import '../../../l10n/strings.g.dart';
import 'models/book_tracking_status.dart';
import 'models/game_tracking_status.dart';
import 'models/media_tracking_status.dart';
import 'models/media_type.dart';

enum TrackingStatus implements MediaTrackingStatus {
  wantToWatch('WANT_TO_WATCH', 'tracking_want_to_watch'),
  watching('WATCHING', 'tracking_watching'),
  completed('COMPLETED', 'tracking_completed'),
  dropped('DROPPED', 'tracking_dropped');

  @override
  final String value;
  final String i18nKey;

  const TrackingStatus(this.value, this.i18nKey);

  @override
  String label(Translations t) {
    return switch (this) {
      TrackingStatus.wantToWatch => t.tracking_want_to_watch,
      TrackingStatus.watching => t.tracking_watching,
      TrackingStatus.completed => t.tracking_completed,
      TrackingStatus.dropped => t.tracking_dropped,
    };
  }

  static TrackingStatus fromString(String value) {
    return TrackingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrackingStatus.wantToWatch,
    );
  }
}

/// Returns the statuses accepted by the API for [mediaType].
List<MediaTrackingStatus> trackingStatusesFor(MediaType mediaType) {
  return switch (mediaType) {
    MediaType.game => List<MediaTrackingStatus>.of(GameTrackingStatus.values),
    MediaType.book => List<MediaTrackingStatus>.of(BookTrackingStatus.values),
    MediaType.series ||
    MediaType.movie => List<MediaTrackingStatus>.of(TrackingStatus.values),
  };
}

/// Parses a status using the vocabulary for [mediaType].
MediaTrackingStatus trackingStatusForMediaType(
  MediaType mediaType,
  String value,
) {
  final statuses = trackingStatusesFor(mediaType);
  return statuses.firstWhere(
    (status) => status.value == value,
    orElse: () => statuses.first,
  );
}
