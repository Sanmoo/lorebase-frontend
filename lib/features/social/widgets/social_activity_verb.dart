import '../../../l10n/strings.g.dart';

String localizedSocialActivityVerb(String type) {
  return switch (type.toUpperCase()) {
    'RATED' => t.social_activity_rated,
    'REVIEWED' => t.social_activity_reviewed,
    'COMPLETED' => t.social_activity_completed,
    'STARTED_WATCHING' => t.social_activity_started_watching,
    'DROPPED' => t.social_activity_dropped,
    'ADDED_TO_LIST' => t.social_activity_added_to_list,
    _ => t.social_activity_interacted_with,
  };
}
