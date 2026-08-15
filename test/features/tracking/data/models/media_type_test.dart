import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/l10n/strings.g.dart';

void main() {
  group('MediaType', () {
    test('apiValue exposes stable backend values', () {
      expect(MediaType.series.apiValue, 'SERIES');
      expect(MediaType.movie.apiValue, 'MOVIE');
    });

    test('fromApiValue parses known values and rejects unknown ones', () {
      expect(MediaTypeX.fromApiValue('series'), MediaType.series);
      expect(MediaTypeX.fromApiValue('movie'), MediaType.movie);
      expect(() => MediaTypeX.fromApiValue('board_game'), throwsArgumentError);
    });

    test('label() returns correct translated labels', () async {
      final ptBr = await AppLocale.ptBr.build();
      expect(MediaType.series.label(ptBr), 'Séries');
      expect(MediaType.movie.label(ptBr), 'Filmes');
      expect(MediaType.game.label(ptBr), 'Jogos');
    });

    test('mediaTypeFromJson and mediaTypeToJson roundtrip', () {
      expect(mediaTypeFromJson('series'), MediaType.series);
      expect(mediaTypeToJson(MediaType.movie), 'MOVIE');
      expect(() => mediaTypeFromJson('invalid'), throwsArgumentError);
    });

    test('MediaType includes game and book', () {
      expect(MediaType.game.apiValue, 'GAME');
      expect(MediaType.book.apiValue, 'BOOK');
    });

    test('mediaTypeFromJson parses GAME and BOOK', () {
      expect(mediaTypeFromJson('GAME'), MediaType.game);
      expect(mediaTypeFromJson('book'), MediaType.book);
    });

    test('label() returns the book label', () async {
      final enUs = await AppLocale.enUs.build();
      expect(MediaType.book.label(enUs), 'Books');
    });
  });
}
