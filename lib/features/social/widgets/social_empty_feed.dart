import 'package:flutter/material.dart';

class SocialEmptyFeed extends StatelessWidget {
  const SocialEmptyFeed({super.key, required this.onDiscoverTap});

  final VoidCallback onDiscoverTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              'Seu feed ainda está quieto',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Siga pessoas para ver avaliações, reviews e atividades recentes.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onDiscoverTap,
              child: const Text('Descobrir pessoas'),
            ),
          ],
        ),
      ),
    );
  }
}
