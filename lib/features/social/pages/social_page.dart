// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

final mySocialProfileProvider = FutureProvider<SocialProfileModel>(
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
        return const Center(child: Text('Não foi possível carregar o Social.'));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _onboarding() {
    return SocialOnboardingPage(
      onProfileCreated: () {
        setState(() => _showOnboardingUntilFinished = true);
        ref.invalidate(mySocialProfileProvider);
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
                child: const Text('Meu perfil →'),
              ),
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Discover'),
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
      error: (_, _) => const Center(child: Text('Erro ao carregar feed.')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discover = ref.watch(socialDiscoverViewModelProvider);
    return discover.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const Center(child: Text('Nenhuma sugestão por enquanto.'));
        }
        return ListView.builder(
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final user = data.items[index];
            return DiscoverUserCard(
              user: user,
              onFollow: () => ref
                  .read(socialDiscoverViewModelProvider.notifier)
                  .followUser(user.userId),
              onUserTap: () => context.go('/social/profile/${user.userId}'),
            );
          },
        );
      },
      error: (_, _) => const Center(child: Text('Erro ao descobrir pessoas.')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
