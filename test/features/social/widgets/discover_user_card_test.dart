import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/discover_user_model.dart';
import 'package:lorebase/features/social/data/models/social_media_model.dart';
import 'package:lorebase/features/social/widgets/discover_user_card.dart';

void main() {
  DiscoverUserModel user({bool followed = false}) => DiscoverUserModel(
    userId: 'user-1',
    displayName: 'Maria',
    affinityScore: 0.826,
    commonGenres: const ['Anime', 'Drama'],
    commonMedia: const [
      SocialMediaModel(mediaId: '1', mediaType: 'SERIES', title: 'One Piece'),
    ],
    isFollowedByMe: followed,
  );

  Future<void> pumpCard(
    WidgetTester tester,
    DiscoverUserModel user, {
    VoidCallback? onFollow,
    bool isFollowing = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoverUserCard(
            user: user,
            onFollow: onFollow ?? () {},
            isFollowing: isFollowing,
          ),
        ),
      ),
    );
  }

  testWidgets('renders affinity as percentage', (tester) async {
    await pumpCard(tester, user());

    expect(find.text('83% de afinidade'), findsOneWidget);
  });

  testWidgets('renders common genre chips', (tester) async {
    await pumpCard(tester, user());

    expect(find.text('Anime'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
  });

  testWidgets('follow button invokes onFollow', (tester) async {
    var followed = false;
    await pumpCard(tester, user(), onFollow: () => followed = true);

    await tester.tap(find.text('Seguir'));

    expect(followed, isTrue);
  });

  testWidgets('followed state shows "Seguindo"', (tester) async {
    await pumpCard(tester, user(followed: true));

    expect(find.text('Seguindo'), findsOneWidget);
  });

  testWidgets('follow button shows spinner and disables while following', (
    tester,
  ) async {
    var calls = 0;
    await pumpCard(tester, user(), isFollowing: true, onFollow: () => calls++);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text('Seguir'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Seguindo usuário'), findsOneWidget);

    await tester.tap(find.byType(FilledButton));
    expect(calls, 0);
  });
}
