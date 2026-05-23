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

    const minimalJson = {'tmdbId': 456, 'title': 'Minimal Series'};

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

    test('fromJson maps additional detail metadata', () {
      final model = SeriesModel.fromJson({
        ...completeJson,
        'seriesId': 'series-123',
        'createdAt': '2026-05-23T19:49:39Z',
        'voteAverage': 8.461,
        'voteCount': 26839,
        'popularity': 188.7155,
        'originCountry': ['US'],
        'episodeRunTime': [57, 60],
        'numberOfEpisodes': 73,
        'createdBy': ['David Benioff', 'D. B. Weiss'],
        'type': 'Scripted',
        'lastEpisodeToAir': {
          'airDate': '2019-05-19',
          'episodeNumber': 6,
          'seasonNumber': 8,
          'name': 'The Iron Throne',
          'overview': 'Final episode.',
        },
        'nextEpisodeToAir': {
          'airDate': '2026-01-01',
          'episodeNumber': 1,
          'seasonNumber': 9,
          'name': 'Future Episode',
          'overview': 'A future episode.',
        },
      });

      expect(model.seriesId, 'series-123');
      expect(model.createdAt, '2026-05-23T19:49:39Z');
      expect(model.voteAverage, 8.461);
      expect(model.voteCount, 26839);
      expect(model.popularity, 188.7155);
      expect(model.originCountry, ['US']);
      expect(model.episodeRunTime, [57, 60]);
      expect(model.numberOfEpisodes, 73);
      expect(model.createdBy, ['David Benioff', 'D. B. Weiss']);
      expect(model.type, 'Scripted');
      expect(model.lastEpisodeToAir?.airDate, '2019-05-19');
      expect(model.lastEpisodeToAir?.episodeNumber, 6);
      expect(model.lastEpisodeToAir?.seasonNumber, 8);
      expect(model.lastEpisodeToAir?.name, 'The Iron Throne');
      expect(model.lastEpisodeToAir?.overview, 'Final episode.');
      expect(model.nextEpisodeToAir?.name, 'Future Episode');
    });

    test('fromJson with missing additional metadata uses safe defaults', () {
      final model = SeriesModel.fromJson(minimalJson);

      expect(model.seriesId, isNull);
      expect(model.createdAt, isNull);
      expect(model.voteAverage, isNull);
      expect(model.voteCount, isNull);
      expect(model.popularity, isNull);
      expect(model.originCountry, isEmpty);
      expect(model.episodeRunTime, isEmpty);
      expect(model.numberOfEpisodes, 0);
      expect(model.createdBy, isEmpty);
      expect(model.type, isNull);
      expect(model.lastEpisodeToAir, isNull);
      expect(model.nextEpisodeToAir, isNull);
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

    test('fromJson accepts tmdbId as String', () {
      const jsonWithStringId = {
        'tmdbId': '123',
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
      final model = SeriesModel.fromJson(jsonWithStringId);

      expect(model.tmdbId, 123);
      expect(model.title, 'Test Series');
    });
  });
}
