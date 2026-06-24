import '../../../l10n/strings.g.dart';
import '../data/models/activity_event_model.dart';

String localizedSocialActivityVerb(String type) {
  return switch (type.toUpperCase()) {
    'RATED' => t.social_activity_rated,
    'REVIEWED' => t.social_activity_reviewed,
    'COMPLETED' => t.social_activity_completed,
    'STARTED_WATCHING' => t.social_activity_started_watching,
    'STARTED_PLAYING' => t.social_activity_started_playing,
    'DROPPED' => t.social_activity_dropped,
    'ADDED_TO_LIST' => t.social_activity_added_to_list,
    _ => t.social_activity_interacted_with,
  };
}

String? socialActivityListNameFor(ActivityEventModel event) {
  final raw = event.metadata['listName'] ?? event.metadata['list_name'];
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

String socialActivityTextFor(ActivityEventModel event) {
  final listName = socialActivityListNameFor(event);
  if (event.activityType.toUpperCase() == 'ADDED_TO_LIST' && listName != null) {
    return '${event.user.displayName} adicionou ${event.media.title} à lista $listName';
  }

  return '${event.user.displayName} ${localizedSocialActivityVerb(event.activityType)} ${event.media.title}';
}
