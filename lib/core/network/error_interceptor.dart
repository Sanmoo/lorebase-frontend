import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  final Ref _ref;

  ErrorInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        err = err.copyWith(
          error: const NetworkException(message: 'Connection timeout. Please try again.'),
        );
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          err = err.copyWith(
            error: const AuthException(message: 'Session expired. Please log in again.'),
          );
        } else if (statusCode != null && statusCode >= 500) {
          err = err.copyWith(
            error: const ServerException(message: 'Server error. Please try again later.'),
          );
        } else if (statusCode == 404) {
          err = err.copyWith(
            error: const ServerException(message: 'Resource not found.', statusCode: 404),
          );
        }
        break;
      default:
        err = err.copyWith(
          error: const NetworkException(message: 'Network error. Check your connection.'),
        );
    }
    handler.next(err);
  }
}
