import '../../../l10n/strings.g.dart';

enum TrackingStatus {
  wantToWatch('WANT_TO_WATCH', 'tracking_want_to_watch'),
  watching('WATCHING', 'tracking_watching'),
  completed('COMPLETED', 'tracking_completed'),
  dropped('DROPPED', 'tracking_dropped');

  final String value;
  final String i18nKey;

  const TrackingStatus(this.value, this.i18nKey);

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
