import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/utils/image_url.dart';

void main() {
  test('uses the high-resolution IGDB cover variant', () {
    expect(
      highResolutionIgdbImageUrl(
        'https://images.igdb.com/igdb/image/upload/t_thumb/cob9kr.jpg',
      ),
      'https://images.igdb.com/igdb/image/upload/t_cover_big/cob9kr.jpg',
    );
  });

  test('keeps non-IGDB URLs unchanged', () {
    const url = 'https://images.example.com/t_thumb/cover.jpg';

    expect(highResolutionIgdbImageUrl(url), url);
  });
}
