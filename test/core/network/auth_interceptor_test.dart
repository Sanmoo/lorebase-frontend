import 'package:dio/dio.dart';
import 'package:dio/src/dio_mixin.dart' show InterceptorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/network/auth_interceptor.dart';

class _TestHandler implements RequestInterceptorHandler {
  RequestOptions? capturedOptions;
  bool isRejected = false;

  @override
  void next(RequestOptions options) {
    capturedOptions = options;
  }

  @override
  void reject(DioException error, [bool? value]) {
    isRejected = true;
  }

  @override
  void resolve(Response<dynamic> response, [bool? value]) {}

  @override
  Future<InterceptorState<dynamic>> get future =>
      throw UnimplementedError('not used in tests');

  @override
  bool get isCompleted => false;
}

void main() {
  group('AuthInterceptor', () {
    late AuthInterceptor interceptor;
    late _TestHandler handler;
    late RequestOptions options;

    setUp(() {
      interceptor = AuthInterceptor();
      handler = _TestHandler();
      options = RequestOptions(path: '/test');
    });

    test('onRequest calls handler.next() even when Amplify throws', () async {
      interceptor.onRequest(options, handler);
      // Flush microtasks to allow the async void method to complete
      await null;

      expect(handler.capturedOptions, isNotNull);
      expect(handler.capturedOptions!.path, '/test');
      expect(handler.isRejected, isFalse);
    });

    test('Authorization header is absent when Amplify not configured',
        () async {
      interceptor.onRequest(options, handler);
      await null;

      expect(handler.capturedOptions, isNotNull);
      expect(
        handler.capturedOptions!.headers.containsKey('Authorization'),
        isFalse,
      );
    });
  });
}
