import 'dart:io';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/movies/pages/movie_detail_page.dart';
import 'package:lorebase/l10n/strings.g.dart';

import '../helpers/golden_helpers.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.setLocale(AppLocale.enUs);

  // Mock path_provider for CachedNetworkImage usage.
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getTemporaryDirectory':
        return Directory.systemTemp.path;
      case 'getApplicationSupportDirectory':
        return Directory.systemTemp.path;
      default:
        return null;
    }
  });

  goldenTest(
    'Movie detail page renders correctly',
    fileName: 'movie_detail_page',
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
                overrides: movieDetailGoldenOverrides(),
                child: MaterialApp(
                  theme: ThemeData.light(useMaterial3: true),
                  home: const MovieDetailPage(tmdbId: 7),
                ),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'dark_default',
            child: IgnorePointer(
              child: ProviderScope(
                overrides: movieDetailGoldenOverrides(),
                child: MaterialApp(
                  theme: ThemeData.dark(useMaterial3: true),
                  home: const MovieDetailPage(tmdbId: 7),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
