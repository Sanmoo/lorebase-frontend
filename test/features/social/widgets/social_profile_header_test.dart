import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/widgets/social_profile_header.dart';

void main() {
  SocialProfileModel profile({bool followed = false}) => SocialProfileModel(
    userId: 'user-1',
    displayName: 'Fulano',
    isPublic: true,
    followingCount: 3,
    followerCount: 7,
    isFollowedByMe: followed,
    createdAt: DateTime(2026, 5, 20),
    updatedAt: DateTime(2026, 5, 20),
  );

  Future<void> pumpHeader(
    WidgetTester tester, {
    bool isMe = false,
    bool followed = false,
    VoidCallback? onFollow,
    VoidCallback? onUnfollow,
    VoidCallback? onEdit,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialProfileHeader(
            profile: profile(followed: followed),
            isMe: isMe,
            onFollow: onFollow,
            onUnfollow: onUnfollow,
            onEdit: onEdit,
          ),
        ),
      ),
    );
  }

  testWidgets('renders counts in wrapping layout and edit button variant', (
    tester,
  ) async {
    await pumpHeader(tester, isMe: true, onEdit: () {});

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.text('7 seguidores'), findsOneWidget);
    expect(find.text('3 seguindo'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
  });

  testWidgets('calls edit callback', (tester) async {
    var calls = 0;
    await pumpHeader(tester, isMe: true, onEdit: () => calls++);

    await tester.tap(find.text('Editar perfil'));

    expect(calls, 1);
  });

  testWidgets('renders follow and unfollow button variants', (tester) async {
    await pumpHeader(tester, onFollow: () {}, onUnfollow: () {});
    expect(find.text('Seguir'), findsOneWidget);

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () {},
      onUnfollow: () {},
    );
    expect(find.text('Deixar de seguir'), findsOneWidget);
  });

  testWidgets('calls follow and unfollow callbacks', (tester) async {
    var followCalls = 0;
    var unfollowCalls = 0;

    await pumpHeader(
      tester,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text('Seguir'));

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text('Deixar de seguir'));

    expect(followCalls, 1);
    expect(unfollowCalls, 1);
  });

  testWidgets('disables follow button when callback is missing', (tester) async {
    await pumpHeader(tester, onUnfollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('disables unfollow button when callback is missing', (tester) async {
    await pumpHeader(tester, followed: true, onFollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
