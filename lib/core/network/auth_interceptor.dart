import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Integrate with Amplify auth when available
    // For now, allow unauthenticated requests (backend has x-user-id fallback)
    handler.next(options);
  }
}
