// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/social_follow_list_viewmodel.dart';
import '../viewmodels/social_profile_viewmodel.dart';
import '../viewmodels/social_public_lists_viewmodel.dart';
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
                  _PublicListsTab(userId: state.profile.userId),
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

class _PublicListsTab extends StatelessWidget {
  const _PublicListsTab({required this.userId});

  static const _sections = [
    _PublicListStatusSectionConfig(status: 'PLAN_TO_WATCH', label: 'Quero ver'),
    _PublicListStatusSectionConfig(status: 'WATCHING', label: 'Assistindo'),
    _PublicListStatusSectionConfig(status: 'COMPLETED', label: 'Concluído'),
    _PublicListStatusSectionConfig(status: 'DROPPED', label: 'Abandonado'),
  ];

  final String userId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Listas públicas',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ..._sectionWidgets(),
        ],
      ),
    );
  }

  List<Widget> _sectionWidgets() {
    final widgets = <Widget>[];
    for (var index = 0; index < _sections.length; index += 1) {
      if (index > 0) {
        widgets.add(const SizedBox(height: 24));
      }
      widgets.add(
        _PublicListStatusSection(userId: userId, section: _sections[index]),
      );
    }
    return widgets;
  }
}

class _PublicListStatusSection extends ConsumerWidget {
  const _PublicListStatusSection({required this.userId, required this.section});

  final String userId;
  final _PublicListStatusSectionConfig section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(
      socialPublicListsViewModelProvider(userId, status: section.status),
    );
    return list.when(
      data: (data) => PublicMediaListSection(
        title: section.label,
        items: data.items,
        emptyMessage: 'Nenhum item em ${section.label}.',
        padding: EdgeInsets.zero,
        scrollable: false,
        showGroupedStatusHeadings: false,
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Não foi possível carregar ${section.label}.'),
      ),
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Carregando ${section.label}...'),
          ],
        ),
      ),
    );
  }
}

class _PublicListStatusSectionConfig {
  const _PublicListStatusSectionConfig({
    required this.status,
    required this.label,
  });

  final String status;
  final String label;
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
                leading: CircleAvatar(
                  backgroundImage: relationship.avatarUrl != null
                      ? NetworkImage(relationship.avatarUrl!)
                      : null,
                  child: relationship.avatarUrl == null
                      ? Text(relationship.displayName.characters.first)
                      : null,
                ),
                title: Text(relationship.displayName),
                subtitle:
                    relationship.username != null &&
                        relationship.username!.trim().isNotEmpty
                    ? Text('@${relationship.username}')
                    : null,
                onTap: () =>
                    context.go('/social/profile/${relationship.userId}'),
              ),
          ],
        );
      },
      error: (_, _) => const Center(child: Text('Erro ao carregar lista.')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
