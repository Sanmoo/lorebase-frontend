import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        final token = session.userPoolTokensResult.value.accessToken.raw;
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Allow request to proceed without auth header
    }
    handler.next(options);
  }
}
