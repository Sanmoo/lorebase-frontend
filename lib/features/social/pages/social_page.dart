// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.g.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/logging/debug_log.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import '../viewmodels/social_discover_viewmodel.dart';
import '../viewmodels/social_feed_viewmodel.dart';
import '../widgets/discover_user_card.dart';
import '../widgets/social_activity_card.dart';
import '../widgets/social_empty_feed.dart';
import 'social_onboarding_page.dart';

final mySocialProfileProvider = FutureProvider.autoDispose<SocialProfileModel>(
  retry: (_, _) => null,
  (ref) async {
    debugLog('[SocialProfile] load started');
    try {
      final profile = await ref.watch(socialRepositoryProvider).getMyProfile();
      debugLog('[SocialProfile] load success');
      return profile;
    } on ServerException catch (error) {
      if (error.statusCode == 404) {
        debugLog('[SocialProfile] load missing status=404');
      } else {
        debugLog(
          '[SocialProfile] load failed status=${error.statusCode} '
          'type=ServerException',
        );
      }
      rethrow;
    } catch (error) {
      debugLog('[SocialProfile] load failed type=${error.runtimeType}');
      rethrow;
    }
  },
);

class SocialPage extends ConsumerStatefulWidget {
  const SocialPage({super.key});

  @override
  ConsumerState<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends ConsumerState<SocialPage> {
  bool _showOnboardingUntilFinished = false;

  @override
  Widget build(BuildContext context) {
    if (_showOnboardingUntilFinished) {
      return _onboarding();
    }

    final profile = ref.watch(mySocialProfileProvider);

    return profile.when(
      data: (profile) => _SocialTabs(profile: profile),
      error: (error, _) {
        if (error is ServerException && error.statusCode == 404) {
          return _onboarding();
        }
        return Center(child: Text(context.t.social_load_error));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _onboarding() {
    return SocialOnboardingPage(
      onProfileCreated: () {
        setState(() => _showOnboardingUntilFinished = true);
      },
      onFinish: () {
        setState(() => _showOnboardingUntilFinished = false);
        ref.invalidate(mySocialProfileProvider);
      },
    );
  }
}

class _SocialTabs extends StatelessWidget {
  const _SocialTabs({required this.profile});

  final SocialProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextButton(
                onPressed: () => context.go('/social/profile/me'),
                child: Text(context.t.social_my_profile),
              ),
            ),
          ),
          TabBar(
            tabs: [
              Tab(text: context.t.social_feed),
              Tab(text: context.t.social_discover),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [_FeedTab(), _DiscoverTab()]),
          ),
        ],
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(socialFeedViewModelProvider);
    return feed.when(
      data: (data) {
        if (data.items.isEmpty) {
          return SocialEmptyFeed(
            onDiscoverTap: () => DefaultTabController.of(context).animateTo(1),
          );
        }
        return ListView.builder(
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final event = data.items[index];
            return SocialActivityCard(
              event: event,
              onUserTap: () =>
                  context.go('/social/profile/${event.user.userId}'),
              onMediaTap: () => context.go(
                event.media.mediaType == 'SERIES'
                    ? '/series/${event.media.mediaId}'
                    : '/movies/${event.media.mediaId}',
              ),
            );
          },
        );
      },
      error: (_, _) => Center(child: Text(context.t.social_feed_load_error)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DiscoverTab extends ConsumerStatefulWidget {
  const _DiscoverTab();

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab> {
  final Set<String> _followingUserIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final discover = ref.watch(socialDiscoverViewModelProvider);
    return discover.when(
      data: (data) {
        if (data.items.isEmpty) {
          return Center(child: Text(context.t.social_discover_empty));
        }
        return ListView.builder(
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final user = data.items[index];
            return DiscoverUserCard(
              user: user,
              isFollowing: _followingUserIds.contains(user.userId),
              onFollow: () => _followUser(user.userId),
              onUserTap: () => context.go('/social/profile/${user.userId}'),
            );
          },
        );
      },
      error: (error, _) => _DiscoverErrorState(
        message: error is ServerException && error.statusCode == 504
            ? 'O Discover demorou para responder. Tente novamente em instantes.'
            : 'Erro ao descobrir pessoas.',
        onRetry: () =>
            ref.read(socialDiscoverViewModelProvider.notifier).refresh(),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _followUser(String userId) async {
    if (_followingUserIds.contains(userId)) {
      return;
    }

    setState(() => _followingUserIds.add(userId));
    try {
      await ref
          .read(socialDiscoverViewModelProvider.notifier)
          .followUser(userId);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.social_follow_error)));
    } finally {
      if (mounted) {
        setState(() => _followingUserIds.remove(userId));
      }
    }
  }
}

class _DiscoverErrorState extends StatelessWidget {
  const _DiscoverErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.t.social_try_again),
            ),
          ],
        ),
      ),
    );
  }
}
