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
}
