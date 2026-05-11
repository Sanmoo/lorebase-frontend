import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../i18n/locale_provider.dart';

class LocaleInterceptor extends Interceptor {
  final Ref _ref;

  LocaleInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final locale = _ref.read(localeProvider);
    final languageTag = locale.toLanguageTag();
    debugPrint('LocaleInterceptor: Accept-Language = $languageTag');
    options.headers['Accept-Language'] = languageTag;
    handler.next(options);
  }
}
