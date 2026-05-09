import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/strings.g.dart';
import '../providers/core_providers.dart';

const _localeStorageKey = 'locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return _localeFromPlatform();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final saved = await storage.read(key: _localeStorageKey);
      if (saved != null) {
        final parts = saved.split('_');
        final locale = parts.length == 2
            ? Locale(parts[0], parts[1])
            : Locale(parts[0]);
        state = locale;
        _syncLocaleSettings(locale);
      }
    } catch (_) {}
  }

  Locale _localeFromPlatform() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    const supported = [
      Locale('pt', 'BR'),
      Locale('en', 'US'),
      Locale('es'),
    ];
    for (final locale in supported) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }
    return const Locale('pt', 'BR');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    _syncLocaleSettings(locale);
    try {
      final storage = ref.read(secureStorageProvider);
      final value = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await storage.write(key: _localeStorageKey, value: value);
    } catch (_) {}
  }

  void _syncLocaleSettings(Locale locale) {
    if (locale.languageCode == 'pt') {
      LocaleSettings.setLocale(AppLocale.ptBr);
    } else if (locale.languageCode == 'es') {
      LocaleSettings.setLocale(AppLocale.es);
    } else {
      LocaleSettings.setLocale(AppLocale.enUs);
    }
  }
}
