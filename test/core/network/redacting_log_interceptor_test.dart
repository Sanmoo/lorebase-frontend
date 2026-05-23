import 'package:dio/dio.dart';
import 'package:dio/src/dio_mixin.dart' show InterceptorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/network/redacting_log_interceptor.dart';

class _TestRequestHandler implements RequestInterceptorHandler {
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

class _TestResponseHandler implements ResponseInterceptorHandler {
  Response<dynamic>? capturedResponse;

  @override
  void next(Response<dynamic> response) {
    capturedResponse = response;
  }

  @override
  void reject(DioException error, [bool? value]) {}

  @override
  void resolve(Response<dynamic> response) {}

  @override
  Future<InterceptorState<dynamic>> get future =>
      throw UnimplementedError('not used in tests');

  @override
  bool get isCompleted => false;
}

class _TestErrorHandler implements ErrorInterceptorHandler {
  DioException? capturedError;

  @override
  void next(DioException error) {
    capturedError = error;
  }

  @override
  void reject(DioException error) {}

  @override
  void resolve(Response<dynamic> response) {}

  @override
  Future<InterceptorState<dynamic>> get future =>
      throw UnimplementedError('not used in tests');

  @override
  bool get isCompleted => false;
}

void main() {
  group('redaction helpers', () {
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

    test('redacts sensitive body keys recursively case-insensitively', () {
      final body = <String, dynamic>{
        'password': 'pass',
        'accessToken': 'access',
        'nested': <String, dynamic>{
          'Refresh-Token': 'refresh',
          'items': [
            <String, dynamic>{'idToken': 'id', 'name': 'public'},
          ],
        },
      };

      final redacted = redactSensitiveData(body) as Map<dynamic, dynamic>;

      expect(redacted['password'], '[REDACTED]');
      expect(redacted['accessToken'], '[REDACTED]');
      expect(
        (redacted['nested'] as Map<dynamic, dynamic>)['Refresh-Token'],
        '[REDACTED]',
      );
      expect(
        (((redacted['nested'] as Map<dynamic, dynamic>)['items'] as List).single
            as Map<dynamic, dynamic>)['idToken'],
        '[REDACTED]',
      );
      expect(body['password'], 'pass');
    });

    test('redacts sensitive URL query parameters case-insensitively', () {
      final uri = Uri.parse(
        'https://example.test/path?code=abc&TOKEN=secret&search=public',
      );

      final redacted = redactSensitiveUri(uri).toString();

      expect(redacted, contains('code=%5BREDACTED%5D'));
      expect(redacted, contains('TOKEN=%5BREDACTED%5D'));
      expect(redacted, contains('search=public'));
      expect(redacted, isNot(contains('abc')));
      expect(redacted, isNot(contains('secret')));
    });
  });

  group('RedactingLogInterceptor', () {
    test(
      'logs redacted request URL, headers, and body without mutating request',
      () {
        final logs = <Object?>[];
        final interceptor = RedactingLogInterceptor(
          enabled: true,
          requestBody: true,
          logPrint: logs.add,
        );
        final handler = _TestRequestHandler();
        final body = <String, dynamic>{
          'password': 'secret-pass',
          'access_token': 'snake-access-secret',
          'client_secret': 'snake-client-secret',
          'id_token': 'snake-id-secret',
        };
        final options = RequestOptions(
          path:
              '/test?refresh_token=snake-refresh-secret&access_token='
              'snake-query-access-secret&name=public',
          headers: <String, dynamic>{
            'Authorization': 'Bearer secret',
            'Cookie': 'session=value',
            'Accept': 'application/json',
          },
          data: body,
        );

        interceptor.onRequest(options, handler);

        final combinedLogs = logs.join('\n');
        expect(combinedLogs, contains('Authorization: [REDACTED]'));
        expect(combinedLogs, contains('Cookie: [REDACTED]'));
        expect(combinedLogs, contains('password: [REDACTED]'));
        expect(combinedLogs, contains('access_token: [REDACTED]'));
        expect(combinedLogs, contains('client_secret: [REDACTED]'));
        expect(combinedLogs, contains('id_token: [REDACTED]'));
        expect(combinedLogs, contains('refresh_token=%5BREDACTED%5D'));
        expect(combinedLogs, contains('access_token=%5BREDACTED%5D'));
        expect(combinedLogs, contains('name=public'));
        expect(combinedLogs, isNot(contains('Bearer secret')));
        expect(combinedLogs, isNot(contains('session=value')));
        expect(combinedLogs, isNot(contains('secret-pass')));
        expect(combinedLogs, isNot(contains('snake-access-secret')));
        expect(combinedLogs, isNot(contains('snake-client-secret')));
        expect(combinedLogs, isNot(contains('snake-id-secret')));
        expect(combinedLogs, isNot(contains('snake-refresh-secret')));
        expect(combinedLogs, isNot(contains('snake-query-access-secret')));
        expect(handler.capturedOptions, same(options));
        expect(options.headers['Authorization'], 'Bearer secret');
        expect(options.headers['Cookie'], 'session=value');
        expect(body['password'], 'secret-pass');
        expect(body['access_token'], 'snake-access-secret');
        expect(body['id_token'], 'snake-id-secret');
      },
    );

    test(
      'logs redacted response headers and body without mutating response',
      () {
        final logs = <Object?>[];
        final interceptor = RedactingLogInterceptor(
          enabled: true,
          responseBody: true,
          logPrint: logs.add,
        );
        final handler = _TestResponseHandler();
        final requestOptions = RequestOptions(path: '/test');
        final data = <String, dynamic>{'refreshToken': 'refresh-secret'};
        final response = Response<dynamic>(
          requestOptions: requestOptions,
          data: data,
          headers: Headers.fromMap(<String, List<String>>{
            'set-cookie': ['session=value'],
            'content-type': ['application/json'],
          }),
          statusCode: 200,
        );

        interceptor.onResponse(response, handler);

        final combinedLogs = logs.join('\n');
        expect(combinedLogs, contains('set-cookie: [REDACTED]'));
        expect(combinedLogs, contains('content-type: application/json'));
        expect(
          combinedLogs,
          isNot(contains('content-type: [application/json]')),
        );
        expect(combinedLogs, contains('refreshToken: [REDACTED]'));
        expect(combinedLogs, isNot(contains('session=value')));
        expect(combinedLogs, isNot(contains('refresh-secret')));
        expect(handler.capturedResponse, same(response));
        expect(response.headers.value('set-cookie'), 'session=value');
        expect(data['refreshToken'], 'refresh-secret');
      },
    );

    test('does not log when disabled but still forwards requests', () {
      final logs = <Object?>[];
      final interceptor = RedactingLogInterceptor(
        enabled: false,
        requestBody: true,
        responseBody: true,
        logPrint: logs.add,
      );
      final handler = _TestRequestHandler();
      final options = RequestOptions(
        path: '/test?token=query-secret',
        data: <String, dynamic>{'password': 'secret'},
      );

      interceptor.onRequest(options, handler);

      expect(logs, isEmpty);
      expect(handler.capturedOptions, same(options));
    });

    test(
      'logs redacted error request and response metadata without mutating error',
      () {
        final logs = <Object?>[];
        final interceptor = RedactingLogInterceptor(
          enabled: true,
          responseBody: true,
          logPrint: logs.add,
        );
        final handler = _TestErrorHandler();
        final requestOptions = RequestOptions(
          path: '/test?code=code-secret',
          headers: <String, dynamic>{
            'X-Api-Key': 'key-secret',
            'Accept': 'application/json',
          },
        );
        final responseData = <String, dynamic>{'secret': 'body-secret'};
        final response = Response<dynamic>(
          requestOptions: requestOptions,
          data: responseData,
          headers: Headers.fromMap(<String, List<String>>{
            'set-cookie': ['session=value'],
          }),
          statusCode: 401,
        );
        final error = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'failed with token raw-error-secret',
        );

        interceptor.onError(error, handler);

        final combinedLogs = logs.join('\n');
        expect(combinedLogs, contains('X-Api-Key: [REDACTED]'));
        expect(combinedLogs, contains('set-cookie: [REDACTED]'));
        expect(combinedLogs, contains('secret: [REDACTED]'));
        expect(combinedLogs, isNot(contains('key-secret')));
        expect(combinedLogs, isNot(contains('session=value')));
        expect(combinedLogs, contains('badResponse'));
        expect(combinedLogs, isNot(contains('body-secret')));
        expect(combinedLogs, isNot(contains('code-secret')));
        expect(combinedLogs, isNot(contains('raw-error-secret')));
        expect(handler.capturedError, same(error));
        expect(requestOptions.headers['X-Api-Key'], 'key-secret');
        expect(response.headers.value('set-cookie'), 'session=value');
        expect(responseData['secret'], 'body-secret');
      },
    );
  });
}
