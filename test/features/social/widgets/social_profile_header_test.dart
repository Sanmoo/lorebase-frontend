import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/data/models/social_profile_model.dart';
import 'package:lorebase/features/social/widgets/social_profile_header.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

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
      TranslationProvider(
        child: MaterialApp(
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
      ),
    );
  }

  testWidgets('renders counts in wrapping layout and edit button variant', (
    tester,
  ) async {
    await pumpHeader(tester, isMe: true, onEdit: () {});

    expect(find.text('Fulano'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.text(t.social_followers_count(count: profile().followerCount)),
      findsOneWidget,
    );
    expect(
      find.text(t.social_following_count(count: profile().followingCount)),
      findsOneWidget,
    );
    expect(find.text(t.social_edit_profile), findsOneWidget);
  });

  testWidgets('calls edit callback', (tester) async {
    var calls = 0;
    await pumpHeader(tester, isMe: true, onEdit: () => calls++);

    await tester.tap(find.text(t.social_edit_profile));

    expect(calls, 1);
  });

  testWidgets('renders follow and unfollow button variants', (tester) async {
    await pumpHeader(tester, onFollow: () {}, onUnfollow: () {});
    expect(find.text(t.social_follow), findsOneWidget);

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () {},
      onUnfollow: () {},
    );
    expect(find.text(t.social_unfollow), findsOneWidget);
  });

  testWidgets('calls follow and unfollow callbacks', (tester) async {
    var followCalls = 0;
    var unfollowCalls = 0;

    await pumpHeader(
      tester,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text(t.social_follow));

    await pumpHeader(
      tester,
      followed: true,
      onFollow: () => followCalls++,
      onUnfollow: () => unfollowCalls++,
    );
    await tester.tap(find.text(t.social_unfollow));

    expect(followCalls, 1);
    expect(unfollowCalls, 1);
  });

  testWidgets('disables follow button when callback is missing', (
    tester,
  ) async {
    await pumpHeader(tester, onUnfollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('disables unfollow button when callback is missing', (
    tester,
  ) async {
    await pumpHeader(tester, followed: true, onFollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
