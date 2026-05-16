import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorebase/features/auth/pages/login_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../helpers/golden_helpers.dart';

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.enUs);

  goldenTest(
    'Login page renders correctly',
    fileName: 'login_page',
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
            child: IgnorePointer(
              child: ProviderScope(
                overrides: loginGoldenOverrides(),
                child: MaterialApp(
                  theme: ThemeData.light(useMaterial3: true),
                  home: const LoginPage(),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'dark_default',
            child: IgnorePointer(
              child: ProviderScope(
                overrides: loginGoldenOverrides(),
                child: MaterialApp(
                  theme: ThemeData.dark(useMaterial3: true),
                  home: const LoginPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
