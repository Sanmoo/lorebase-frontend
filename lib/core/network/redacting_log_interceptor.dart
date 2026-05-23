import 'package:dio/dio.dart';

const _redactedValue = '[REDACTED]';
const _sensitiveHeaderNames = <String>{
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
  'api-key',
  'proxy-authorization',
};

Map<String, dynamic> redactSensitiveHeaders(Map<String, dynamic> headers) {
  return headers.map((key, value) {
    if (_sensitiveHeaderNames.contains(key.toLowerCase())) {
      return MapEntry<String, dynamic>(key, _redactedValue);
    }

    return MapEntry<String, dynamic>(key, value);
  });
}

class RedactingLogInterceptor extends LogInterceptor {
  RedactingLogInterceptor({
    super.request,
    super.requestUrl,
    super.requestHeader,
    super.requestBody,
    super.responseUrl,
    super.responseHeader,
    super.responseBody,
    super.error,
    super.logPrint,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final redactedOptions = options.copyWith(
      headers: redactSensitiveHeaders(options.headers),
    );

    super.onRequest(redactedOptions, RequestInterceptorHandler());
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    super.onResponse(_redactResponse(response), ResponseInterceptorHandler());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final redactedError = response == null
        ? err
        : err.copyWith(response: _redactResponse(response));

    super.onError(redactedError, ErrorInterceptorHandler());
    handler.next(err);
  }

  Response<dynamic> _redactResponse(Response<dynamic> response) {
    return Response<dynamic>(
      data: response.data,
      headers: Headers.fromMap(
        redactSensitiveHeaders(response.headers.map).map(
          (key, value) => MapEntry(
            key,
            value is List<String> ? value : <String>[value.toString()],
          ),
        ),
        preserveHeaderCase: response.headers.preserveHeaderCase,
      ),
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      isRedirect: response.isRedirect,
      redirects: response.redirects,
      extra: response.extra,
    );
  }
}
