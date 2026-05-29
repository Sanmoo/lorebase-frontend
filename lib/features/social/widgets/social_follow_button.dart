import 'package:flutter/material.dart';
import 'package:lorebase/l10n/strings.g.dart';

class SocialFollowButton extends StatelessWidget {
  const SocialFollowButton({
    super.key,
    required this.isFollowedByMe,
    this.onFollow,
    this.onUnfollow,
    this.isLoading = false,
  });

  final bool isFollowedByMe;
  final bool isLoading;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;

  @override
  Widget build(BuildContext context) {
    final label = isFollowedByMe
        ? context.t.social_unfollow
        : context.t.social_follow;
    final onPressed = isLoading
        ? null
        : (isFollowedByMe ? onUnfollow : onFollow);

    return FilledButton.tonal(
      onPressed: onPressed,
      child: isLoading
          ? Semantics(
              label: context.t.social_follow_updating_semantics,
              child: const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Text(label),
    );
  }
}
