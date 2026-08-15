import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/tracking/data/models/media_type.dart';
import 'package:lorebase/features/tracking/data/models/tracked_media_summary_model.dart';
import 'package:lorebase/features/tracking/widgets/tracked_media_poster.dart';

void main() {
  testWidgets('shows tracked media title', (tester) async {
    const media = TrackedMediaSummaryModel(
      mediaId: '1',
      title: 'Movie Title',
      mediaType: MediaType.movie,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrackedMediaPoster(media: media)),
      ),
    );

    expect(find.text('Movie Title'), findsOneWidget);
  });

  testWidgets('uses the high-resolution IGDB cover for games', (tester) async {
    const media = TrackedMediaSummaryModel(
      mediaId: 'game-1',
      title: 'Game Title',
      mediaType: MediaType.game,
      posterPath:
          'https://images.igdb.com/igdb/image/upload/t_thumb/cob9kr.jpg',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TrackedMediaPoster(media: media)),
      ),
    );

    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      'https://images.igdb.com/igdb/image/upload/t_cover_big/cob9kr.jpg',
    );
  });
}
