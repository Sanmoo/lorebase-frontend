import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_follow_button.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

  Future<void> pumpButton(
    WidgetTester tester, {
    required bool isFollowedByMe,
    VoidCallback? onFollow,
    VoidCallback? onUnfollow,
    bool isLoading = false,
  }) {
    return tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SocialFollowButton(
              isFollowedByMe: isFollowedByMe,
              onFollow: onFollow,
              onUnfollow: onUnfollow,
              isLoading: isLoading,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('calls follow callback when not followed', (tester) async {
    var calls = 0;

    await pumpButton(
      tester,
      isFollowedByMe: false,
      onFollow: () => calls++,
      onUnfollow: () {},
    );

    expect(find.text(t.social_follow), findsOneWidget);
    await tester.tap(find.text(t.social_follow));

    expect(calls, 1);
  });

  testWidgets('calls unfollow callback when followed', (tester) async {
    var calls = 0;

    await pumpButton(
      tester,
      isFollowedByMe: true,
      onFollow: () {},
      onUnfollow: () => calls++,
    );

    expect(find.text(t.social_unfollow), findsOneWidget);
    await tester.tap(find.text(t.social_unfollow));

    expect(calls, 1);
  });

  testWidgets('disables missing callback', (tester) async {
    await pumpButton(tester, isFollowedByMe: false, onUnfollow: () {});

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows spinner and disables while loading', (tester) async {
    await pumpButton(
      tester,
      isFollowedByMe: false,
      onFollow: () {},
      onUnfollow: () {},
      isLoading: true,
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.text(t.social_follow), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.bySemanticsLabel(t.social_follow_updating_semantics),
      findsOneWidget,
    );
  });
}
