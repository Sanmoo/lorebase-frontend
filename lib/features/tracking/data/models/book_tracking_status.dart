import '../../../../l10n/strings.g.dart';
import 'media_tracking_status.dart';

enum BookTrackingStatus implements MediaTrackingStatus {
  wantToRead('WANT_TO_READ'),
  reading('READING'),
  completed('COMPLETED'),
  dropped('DROPPED');

  const BookTrackingStatus(this.value);

  @override
  final String value;

  @override
  String label(Translations t) {
    return switch (this) {
      BookTrackingStatus.wantToRead => t.tracking_want_to_read,
      BookTrackingStatus.reading => t.tracking_reading,
      BookTrackingStatus.completed => t.tracking_completed,
      BookTrackingStatus.dropped => t.tracking_dropped,
    };
  }

  static BookTrackingStatus fromString(String value) {
    return BookTrackingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookTrackingStatus.wantToRead,
    );
  }
}
