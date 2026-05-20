import 'package:flutter/material.dart';

import '../data/models/activity_event_model.dart';

class SocialActivityCard extends StatelessWidget {
  const SocialActivityCard({
    super.key,
    required this.event,
    required this.onUserTap,
    required this.onMediaTap,
  });

  final ActivityEventModel event;
  final VoidCallback onUserTap;
  final VoidCallback onMediaTap;

  @override
  Widget build(BuildContext context) {
    final rating = event.metadata['rating'];
    final review = event.metadata['review'] ?? event.metadata['reviewSnippet'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                InkWell(
                  onTap: onUserTap,
                  child: Text(
                    event.user.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(_verbFor(event.activityType)),
                InkWell(
                  onTap: onMediaTap,
                  child: Text(
                    event.media.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (rating != null) ...[
              const SizedBox(height: 8),
              Text('⭐ $rating/10'),
            ],
            if (review != null && review.toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.toString()),
            ],
          ],
        ),
      ),
    );
  }

  String _verbFor(String type) {
    return switch (type) {
      'RATED' => 'avaliou',
      'REVIEWED' => 'escreveu uma review de',
      'COMPLETED' => 'completou',
      'STARTED_WATCHING' => 'começou',
      'DROPPED' => 'abandonou',
      'ADDED_TO_LIST' => 'adicionou à lista',
      _ => 'interagiu com',
    };
  }
}
