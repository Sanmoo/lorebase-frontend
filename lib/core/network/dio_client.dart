import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'locale_interceptor.dart';
import 'redacting_log_interceptor.dart';

class DioClient {
  static Dio create(Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      LocaleInterceptor(ref),
      ErrorInterceptor(ref),
      RedactingLogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}
