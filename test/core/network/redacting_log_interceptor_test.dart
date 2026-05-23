import 'package:dio/dio.dart';
import 'package:dio/src/dio_mixin.dart' show InterceptorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/network/redacting_log_interceptor.dart';

class _TestHandler implements RequestInterceptorHandler {
  RequestOptions? capturedOptions;

  @override
  void next(RequestOptions options) {
    capturedOptions = options;
  }

  @override
  void reject(DioException error, [bool? value]) {}

  @override
  void resolve(Response<dynamic> response, [bool? value]) {}

  @override
  Future<InterceptorState<dynamic>> get future =>
      throw UnimplementedError('not used in tests');

  @override
  bool get isCompleted => false;
}

void main() {
  group('redactSensitiveHeaders', () {
    test('redacts sensitive header names case-insensitively', () {
      final headers = <String, dynamic>{
        'authorization': 'Bearer token',
        'Cookie': 'session=value',
        'SET-COOKIE': 'session=value',
        'X-Api-Key': 'secret',
        'API-KEY': 'secret',
        'Proxy-Authorization': 'Basic secret',
        'Accept': 'application/json',
      };

      expect(redactSensitiveHeaders(headers), <String, dynamic>{
        'authorization': '[REDACTED]',
        'Cookie': '[REDACTED]',
        'SET-COOKIE': '[REDACTED]',
        'X-Api-Key': '[REDACTED]',
        'API-KEY': '[REDACTED]',
        'Proxy-Authorization': '[REDACTED]',
        'Accept': 'application/json',
      });
    });

    test('does not mutate the original headers map', () {
      final headers = <String, dynamic>{
        'Authorization': 'Bearer token',
        'Accept': 'application/json',
      };

      final redacted = redactSensitiveHeaders(headers);

      expect(headers['Authorization'], 'Bearer token');
      expect(redacted['Authorization'], '[REDACTED]');
    });
  });

  group('RedactingLogInterceptor', () {
    test('logs redacted request headers while preserving original request', () {
      final logs = <Object>[];
      final interceptor = RedactingLogInterceptor(logPrint: logs.add);
      final handler = _TestHandler();
      final options = RequestOptions(
        path: '/test',
        headers: <String, dynamic>{
          'Authorization': 'Bearer secret',
          'Accept': 'application/json',
        },
      );

      interceptor.onRequest(options, handler);

      final combinedLogs = logs.join('\n');
      expect(combinedLogs, contains('Authorization: [REDACTED]'));
      expect(combinedLogs, isNot(contains('Bearer secret')));
      expect(handler.capturedOptions, same(options));
      expect(options.headers['Authorization'], 'Bearer secret');
    });
  });
}
