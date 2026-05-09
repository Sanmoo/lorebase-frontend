import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        if (parts.length == 2) {
          state = Locale(parts[0], parts[1]);
        } else {
          state = Locale(parts[0]);
        }
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
    try {
      final storage = ref.read(secureStorageProvider);
      final value = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await storage.write(key: _localeStorageKey, value: value);
    } catch (_) {}
  }
}
