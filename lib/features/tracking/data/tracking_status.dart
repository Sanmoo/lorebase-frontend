enum TrackingStatus {
  wantToWatch('WANT_TO_WATCH', 'Want to Watch'),
  watching('WATCHING', 'Watching'),
  completed('COMPLETED', 'Completed'),
  dropped('DROPPED', 'Dropped');

  final String value;
  final String label;

  const TrackingStatus(this.value, this.label);

  static TrackingStatus fromString(String value) {
    return TrackingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrackingStatus.wantToWatch,
    );
  }
}
