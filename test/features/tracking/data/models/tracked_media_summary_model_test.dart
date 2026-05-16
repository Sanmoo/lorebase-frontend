import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';

void main() {
  test('fromJson parses summary payload with tmdbId as int (API shape)', () {
    final model = TrackedMediaSummaryModel.fromJson(const {
      'tmdbId': 10,
      'title': 'The Batman',
      'mediaType': 'MOVIE',
      'posterPath': '/poster.jpg',
    });

    expect(model.mediaId, '10');
    expect(model.title, 'The Batman');
    expect(model.mediaType!.apiValue, 'MOVIE');
    expect(model.posterPath, '/poster.jpg');
  });

  test('fromJson handles missing mediaType', () {
    final model = TrackedMediaSummaryModel.fromJson(const {
      'tmdbId': 42,
      'title': 'Test Show',
    });

    expect(model.mediaId, '42');
    expect(model.title, 'Test Show');
    expect(model.mediaType, isNull);
  });

  test('fromJson defaults mediaId to empty string when tmdbId is absent', () {
    final model = TrackedMediaSummaryModel.fromJson(const {
      'title': 'No ID Show',
    });

    expect(model.mediaId, '');
    expect(model.title, 'No ID Show');
  });

  test('toJson fromJson roundtrip', () {
    const original = TrackedMediaSummaryModel(
      mediaId: '10',
      title: 'The Batman',
      mediaType: MediaType.movie,
      posterPath: '/poster.jpg',
    );
    final jsonMap = original.toJson();
    final restored = TrackedMediaSummaryModel.fromJson(jsonMap);
    expect(restored.mediaId, '10');
    expect(restored.title, 'The Batman');
    expect(restored.mediaType!.apiValue, 'MOVIE');
  });

  test('toJson fromJson roundtrip with null mediaType', () {
    const original = TrackedMediaSummaryModel(
      mediaId: '42',
      title: 'Test Show',
    );
    final jsonMap = original.toJson();
    final restored = TrackedMediaSummaryModel.fromJson(jsonMap);
    expect(restored.mediaId, '42');
    expect(restored.title, 'Test Show');
    expect(restored.mediaType, isNull);
  });

  test('fromJson throws FormatException for invalid mediaType type', () {
    expect(
      () => TrackedMediaSummaryModel.fromJson(const {
        'tmdbId': 1,
        'title': 'Test',
        'mediaType': 123,
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
