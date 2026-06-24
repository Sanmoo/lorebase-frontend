import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/game_tracking_status.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('GameTrackingStatus', () {
    test('values map to backend strings', () {
      expect(GameTrackingStatus.wantToPlay.value, 'WANT_TO_PLAY');
      expect(GameTrackingStatus.playing.value, 'PLAYING');
      expect(GameTrackingStatus.completed.value, 'COMPLETED');
      expect(GameTrackingStatus.dropped.value, 'DROPPED');
    });

    test('fromString returns matching value', () {
      expect(
        GameTrackingStatus.fromString('PLAYING'),
        GameTrackingStatus.playing,
      );
    });

    test('fromString defaults to wantToPlay for unknown', () {
      expect(
        GameTrackingStatus.fromString('INVALID'),
        GameTrackingStatus.wantToPlay,
      );
    });

    test('label returns translated strings', () async {
      final ptBr = await AppLocale.ptBr.build();
      expect(GameTrackingStatus.wantToPlay.label(ptBr), 'Quero Jogar');
      expect(GameTrackingStatus.playing.label(ptBr), 'Jogando');
      expect(GameTrackingStatus.completed.label(ptBr), 'Concluído');
      expect(GameTrackingStatus.dropped.label(ptBr), 'Abandonado');
    });
  });
}
