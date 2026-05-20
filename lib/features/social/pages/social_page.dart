// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../data/models/social_profile_model.dart';
import '../data/repositories/social_repository.dart';
import '../viewmodels/social_discover_viewmodel.dart';
import '../viewmodels/social_feed_viewmodel.dart';
import '../widgets/discover_user_card.dart';
import '../widgets/social_activity_card.dart';
import '../widgets/social_empty_feed.dart';
import 'social_onboarding_page.dart';

final mySocialProfileProvider = FutureProvider<SocialProfileModel>((ref) {
  return ref.watch(socialRepositoryProvider).getMyProfile();
});

class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(mySocialProfileProvider);

    return profile.when(
      data: (_) => const _SocialTabs(),
      error: (error, _) {
        if (error is ServerException && error.statusCode == 404) {
          return SocialOnboardingPage(
            onProfileCreated: () => ref.invalidate(mySocialProfileProvider),
          );
        }
        return const Center(child: Text('Não foi possível carregar o Social.'));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SocialTabs extends StatelessWidget {
  const _SocialTabs();

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Discover'),
            ],
          ),
          Expanded(child: TabBarView(children: [_FeedTab(), _DiscoverTab()])),
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
          itemBuilder: (context, index) => SocialActivityCard(
            event: data.items[index],
            onUserTap: () {},
            onMediaTap: () {},
          ),
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
              onUserTap: () {},
            );
          },
        );
      },
      error: (_, _) => const Center(child: Text('Erro ao descobrir pessoas.')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
