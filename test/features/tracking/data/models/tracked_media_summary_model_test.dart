import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';

void main() {
  const json = {
    'tmdbId': 10,
    'title': 'The Batman',
    'mediaType': 'movie',
    'posterPath': '/poster.jpg',
    'backdropPath': '/backdrop.jpg',
  };

  test('fromJson parses summary payload', () {
    final model = TrackedMediaSummaryModel.fromJson(json);

    expect(model.tmdbId, 10);
    expect(model.title, 'The Batman');
    expect(model.mediaType.apiValue, 'movie');
    expect(model.posterPath, '/poster.jpg');
  });
}
