import 'package:flutter/material.dart';
import 'package:lorebase/l10n/strings.g.dart';

class SocialEmptyFeed extends StatelessWidget {
  const SocialEmptyFeed({super.key, required this.onDiscoverTap});

  final VoidCallback onDiscoverTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              t.social_empty_feed_title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.social_empty_feed_body,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onDiscoverTap,
              child: Text(t.social_discover_people_cta),
            ),
          ],
        ),
      ),
    );
  }
}
