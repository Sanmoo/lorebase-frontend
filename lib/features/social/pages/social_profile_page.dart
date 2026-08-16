// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/strings.g.dart';
import '../data/avatar_image_picker.dart';
import '../viewmodels/social_avatar_viewmodel.dart';
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
    final avatarState = ref.watch(socialAvatarViewModelProvider);

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
              isAvatarUploading: isMe && avatarState.isUploading,
              onAvatarEdit: isMe ? () => _pickAvatarSource(context, ref) : null,
            ),
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: context.t.social_activity),
                Tab(text: context.t.social_lists),
                Tab(text: context.t.social_followers),
                Tab(text: context.t.social_following),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ActivityTab(state: state, isMe: isMe),
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
      error: (_, _) =>
          Center(child: Text(context.t.social_profile_unavailable)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

Future<void> _pickAvatarSource(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<AvatarImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(context.t.social_choose_from_gallery),
            onTap: () => Navigator.of(context).pop(AvatarImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(context.t.social_take_photo),
            onTap: () => Navigator.of(context).pop(AvatarImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(context.t.social_cancel),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
  if (source == null || !context.mounted) {
    return;
  }

  await ref.read(socialAvatarViewModelProvider.notifier).uploadFrom(source);
  if (!context.mounted) {
    return;
  }
  final state = ref.read(socialAvatarViewModelProvider);
  final message =
      state.error?.localizedMessage(context) ??
      (state.lastUploadSucceeded
          ? context.t.social_avatar_updated_success
          : null);
  if (message != null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

extension _SocialAvatarErrorMessage on SocialAvatarError {
  String localizedMessage(BuildContext context) {
    final t = context.t;
    return switch (this) {
      SocialAvatarError.invalidType => t.social_avatar_invalid_type,
      SocialAvatarError.sizeLimit => t.social_avatar_size_limit,
      SocialAvatarError.accessFailure => t.social_avatar_access_failure,
      SocialAvatarError.updateFailure => t.social_avatar_update_failure,
    };
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.state, required this.isMe});

  final SocialProfileDetailState state;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    if (state.hasActivityError) {
      return Center(child: Text(context.t.social_profile_activity_load_error));
    }
    if (state.activity.items.isEmpty) {
      return Center(child: Text(context.t.social_empty_public_activity));
    }
    final actorLabel = isMe ? 'Você' : state.profile.displayName;
    return ListView.builder(
      itemCount: state.activity.items.length,
      itemBuilder: (context, index) {
        final event = state.activity.items[index];
        return SocialActivityCard(
          event: event,
          actorLabel: actorLabel,
          onUserTap: () => context.go('/social/profile/${event.user.userId}'),
          onMediaTap: () => context.go(
            switch (event.media.mediaType.toUpperCase()) {
              'SERIES' => '/series/${event.media.mediaId}',
              'BOOK' => '/books/${event.media.mediaId}',
              _ => '/movies/${event.media.mediaId}',
            },
          ),
        );
      },
    );
  }
}

class _PublicListsTab extends StatelessWidget {
  const _PublicListsTab({required this.userId});

  static const _sections = [
    _PublicListStatusSectionConfig(
      status: 'PLAN_TO_WATCH',
      label: _PublicListStatusLabel.planToWatch,
    ),
    _PublicListStatusSectionConfig(
      status: 'WATCHING',
      label: _PublicListStatusLabel.watching,
    ),
    _PublicListStatusSectionConfig(
      status: 'COMPLETED',
      label: _PublicListStatusLabel.completed,
    ),
    _PublicListStatusSectionConfig(
      status: 'DROPPED',
      label: _PublicListStatusLabel.dropped,
    ),
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
            context.t.social_public_lists_title,
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
    final sectionLabel = section.localizedLabel(context);
    return list.when(
      data: (data) => PublicMediaListSection(
        title: sectionLabel,
        items: data.items,
        emptyMessage: context.t.social_public_list_empty(section: sectionLabel),
        padding: EdgeInsets.zero,
        scrollable: false,
        showGroupedStatusHeadings: false,
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(context.t.social_section_load_error(section: sectionLabel)),
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
            Text(context.t.social_section_loading(section: sectionLabel)),
          ],
        ),
      ),
    );
  }
}

enum _PublicListStatusLabel { planToWatch, watching, completed, dropped }

class _PublicListStatusSectionConfig {
  const _PublicListStatusSectionConfig({
    required this.status,
    required this.label,
  });

  final String status;
  final _PublicListStatusLabel label;

  String localizedLabel(BuildContext context) {
    final t = context.t;
    return switch (label) {
      _PublicListStatusLabel.planToWatch => t.social_status_plan_to_watch,
      _PublicListStatusLabel.watching => t.social_status_watching,
      _PublicListStatusLabel.completed => t.social_status_completed,
      _PublicListStatusLabel.dropped => t.social_status_dropped,
    };
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
          return Center(child: Text(context.t.social_empty_people));
        }
        return ListView(
          children: [
            for (final relationship in data.items)
              Builder(
                builder: (context) {
                  final trimmedDisplayName = relationship.displayName.trim();
                  final trimmedUsername = relationship.username?.trim();
                  final displayInitial = trimmedDisplayName.isNotEmpty
                      ? trimmedDisplayName.characters.first
                      : null;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: relationship.avatarUrl != null
                          ? NetworkImage(relationship.avatarUrl!)
                          : null,
                      child: relationship.avatarUrl == null
                          ? displayInitial != null
                                ? Text(displayInitial)
                                : const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(relationship.displayName),
                    subtitle:
                        trimmedUsername != null && trimmedUsername.isNotEmpty
                        ? Text('@$trimmedUsername')
                        : null,
                    onTap: () =>
                        context.go('/social/profile/${relationship.userId}'),
                  );
                },
              ),
          ],
        );
      },
      error: (_, _) => Center(child: Text(context.t.social_list_load_error)),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
