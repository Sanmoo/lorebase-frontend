import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/widgets/error_widget.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  Widget wrap(Widget child) {
    return TranslationProvider(
      child: MaterialApp(
        locale: AppLocale.enUs.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(body: child),
      ),
    );
  }

  group('AppErrorWidget', () {
    testWidgets('shows error message', (tester) async {
      await tester.pumpWidget(
        wrap(const AppErrorWidget(message: 'Something broke')),
      );
      expect(find.text('Something broke'), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AppErrorWidget(message: 'Error')));
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        wrap(AppErrorWidget(message: 'Error', onRetry: () {})),
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button calls onRetry when tapped', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(AppErrorWidget(message: 'Error', onRetry: () => retried = true)),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });
  });
}
