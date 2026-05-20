import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/data/models/movie_model.dart';

void main() {
  group('MovieModel', () {
    const completeJson = {
      'tmdbId': 550,
      'title': 'Fight Club',
      'overview': 'A film about an underground fight club',
      'posterPath': '/fight.jpg',
      'backdropPath': '/fight-bg.jpg',
      'releaseDate': '1999-10-15',
      'genres': ['Drama'],
      'runtimeMinutes': 139,
      'status': 'Released',
    };

    const minimalJson = {
      'tmdbId': 77,
      'title': 'Memento',
    };

    test('fromJson with complete JSON maps all fields correctly', () {
      final movie = MovieModel.fromJson(completeJson);

      expect(movie.tmdbId, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.overview, 'A film about an underground fight club');
      expect(movie.posterPath, '/fight.jpg');
      expect(movie.backdropPath, '/fight-bg.jpg');
      expect(movie.releaseDate, '1999-10-15');
      expect(movie.genres, ['Drama']);
      expect(movie.runtimeMinutes, 139);
      expect(movie.status, 'Released');
    });

    test('fromJson with missing optional fields uses defaults', () {
      final movie = MovieModel.fromJson(minimalJson);

      expect(movie.tmdbId, 77);
      expect(movie.title, 'Memento');
      expect(movie.overview, isNull);
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.genres, isEmpty);
      expect(movie.runtimeMinutes, isNull);
      expect(movie.status, isNull);
    });

    test('toJson() -> fromJson() roundtrip preserves data', () {
      final original = MovieModel.fromJson(completeJson);
      final json = original.toJson();
      final restored = MovieModel.fromJson(json);

      expect(restored.tmdbId, original.tmdbId);
      expect(restored.title, original.title);
      expect(restored.overview, original.overview);
      expect(restored.posterPath, original.posterPath);
      expect(restored.backdropPath, original.backdropPath);
      expect(restored.releaseDate, original.releaseDate);
      expect(restored.genres, original.genres);
      expect(restored.runtimeMinutes, original.runtimeMinutes);
      expect(restored.status, original.status);
    });

    test('fromJson accepts tmdbId as String', () {
      const jsonWithStringId = {
        'tmdbId': '550',
        'title': 'Fight Club',
        'overview': 'A film about an underground fight club',
        'posterPath': '/fight.jpg',
        'backdropPath': '/fight-bg.jpg',
        'releaseDate': '1999-10-15',
        'genres': ['Drama'],
        'runtimeMinutes': 139,
        'status': 'Released',
      };
      final movie = MovieModel.fromJson(jsonWithStringId);

      expect(movie.tmdbId, 550);
      expect(movie.title, 'Fight Club');
    });

    test('fromJson accepts runtime field from API', () {
      final movie = MovieModel.fromJson({
        ...minimalJson,
        'runtime': 113,
      });

      expect(movie.runtimeMinutes, 113);
    });
  });
}
