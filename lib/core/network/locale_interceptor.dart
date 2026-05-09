import 'package:dio/dio.dart';
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
    options.headers['Accept-Language'] = locale.toLanguageTag();
    handler.next(options);
  }
}
