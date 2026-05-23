import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _redactedValue = '[REDACTED]';
const _sensitiveKeyNames = <String>{
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
  'api-key',
  'proxy-authorization',
  'password',
  'token',
  'access-token',
  'accesstoken',
  'refresh-token',
  'refreshtoken',
  'id-token',
  'idtoken',
  'secret',
  'credential',
  'code',
};

typedef RedactingLogPrint = void Function(Object? object);

bool _isSensitiveKey(String key) =>
    _sensitiveKeyNames.contains(key.toLowerCase());

Map<String, dynamic> redactSensitiveHeaders(Map<String, dynamic> headers) {
  return headers.map((key, value) {
    if (_isSensitiveKey(key)) {
      return MapEntry<String, dynamic>(key, _redactedValue);
    }

    return MapEntry<String, dynamic>(key, value);
  });
}

dynamic redactSensitiveData(dynamic data) {
  if (data is Map) {
    return data.map((key, value) {
      final stringKey = key.toString();
      if (_isSensitiveKey(stringKey)) {
        return MapEntry<dynamic, dynamic>(key, _redactedValue);
      }

      return MapEntry<dynamic, dynamic>(key, redactSensitiveData(value));
    });
  }

  if (data is List) {
    return data.map(redactSensitiveData).toList(growable: false);
  }

  return data;
}

Uri redactSensitiveUri(Uri uri) {
  if (uri.queryParametersAll.isEmpty) {
    return uri;
  }

  final redactedQueryParameters = uri.queryParametersAll.map((key, value) {
    if (_isSensitiveKey(key)) {
      return MapEntry<String, Iterable<String>>(key, const [_redactedValue]);
    }

    return MapEntry<String, Iterable<String>>(key, value);
  });

  return uri.replace(queryParameters: redactedQueryParameters);
}

class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor({
    this.request = true,
    this.requestUrl = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseUrl = true,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    RedactingLogPrint? logPrint,
  }) : _logPrint = logPrint ?? ((object) => debugPrint(object?.toString()));

  final bool request;
  final bool requestUrl;
  final bool requestHeader;
  final bool requestBody;
  final bool responseUrl;
  final bool responseHeader;
  final bool responseBody;
  final bool error;
  final RedactingLogPrint _logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (request) {
      _logPrint('--> ${options.method} ${_safeUri(options)}');
    }
    if (requestHeader) {
      _logPrint('Request headers: ${redactSensitiveHeaders(options.headers)}');
    }
    if (requestBody) {
      _logPrint('Request body: ${redactSensitiveData(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (responseUrl) {
      _logPrint(
        '<-- ${response.statusCode} ${_safeUri(response.requestOptions)}',
      );
    }
    if (responseHeader) {
      _logPrint(
        'Response headers: ${redactSensitiveHeaders(response.headers.map)}',
      );
    }
    if (responseBody) {
      _logPrint('Response body: ${redactSensitiveData(response.data)}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      _logPrint(
        '<-- ERROR ${err.response?.statusCode ?? err.type.name} '
        '${_safeUri(err.requestOptions)}',
      );
      _logPrint('Error message: ${err.message}');
      _logPrint(
        'Error request headers: '
        '${redactSensitiveHeaders(err.requestOptions.headers)}',
      );
      final response = err.response;
      if (response != null) {
        _logPrint(
          'Error response headers: '
          '${redactSensitiveHeaders(response.headers.map)}',
        );
        if (responseBody) {
          _logPrint(
            'Error response body: ${redactSensitiveData(response.data)}',
          );
        }
      }
    }
    handler.next(err);
  }

  Uri _safeUri(RequestOptions options) => redactSensitiveUri(options.uri);
}
