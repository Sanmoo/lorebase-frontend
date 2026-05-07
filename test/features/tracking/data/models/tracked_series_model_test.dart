import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_series_model.dart';
import 'package:lorebase/features/tracking/data/models/season_rating_model.dart';
import 'package:lorebase/features/series/data/models/series_model.dart';

void main() {
  group('TrackedSeriesModel', () {
    final completeJson = {
      'trackingId': 'track-1',
      'userId': 'user-1',
      'seriesId': 'series-1',
      'status': 'watching',
      'seriesRating': 4,
      'seriesReview': 'Great show!',
      'seasonRatings': [
        {
          'seasonNumber': 1,
          'rating': 5,
          'ratedAt': '2024-01-01T00:00:00.000Z',
        },
        {
          'seasonNumber': 2,
          'rating': 4,
          'ratedAt': '2024-06-01T00:00:00.000Z',
        },
      ],
      'series': {
        'tmdbId': 123,
        'title': 'Test Series',
      },
      'addedAt': '2024-01-15T00:00:00.000Z',
      'lastUpdated': '2024-06-15T00:00:00.000Z',
    };

    final jsonWithoutSeries = {
      'trackingId': 'track-2',
      'userId': 'user-2',
      'seriesId': 'series-2',
      'status': 'want_to_watch',
      'seriesRating': null,
      'seriesReview': null,
      'seasonRatings': [],
      'series': null,
      'addedAt': '2024-02-01T00:00:00.000Z',
      'lastUpdated': '2024-02-01T00:00:00.000Z',
    };

    test('fromJson with complete JSON and nested data maps all fields', () {
      final model = TrackedSeriesModel.fromJson(completeJson);

      expect(model.trackingId, 'track-1');
      expect(model.userId, 'user-1');
      expect(model.seriesId, 'series-1');
      expect(model.status, 'watching');
      expect(model.seriesRating, 4);
      expect(model.seriesReview, 'Great show!');

      expect(model.seasonRatings, hasLength(2));
      expect(model.seasonRatings[0], isA<SeasonRatingModel>());
      expect(model.seasonRatings[0].seasonNumber, 1);
      expect(model.seasonRatings[0].rating, 5);
      expect(model.seasonRatings[1].seasonNumber, 2);
      expect(model.seasonRatings[1].rating, 4);

      expect(model.series, isA<SeriesModel>());
      expect(model.series!.tmdbId, 123);
      expect(model.series!.title, 'Test Series');

      expect(model.addedAt, DateTime.parse('2024-01-15T00:00:00.000Z'));
      expect(model.lastUpdated, DateTime.parse('2024-06-15T00:00:00.000Z'));
    });

    test('fromJson without series maps series as null', () {
      final model = TrackedSeriesModel.fromJson(jsonWithoutSeries);

      expect(model.trackingId, 'track-2');
      expect(model.status, 'want_to_watch');
      expect(model.seriesRating, isNull);
      expect(model.seriesReview, isNull);
      expect(model.seasonRatings, isEmpty);
      expect(model.series, isNull);
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = TrackedSeriesModel.fromJson(completeJson);
      final jsonString = jsonEncode(original.toJson());
      final restored = TrackedSeriesModel.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      expect(restored.trackingId, original.trackingId);
      expect(restored.userId, original.userId);
      expect(restored.seriesId, original.seriesId);
      expect(restored.status, original.status);
      expect(restored.seriesRating, original.seriesRating);
      expect(restored.seriesReview, original.seriesReview);
      expect(restored.seasonRatings.length, original.seasonRatings.length);
      expect(restored.seasonRatings[0].seasonNumber,
          original.seasonRatings[0].seasonNumber);
      expect(restored.seasonRatings[0].rating,
          original.seasonRatings[0].rating);
      expect(restored.series!.tmdbId, original.series!.tmdbId);
      expect(restored.series!.title, original.series!.title);
      expect(restored.addedAt, original.addedAt);
      expect(restored.lastUpdated, original.lastUpdated);
    });
  });
}
