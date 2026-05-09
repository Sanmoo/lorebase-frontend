// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/i18n/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'l10n/strings.g.dart';
import 'router.dart';

class LorebaseApp extends ConsumerWidget {
  const LorebaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final localeState = ref.watch(localeProvider);

    return TranslationProvider(
      child: MaterialApp.router(
        title: 'Lorebase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        locale: localeState,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) {
          if (authState.isLoading) {
            return Material(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return child!;
        },
      ),
    );
  }
}
