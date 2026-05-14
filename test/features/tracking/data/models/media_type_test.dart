import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('MediaType', () {
    test('apiValue exposes stable backend values', () {
      expect(MediaType.series.apiValue, 'series');
      expect(MediaType.movie.apiValue, 'movie');
    });

    test('fromApiValue parses known values and rejects unknown ones', () {
      expect(MediaTypeX.fromApiValue('series'), MediaType.series);
      expect(MediaTypeX.fromApiValue('movie'), MediaType.movie);
      expect(
        () => MediaTypeX.fromApiValue('board_game'),
        throwsArgumentError,
      );
    });

    test('label() returns correct translated labels', () {
      final ptBr = AppLocale.ptBr.buildSync();
      expect(MediaType.series.label(ptBr), 'Séries');
      expect(MediaType.movie.label(ptBr), 'Filmes');
    });

    test('mediaTypeFromJson and mediaTypeToJson roundtrip', () {
      expect(mediaTypeFromJson('series'), MediaType.series);
      expect(mediaTypeToJson(MediaType.movie), 'movie');
      expect(
        () => mediaTypeFromJson('invalid'),
        throwsArgumentError,
      );
    });
  });
}
