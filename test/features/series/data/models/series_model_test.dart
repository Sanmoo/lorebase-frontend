import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

void main() {
  group('SeriesModel', () {
    const completeJson = {
      'tmdbId': 123,
      'title': 'Test Series',
      'overview': 'A test',
      'posterPath': '/p.jpg',
      'backdropPath': '/b.jpg',
      'firstAirDate': '2024-01-01',
      'genres': ['Drama'],
      'networks': ['HBO'],
      'seasonCount': 3,
      'status': 'Ended',
    };

    const minimalJson = {
      'tmdbId': 456,
      'title': 'Minimal Series',
    };

    test('fromJson with complete JSON maps all fields correctly', () {
      final model = SeriesModel.fromJson(completeJson);

      expect(model.tmdbId, 123);
      expect(model.title, 'Test Series');
      expect(model.overview, 'A test');
      expect(model.posterPath, '/p.jpg');
      expect(model.backdropPath, '/b.jpg');
      expect(model.firstAirDate, '2024-01-01');
      expect(model.genres, ['Drama']);
      expect(model.networks, ['HBO']);
      expect(model.seasonCount, 3);
      expect(model.status, 'Ended');
    });

    test('fromJson with missing optional fields uses defaults', () {
      final model = SeriesModel.fromJson(minimalJson);

      expect(model.tmdbId, 456);
      expect(model.title, 'Minimal Series');
      expect(model.overview, isNull);
      expect(model.posterPath, isNull);
      expect(model.backdropPath, isNull);
      expect(model.firstAirDate, isNull);
      expect(model.genres, isEmpty);
      expect(model.networks, isEmpty);
      expect(model.seasonCount, 0);
      expect(model.status, isNull);
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = SeriesModel.fromJson(completeJson);
      final json = original.toJson();
      final restored = SeriesModel.fromJson(json);

      expect(restored.tmdbId, original.tmdbId);
      expect(restored.title, original.title);
      expect(restored.overview, original.overview);
      expect(restored.posterPath, original.posterPath);
      expect(restored.backdropPath, original.backdropPath);
      expect(restored.firstAirDate, original.firstAirDate);
      expect(restored.genres, original.genres);
      expect(restored.networks, original.networks);
      expect(restored.seasonCount, original.seasonCount);
      expect(restored.status, original.status);
    });
  });
}
