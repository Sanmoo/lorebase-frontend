import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/social/widgets/social_follow_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required bool isFollowedByMe,
    VoidCallback? onFollow,
    VoidCallback? onUnfollow,
    bool isLoading = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialFollowButton(
            isFollowedByMe: isFollowedByMe,
            onFollow: onFollow,
            onUnfollow: onUnfollow,
            isLoading: isLoading,
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

    expect(find.text('Seguir'), findsOneWidget);
    await tester.tap(find.text('Seguir'));

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

    expect(find.text('Deixar de seguir'), findsOneWidget);
    await tester.tap(find.text('Deixar de seguir'));

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
    expect(find.text('Seguir'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.bySemanticsLabel('Atualizando seguir'), findsOneWidget);
  });
}
