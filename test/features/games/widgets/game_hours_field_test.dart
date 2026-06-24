import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/games/widgets/game_hours_field.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  testWidgets('renders label and initial hours', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: GameHoursField(hours: 12.5, onChanged: (_) {})),
        ),
      ),
    );

    expect(find.text('Hours Played'), findsOneWidget);
    expect(find.text('12.5'), findsOneWidget);
  });

  testWidgets('forwards parsed double on change', (tester) async {
    double? changed;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GameHoursField(onChanged: (value) => changed = value),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '42.5');
    await tester.pump();

    expect(changed, 42.5);
  });

  testWidgets('forwards null for invalid input', (tester) async {
    double? changed;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: GameHoursField(onChanged: (value) => changed = value),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();

    expect(changed, isNull);
  });

  testWidgets('uses decimal keyboard', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: GameHoursField(onChanged: (_) {})),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
  });
}
