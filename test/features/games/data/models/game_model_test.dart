import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/data/models/game_model.dart';

void main() {
  group('GameModel', () {
    test('fromJson parses backend response', () {
      final json = {
        'gameId': '1234',
        'title': 'Hades',
        'summary': 'Roguelike',
        'genre': 'Action',
        'coverUrl': 'https://example.com/cover.jpg',
        'releaseDate': '2020-09-17',
        'platforms': ['PC', 'Switch', 'PS5'],
        'developer': 'Supergiant Games',
        'publisher': 'Supergiant Games',
        'franchise': 'Hades',
        'gameModes': ['Single player'],
      };

      final model = GameModel.fromJson(json);
      expect(model.gameId, '1234');
      expect(model.title, 'Hades');
      expect(model.platforms, ['PC', 'Switch', 'PS5']);
    });
  });
}
