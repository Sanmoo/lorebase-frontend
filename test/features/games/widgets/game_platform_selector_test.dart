import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/widgets/game_platform_selector.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('renders available platforms and forwards selection', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GamePlatformSelector(
              platforms: const ['PC', 'PS5', 'Switch'],
              selectedPlatform: 'PS5',
              labelText: 'Platform',
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Platform'), findsOneWidget);
    expect(find.text('PS5'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('PC').last, findsOneWidget);
    expect(find.text('Switch').last, findsOneWidget);

    await tester.tap(find.text('PC').last);
    await tester.pumpAndSettle();

    expect(selected, 'PC');
  });

  testWidgets('handles empty platforms list', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GamePlatformSelector(
              platforms: const [],
              onChanged: (_) {},
              labelText: 'Platform',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DropdownMenuItem<String>), findsNothing);
  });

  testWidgets('falls back to other label for unknown platform', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GamePlatformSelector(
              platforms: const ['Unknown Console'],
              selectedPlatform: 'Unknown Console',
              labelText: 'Platform',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Other'), findsOneWidget);
  });
}
