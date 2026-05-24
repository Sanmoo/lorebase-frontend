// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/social_follow_list_viewmodel.dart';
import '../viewmodels/social_profile_viewmodel.dart';
import '../widgets/public_media_list_section.dart';
import '../widgets/social_activity_card.dart';
import '../widgets/social_profile_header.dart';

class SocialProfilePage extends ConsumerWidget {
  const SocialProfilePage({super.key, required this.userId, this.isMe = false});

  final String userId;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(socialProfileViewModelProvider(userId));

    return detail.when(
      data: (state) => DefaultTabController(
        length: 4,
        child: Column(
          children: [
            SocialProfileHeader(
              profile: state.profile,
              isMe: isMe,
              isLoading: state.isFollowActionInProgress,
              onFollow: () => ref
                  .read(socialProfileViewModelProvider(userId).notifier)
                  .follow(),
              onUnfollow: () => ref
                  .read(socialProfileViewModelProvider(userId).notifier)
                  .unfollow(),
              onEdit: () => context.push('/social/profile/edit'),
            ),
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Activity'),
                Tab(text: 'Lists'),
                Tab(text: 'Followers'),
                Tab(text: 'Following'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ActivityTab(state: state),
                  PublicMediaListSection(
                    title: 'Listas públicas',
                    items: state.publicLists.items,
                  ),
                  _FollowListTab(
                    userId: userId,
                    kind: SocialFollowListKind.followers,
                  ),
                  _FollowListTab(
                    userId: userId,
                    kind: SocialFollowListKind.following,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => const Center(
        child: Text('Este perfil não está disponível no momento.'),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.state});

  final SocialProfileDetailState state;

  @override
  Widget build(BuildContext context) {
    if (state.activity.items.isEmpty) {
      return const Center(child: Text('Nenhuma atividade pública ainda.'));
    }
    return ListView.builder(
      itemCount: state.activity.items.length,
      itemBuilder: (context, index) {
        final event = state.activity.items[index];
        return SocialActivityCard(
          event: event,
          onUserTap: () => context.go('/social/profile/${event.user.userId}'),
          onMediaTap: () => context.go(
            event.media.mediaType == 'SERIES'
                ? '/series/${event.media.mediaId}'
                : '/movies/${event.media.mediaId}',
          ),
        );
      },
    );
  }
}

class _FollowListTab extends ConsumerWidget {
  const _FollowListTab({required this.userId, required this.kind});

  final String userId;
  final SocialFollowListKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(socialFollowListViewModelProvider(userId, kind));
    return list.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const Center(child: Text('Nenhuma pessoa para mostrar.'));
        }
        return ListView(
          children: [
            for (final relationship in data.items)
              ListTile(
                title: Text(
                  kind == SocialFollowListKind.followers
                      ? relationship.followerId ?? 'Usuário'
                      : relationship.followedId ?? 'Usuário',
                ),
              ),
          ],
        );
      },
      error: (_, _) => const Center(child: Text('Erro ao carregar lista.')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
