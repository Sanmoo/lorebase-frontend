import '../../../../l10n/strings.g.dart';

enum GameTrackingStatus {
  wantToPlay('WANT_TO_PLAY'),
  playing('PLAYING'),
  completed('COMPLETED'),
  dropped('DROPPED');

  final String value;

  const GameTrackingStatus(this.value);

  String label(Translations t) {
    return switch (this) {
      GameTrackingStatus.wantToPlay => t.tracking_want_to_play_game,
      GameTrackingStatus.playing => t.tracking_playing_game,
      GameTrackingStatus.completed => t.tracking_completed_game,
      GameTrackingStatus.dropped => t.tracking_dropped_game,
    };
  }

  static GameTrackingStatus fromString(String value) {
    return GameTrackingStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameTrackingStatus.wantToPlay,
    );
  }
}
