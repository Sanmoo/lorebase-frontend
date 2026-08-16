import 'package:flutter/material.dart';

import '../../../l10n/strings.g.dart';
import '../data/models/activity_event_model.dart';
import 'social_activity_verb.dart';

class SocialActivityCard extends StatelessWidget {
  const SocialActivityCard({
    super.key,
    required this.event,
    this.actorLabel,
    required this.onUserTap,
    required this.onMediaTap,
  });

  final ActivityEventModel event;
  final String? actorLabel;
  final VoidCallback onUserTap;
  final VoidCallback onMediaTap;

  @override
  Widget build(BuildContext context) {
    final rating = event.metadata['rating'];
    final review = event.metadata['review'] ?? event.metadata['reviewSnippet'];
    final listName = socialActivityListNameFor(event);
    final showsNamedList =
        event.activityType.toUpperCase() == 'ADDED_TO_LIST' && listName != null;
    final displayedActor = actorLabel ?? event.user.displayName;

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
                    displayedActor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  showsNamedList
                      ? t.social_activity_added
                      : localizedSocialActivityVerb(
                          event.activityType,
                          mediaType: event.media.mediaType,
                        ),
                ),
                InkWell(
                  onTap: onMediaTap,
                  child: Text(
                    event.media.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (showsNamedList)
                  Text('${t.social_activity_to_list} $listName'),
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
}
