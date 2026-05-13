import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_model.dart';

void main() {
  final now = DateTime.now().toIso8601String();

  final json = {
    'trackingId': 'trk-1',
    'userId': 'user-1',
    'mediaType': 'series',
    'mediaId': '42',
    'status': 'WATCHING',
    'rating': 8,
    'review': 'Great',
    'seasonRatings': [
      {'seasonNumber': 1, 'rating': 8, 'ratedAt': now},
    ],
    'media': {
      'tmdbId': 42,
      'title': 'Test Show',
      'mediaType': 'series',
    },
    'addedAt': now,
    'lastUpdated': now,
  };

  test('fromJson parses nested media payload', () {
    final model = TrackedMediaModel.fromJson(json);

    expect(model.mediaType.apiValue, 'series');
    expect(model.mediaId, '42');
    expect(model.rating, 8);
    expect(model.review, 'Great');
    expect(model.media!.title, 'Test Show');
  });
}
