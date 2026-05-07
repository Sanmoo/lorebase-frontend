import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/season_rating_model.dart';

void main() {
  group('SeasonRatingModel', () {
    const completeJson = {
      'seasonNumber': 1,
      'rating': 5,
      'ratedAt': '2024-01-01T00:00:00.000Z',
    };

    test('fromJson with complete JSON maps all fields correctly', () {
      final model = SeasonRatingModel.fromJson(completeJson);

      expect(model.seasonNumber, 1);
      expect(model.rating, 5);
      expect(model.ratedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('toJson() → fromJson() roundtrip preserves data', () {
      final original = SeasonRatingModel.fromJson(completeJson);
      final json = original.toJson();
      final restored = SeasonRatingModel.fromJson(json);

      expect(restored.seasonNumber, original.seasonNumber);
      expect(restored.rating, original.rating);
      expect(restored.ratedAt, original.ratedAt);
    });
  });
}
