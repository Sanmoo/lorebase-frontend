import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
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
      if (session.isSignedIn && session is CognitoAuthSession) {
        final cognitoSession = session;
        final token = cognitoSession.userPoolTokensResult.value.accessToken.raw;
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Allow request to proceed without auth header
    }
    handler.next(options);
  }
}
