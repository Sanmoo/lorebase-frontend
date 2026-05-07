import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/tracking_status.dart';

void main() {
  group('TrackingStatus', () {
    test('fromString("WATCHING") returns watching', () {
      expect(
        TrackingStatus.fromString('WATCHING'),
        TrackingStatus.watching,
      );
    });

    test('fromString("WANT_TO_WATCH") returns wantToWatch', () {
      expect(
        TrackingStatus.fromString('WANT_TO_WATCH'),
        TrackingStatus.wantToWatch,
      );
    });

    test('fromString("COMPLETED") returns completed', () {
      expect(
        TrackingStatus.fromString('COMPLETED'),
        TrackingStatus.completed,
      );
    });

    test('fromString("DROPPED") returns dropped', () {
      expect(
        TrackingStatus.fromString('DROPPED'),
        TrackingStatus.dropped,
      );
    });

    test('fromString("INVALID") falls back to wantToWatch', () {
      expect(
        TrackingStatus.fromString('INVALID'),
        TrackingStatus.wantToWatch,
      );
    });

    test('each enum value has correct value and label', () {
      expect(TrackingStatus.wantToWatch.value, 'WANT_TO_WATCH');
      expect(TrackingStatus.wantToWatch.label, 'Want to Watch');

      expect(TrackingStatus.watching.value, 'WATCHING');
      expect(TrackingStatus.watching.label, 'Watching');

      expect(TrackingStatus.completed.value, 'COMPLETED');
      expect(TrackingStatus.completed.label, 'Completed');

      expect(TrackingStatus.dropped.value, 'DROPPED');
      expect(TrackingStatus.dropped.label, 'Dropped');
    });

    test('TrackingStatus.values length is 4', () {
      expect(TrackingStatus.values.length, 4);
    });
  });
}
