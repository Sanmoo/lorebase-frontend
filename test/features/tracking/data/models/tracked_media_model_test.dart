import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  final now = DateTime.now().toIso8601String();
  final parsedNow = DateTime.parse(now);

  final json = {
    'trackingId': 'trk-1',
    'userId': 'user-1',
    'mediaType': 'SERIES',
    'mediaId': '42',
    'status': 'WATCHING',
    'rating': 8,
    'review': 'Great',
    'seasonRatings': [
      {'seasonNumber': 1, 'rating': 8, 'ratedAt': now},
    ],
    'media': {
      'mediaId': 42,
      'title': 'Test Show',
      'mediaType': 'SERIES',
    },
    'addedAt': now,
    'lastUpdated': now,
  };

  test('fromJson parses nested media payload', () {
    final model = TrackedMediaModel.fromJson(json);

    expect(model.mediaType.apiValue, 'SERIES');
    expect(model.mediaId, '42');
    expect(model.rating, 8);
    expect(model.review, 'Great');
    expect(model.media!.title, 'Test Show');
  });

  test('fromJson parses seasonRatings', () {
    final model = TrackedMediaModel.fromJson(json);

    expect(model.seasonRatings.length, 1);
    expect(model.seasonRatings.first.seasonNumber, 1);
    expect(model.seasonRatings.first.rating, 8);
  });

  test('fromJson parses addedAt and lastUpdated', () {
    final model = TrackedMediaModel.fromJson(json);

    expect(model.addedAt, parsedNow);
    expect(model.lastUpdated, parsedNow);
  });

  test('fromJson handles null media (no embedded summary)', () {
    final model = TrackedMediaModel.fromJson({
      'trackingId': 'trk-2',
      'userId': 'user-1',
      'mediaType': 'MOVIE',
      'mediaId': '99',
      'status': 'WATCHING',
      'addedAt': now,
      'lastUpdated': now,
    });

    expect(model.media, isNull);
    expect(model.mediaType.apiValue, 'MOVIE');
    expect(model.rating, isNull);
    expect(model.seasonRatings, isEmpty);
  });

  test('toJson fromJson roundtrip without media', () {
    final original = TrackedMediaModel(
      trackingId: 'trk-3',
      userId: 'user-1',
      mediaType: MediaType.movie,
      mediaId: '100',
      status: 'COMPLETED',
      rating: 9,
      review: 'Amazing',
      addedAt: parsedNow,
      lastUpdated: parsedNow,
    );
    final jsonMap = original.toJson();
    final restored = TrackedMediaModel.fromJson(jsonMap);
    expect(restored.trackingId, 'trk-3');
    expect(restored.mediaId, '100');
    expect(restored.status, 'COMPLETED');
    expect(restored.rating, 9);
    expect(restored.review, 'Amazing');
    expect(restored.media, isNull);
  });
}
