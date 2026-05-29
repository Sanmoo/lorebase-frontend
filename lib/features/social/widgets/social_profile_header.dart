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
    this.isLoading = false,
  });

  final SocialProfileModel profile;
  final bool isMe;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onEdit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              _initial(profile.displayName),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
