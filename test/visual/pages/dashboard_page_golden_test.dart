import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/dashboard/pages/dashboard_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Dashboard page renders correctly with data',
    fileName: 'dashboard_page',
    constraints: BoxConstraints.loose(const Size(800, 600)),
    builder: () => TranslationProvider(
      child: GoldenTestGroup(
        columnWidthBuilder: (_) => const FixedColumnWidth(400),
        scenarioConstraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        children: [
          GoldenTestScenario(
            name: 'light_default',
            child: ProviderScope(
              overrides: dashboardGoldenOverrides(),
              child: MaterialApp(
                theme: ThemeData.light(useMaterial3: true),
                home: const DashboardPage(),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'dark_default',
            child: ProviderScope(
              overrides: dashboardGoldenOverrides(),
              child: MaterialApp(
                theme: ThemeData.dark(useMaterial3: true),
                home: const DashboardPage(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
