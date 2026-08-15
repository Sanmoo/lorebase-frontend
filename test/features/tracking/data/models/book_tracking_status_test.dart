import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/book_tracking_status.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('BookTrackingStatus', () {
    test('values map to the reading statuses accepted by the API', () {
      expect(BookTrackingStatus.wantToRead.value, 'WANT_TO_READ');
      expect(BookTrackingStatus.reading.value, 'READING');
      expect(BookTrackingStatus.completed.value, 'COMPLETED');
      expect(BookTrackingStatus.dropped.value, 'DROPPED');
    });

    test('fromString returns the matching reading status', () {
      expect(
        BookTrackingStatus.fromString('READING'),
        BookTrackingStatus.reading,
      );
    });

    test('fromString falls back to wantToRead for unknown values', () {
      expect(
        BookTrackingStatus.fromString('WATCHING'),
        BookTrackingStatus.wantToRead,
      );
    });

    test('exposes only the four reading statuses', () {
      expect(BookTrackingStatus.values, [
        BookTrackingStatus.wantToRead,
        BookTrackingStatus.reading,
        BookTrackingStatus.completed,
        BookTrackingStatus.dropped,
      ]);
    });

    test('label returns localized reading labels', () async {
      final ptBr = await AppLocale.ptBr.build();
      expect(BookTrackingStatus.wantToRead.label(ptBr), 'Quero ler');
      expect(BookTrackingStatus.reading.label(ptBr), 'Lendo');
      expect(BookTrackingStatus.completed.label(ptBr), 'Concluído');
      expect(BookTrackingStatus.dropped.label(ptBr), 'Abandonado');
    });
  });
}
