import 'package:flutter/material.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../data/models/social_profile_model.dart';
import 'social_follow_button.dart';

class SocialProfileHeader extends StatelessWidget {
  const SocialProfileHeader({
    super.key,
    required this.profile,
    required this.isMe,
    this.onFollow,
    this.onUnfollow,
    this.onEdit,
    this.onAvatarEdit,
    this.isLoading = false,
    this.isAvatarUploading = false,
  });

  final SocialProfileModel profile;
  final bool isMe;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onEdit;
  final VoidCallback? onAvatarEdit;
  final bool isLoading;
  final bool isAvatarUploading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfileAvatar(
            profile: profile,
            isMe: isMe,
            onAvatarEdit: onAvatarEdit,
            isAvatarUploading: isAvatarUploading,
            initial: _initial(profile.displayName),
          ),
          const SizedBox(height: 12),
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                context.t.social_followers_count(count: profile.followerCount),
              ),
              Text(
                context.t.social_following_count(count: profile.followingCount),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMe)
            FilledButton.tonal(
              onPressed: onEdit,
              child: Text(context.t.social_edit_profile),
            )
          else
            SocialFollowButton(
              isFollowedByMe: profile.isFollowedByMe,
              isLoading: isLoading,
              onFollow: onFollow,
              onUnfollow: onUnfollow,
            ),
        ],
      ),
    );
  }

  String _initial(String value) {
    return value.trim().isEmpty
        ? '?'
        : value.trim().characters.first.toUpperCase();
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.isMe,
    required this.initial,
    this.onAvatarEdit,
    this.isAvatarUploading = false,
  });

  final SocialProfileModel profile;
  final bool isMe;
  final String initial;
  final VoidCallback? onAvatarEdit;
  final bool isAvatarUploading;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = profile.avatarUrl?.trim();
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final canEdit = isMe && onAvatarEdit != null && !isAvatarUploading;
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child: hasAvatar
              ? null
              : Text(
                  initial,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
        ),
        if (isMe && onAvatarEdit != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        if (isAvatarUploading)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.72),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
      ],
    );

    if (!isMe || onAvatarEdit == null) {
      return avatar;
    }

    return InkWell(
      key: const Key('socialProfileAvatarAction'),
      customBorder: const CircleBorder(),
      onTap: canEdit ? onAvatarEdit : null,
      child: avatar,
    );
  }
}
