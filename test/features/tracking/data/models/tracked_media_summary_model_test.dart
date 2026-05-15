import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';

void main() {
  const json = {
    'mediaId': '10',
    'title': 'The Batman',
    'mediaType': 'movie',
    'posterPath': '/poster.jpg',
  };

  test('fromJson parses summary payload', () {
    final model = TrackedMediaSummaryModel.fromJson(json);

    expect(model.mediaId, '10');
    expect(model.title, 'The Batman');
    expect(model.mediaType.apiValue, 'movie');
    expect(model.posterPath, '/poster.jpg');
  });

  test('toJson fromJson roundtrip', () {
    final original = TrackedMediaSummaryModel.fromJson(const {
      'mediaId': '10',
      'title': 'The Batman',
      'mediaType': 'movie',
      'posterPath': '/poster.jpg',
    });
    final jsonMap = original.toJson();
    final restored = TrackedMediaSummaryModel.fromJson(jsonMap);
    expect(restored.mediaId, '10');
    expect(restored.title, 'The Batman');
  });
}
