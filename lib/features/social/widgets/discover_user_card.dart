import 'package:flutter/material.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../data/models/discover_user_model.dart';

class DiscoverUserCard extends StatelessWidget {
  const DiscoverUserCard({
    super.key,
    required this.user,
    required this.onFollow,
    this.onUserTap,
    this.isFollowing = false,
  });

  final DiscoverUserModel user;
  final VoidCallback onFollow;
  final VoidCallback? onUserTap;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    final affinity = (user.affinityScore * 100).round();
    final t = context.t;

    return Card(
      child: InkWell(
        onTap: onUserTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(_initial(user.displayName))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(t.social_affinity(percent: affinity)),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: user.isFollowedByMe || isFollowing
                        ? null
                        : onFollow,
                    child: isFollowing
                        ? Semantics(
                            label: t.social_following_user_semantics,
                            child: const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Text(
                            user.isFollowedByMe
                                ? t.social_following_action
                                : t.social_follow,
                          ),
                  ),
                ],
              ),
              if (user.commonGenres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final genre in user.commonGenres)
                      Chip(label: Text(genre)),
                  ],
                ),
              ],
              if (user.commonMedia.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  user.commonMedia.map((media) => media.title).join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _initial(String value) {
    return value.trim().isEmpty
        ? '?'
        : value.trim().characters.first.toUpperCase();
  }
}
