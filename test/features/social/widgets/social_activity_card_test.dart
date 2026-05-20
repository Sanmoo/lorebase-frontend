import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/activity_event_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/data/models/social_user_model.dart';
import 'package:lorebase/features/social/widgets/social_activity_card.dart';

void main() {
  ActivityEventModel event({
    String type = 'RATED',
    Map<String, dynamic>? metadata,
  }) => ActivityEventModel(
    eventId: 'evt-1',
    user: const SocialUserModel(userId: 'user-1', displayName: 'Fulano'),
    activityType: type,
    media: const SocialMediaModel(
      mediaId: 'media-1',
      mediaType: 'SERIES',
      title: 'One Piece',
    ),
    metadata: metadata ?? const {'rating': 8},
    createdAt: DateTime(2026, 5, 20),
  );

  Future<void> pumpCard(
    WidgetTester tester,
    ActivityEventModel event, {
    VoidCallback? onUserTap,
    VoidCallback? onMediaTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialActivityCard(
            event: event,
            onUserTap: onUserTap ?? () {},
            onMediaTap: onMediaTap ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('RATED renders "avaliou" and rating', (tester) async {
    await pumpCard(tester, event());

    expect(find.textContaining('avaliou'), findsOneWidget);
    expect(find.text('⭐ 8/10'), findsOneWidget);
  });

  testWidgets('renders all activity verbs and review metadata fallbacks', (
    tester,
  ) async {
    for (final entry in {
      'REVIEWED': 'escreveu uma review de',
      'COMPLETED': 'completou',
      'STARTED_WATCHING': 'começou',
      'DROPPED': 'abandonou',
      'ADDED_TO_LIST': 'adicionou à lista',
      'UNKNOWN': 'interagiu com',
    }.entries) {
      await pumpCard(
        tester,
        event(
          type: entry.key,
          metadata: const {'reviewSnippet': 'Gostei bastante'},
        ),
      );

      expect(find.textContaining(entry.value), findsOneWidget);
      expect(find.text('Gostei bastante'), findsOneWidget);
    }
  });

  testWidgets('does not render empty review text', (tester) async {
    await pumpCard(tester, event(metadata: const {'review': ''}));

    expect(find.text(''), findsNothing);
  });

  testWidgets('tapping user invokes onUserTap', (tester) async {
    var tapped = false;
    await pumpCard(tester, event(), onUserTap: () => tapped = true);

    await tester.tap(find.text('Fulano'));

    expect(tapped, isTrue);
  });

  testWidgets('tapping media invokes onMediaTap', (tester) async {
    var tapped = false;
    await pumpCard(tester, event(), onMediaTap: () => tapped = true);

    await tester.tap(find.text('One Piece'));

    expect(tapped, isTrue);
  });
}
