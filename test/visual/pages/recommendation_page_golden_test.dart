import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:lorebase/features/recommendation/pages/recommendation_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Recommendation page renders correctly',
    fileName: 'recommendation_page',
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
            child: MaterialApp(
              theme: ThemeData.light(useMaterial3: true),
              home: const RecommendationPage(),
            ),
          ),
          GoldenTestScenario(
            name: 'dark_default',
            child: MaterialApp(
              theme: ThemeData.dark(useMaterial3: true),
              home: const RecommendationPage(),
            ),
          ),
        ],
      ),
    ),
  );
}
