import 'package:flutter/material.dart';

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
    final label = isFollowedByMe ? 'Deixar de seguir' : 'Seguir';
    final onPressed = isLoading
        ? null
        : (isFollowedByMe ? onUnfollow : onFollow);

    return FilledButton.tonal(
      onPressed: onPressed,
      child: isLoading
          ? Semantics(
              label: 'Atualizando seguir',
              child: const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Text(label),
    );
  }
}
