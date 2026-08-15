import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/book_tracking_status.dart';
import 'package:lorebase/features/tracking/data/models/game_tracking_status.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/tracking_status.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('TrackingStatus', () {
    test('fromString("WATCHING") returns watching', () {
      expect(TrackingStatus.fromString('WATCHING'), TrackingStatus.watching);
    });

    test('fromString("WANT_TO_WATCH") returns wantToWatch', () {
      expect(
        TrackingStatus.fromString('WANT_TO_WATCH'),
        TrackingStatus.wantToWatch,
      );
    });

    test('fromString("COMPLETED") returns completed', () {
      expect(TrackingStatus.fromString('COMPLETED'), TrackingStatus.completed);
    });

    test('fromString("DROPPED") returns dropped', () {
      expect(TrackingStatus.fromString('DROPPED'), TrackingStatus.dropped);
    });

    test('fromString("INVALID") falls back to wantToWatch', () {
      expect(TrackingStatus.fromString('INVALID'), TrackingStatus.wantToWatch);
    });

    test('each enum value has correct value and i18nKey', () {
      expect(TrackingStatus.wantToWatch.value, 'WANT_TO_WATCH');
      expect(TrackingStatus.wantToWatch.i18nKey, 'tracking_want_to_watch');

      expect(TrackingStatus.watching.value, 'WATCHING');
      expect(TrackingStatus.watching.i18nKey, 'tracking_watching');

      expect(TrackingStatus.completed.value, 'COMPLETED');
      expect(TrackingStatus.completed.i18nKey, 'tracking_completed');

      expect(TrackingStatus.dropped.value, 'DROPPED');
      expect(TrackingStatus.dropped.i18nKey, 'tracking_dropped');
    });

    test('each enum value has correct label via Translations', () async {
      final t = await AppLocale.enUs.build();
      expect(TrackingStatus.wantToWatch.label(t), 'Want to Watch');
      expect(TrackingStatus.watching.label(t), 'Watching');
      expect(TrackingStatus.completed.label(t), 'Completed');
      expect(TrackingStatus.dropped.label(t), 'Dropped');
    });

    test('TrackingStatus.values length is 4', () {
      expect(TrackingStatus.values.length, 4);
    });

    test('tracking statuses are selected by media context', () {
      expect(trackingStatusesFor(MediaType.series), TrackingStatus.values);
      expect(trackingStatusesFor(MediaType.movie), TrackingStatus.values);
      expect(trackingStatusesFor(MediaType.game), GameTrackingStatus.values);
      expect(trackingStatusesFor(MediaType.book), BookTrackingStatus.values);
    });

    test('status parsing uses the media context and safe defaults', () {
      expect(
        trackingStatusForMediaType(MediaType.book, 'READING'),
        BookTrackingStatus.reading,
      );
      expect(
        trackingStatusForMediaType(MediaType.game, 'READING'),
        GameTrackingStatus.wantToPlay,
      );
      expect(
        trackingStatusForMediaType(MediaType.movie, 'READING'),
        TrackingStatus.wantToWatch,
      );
    });
  });
}
