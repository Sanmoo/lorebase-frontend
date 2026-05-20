import 'package:dio/dio.dart';
import 'package:dio/src/dio_mixin.dart' show InterceptorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';
import 'package:lorebase/core/network/error_interceptor.dart';

class _TestHandler implements ErrorInterceptorHandler {
  DioException? capturedError;
  bool isRejected = false;

  @override
  void next(DioException e) {
    capturedError = e;
  }

  @override
  void reject(DioException e) {
    isRejected = true;
    capturedError = e;
  }

  @override
  void resolve(Response<dynamic> response) {}

  ErrorInterceptorHandler get linted => this;

  @override
  Future<InterceptorState<dynamic>> get future =>
      throw UnimplementedError('not used in tests');

  @override
  bool get isCompleted => false;
}

DioException _createDioException(
  DioExceptionType type, {
  int? statusCode,
  String message = '',
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    type: type,
    message: message,
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          )
        : null,
  );
}

void main() {
  late ErrorInterceptor interceptor;
  late _TestHandler handler;

  setUp(() {
    interceptor = ErrorInterceptor();
    handler = _TestHandler();
  });

  group('ErrorInterceptor', () {
    test(
      'connectionTimeout wraps as NetworkException with timeout message',
      () {
        final err = _createDioException(DioExceptionType.connectionTimeout);
        interceptor.onError(err, handler);

        expect(handler.isRejected, isFalse);
        expect(handler.capturedError, isNotNull);
        expect(handler.capturedError!.error, isA<NetworkException>());
        expect(
          (handler.capturedError!.error as NetworkException).message,
          'Connection timeout. Please try again.',
        );
      },
    );

    test('sendTimeout wraps as NetworkException with timeout message', () {
      final err = _createDioException(DioExceptionType.sendTimeout);
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<NetworkException>());
      expect(
        (handler.capturedError!.error as NetworkException).message,
        'Connection timeout. Please try again.',
      );
    });

    test('receiveTimeout wraps as NetworkException with timeout message', () {
      final err = _createDioException(DioExceptionType.receiveTimeout);
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<NetworkException>());
      expect(
        (handler.capturedError!.error as NetworkException).message,
        'Connection timeout. Please try again.',
      );
    });

    test('connectionError wraps as NetworkException with timeout message', () {
      final err = _createDioException(DioExceptionType.connectionError);
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<NetworkException>());
      expect(
        (handler.capturedError!.error as NetworkException).message,
        'Connection timeout. Please try again.',
      );
    });

    test(
      'badResponse with status 401 wraps as AuthException session expired',
      () {
        final err = _createDioException(
          DioExceptionType.badResponse,
          statusCode: 401,
        );
        interceptor.onError(err, handler);

        expect(handler.isRejected, isFalse);
        expect(handler.capturedError, isNotNull);
        expect(handler.capturedError!.error, isA<AuthException>());
        expect(
          (handler.capturedError!.error as AuthException).message,
          'Session expired. Please log in again.',
        );
      },
    );

    test('badResponse with status 500 wraps as ServerException', () {
      final err = _createDioException(
        DioExceptionType.badResponse,
        statusCode: 500,
      );
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<ServerException>());
      expect(
        (handler.capturedError!.error as ServerException).message,
        'Server error. Please try again later.',
      );
    });

    test('badResponse with status 502 wraps as ServerException', () {
      final err = _createDioException(
        DioExceptionType.badResponse,
        statusCode: 502,
      );
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<ServerException>());
      expect(
        (handler.capturedError!.error as ServerException).message,
        'Server error. Please try again later.',
      );
    });

    test(
      'badResponse with status 404 wraps as ServerException with statusCode 404',
      () {
        final err = _createDioException(
          DioExceptionType.badResponse,
          statusCode: 404,
        );
        interceptor.onError(err, handler);

        expect(handler.isRejected, isFalse);
        expect(handler.capturedError, isNotNull);
        expect(handler.capturedError!.error, isA<ServerException>());
        final serverEx = handler.capturedError!.error as ServerException;
        expect(serverEx.message, 'Resource not found.');
        expect(serverEx.statusCode, 404);
      },
    );

    test(
      'default/unhandled type wraps as NetworkException generic message',
      () {
        final err = _createDioException(DioExceptionType.cancel);
        interceptor.onError(err, handler);

        expect(handler.isRejected, isFalse);
        expect(handler.capturedError, isNotNull);
        expect(handler.capturedError!.error, isA<NetworkException>());
        expect(
          (handler.capturedError!.error as NetworkException).message,
          'Network error. Check your connection.',
        );
      },
    );

    test('handler always calls handler.next() not reject', () {
      final err = _createDioException(DioExceptionType.connectionTimeout);
      interceptor.onError(err, handler);

      expect(handler.isRejected, isFalse);
      // Verify capturedError is set (proof that next was called)
      expect(handler.capturedError, isNotNull);
      expect(handler.capturedError!.error, isA<NetworkException>());
    });
  });
}
