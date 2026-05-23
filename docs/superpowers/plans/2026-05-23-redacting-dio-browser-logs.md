# Redacting Dio Browser Logs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep Dio request/response logs while ensuring browser logs never print sensitive header values such as bearer tokens or cookies.

**Architecture:** Replace Dio's built-in `LogInterceptor` with a small project-owned `RedactingLogInterceptor`. The interceptor logs request, response, and error metadata while sanitizing headers through a pure, testable redaction helper before any output is emitted.

**Tech Stack:** Flutter/Dart, Dio interceptors, `flutter/foundation.dart` `debugPrint`, `flutter_test`.

---

## File Structure

- Create `lib/core/network/redacting_log_interceptor.dart`
  - Owns sensitive-header detection, header redaction, and sanitized Dio logging.
  - Exposes `redactSensitiveHeaders(Map<String, dynamic> headers)` for direct unit tests.
  - Allows a custom `logPrint` function so tests can capture output without relying on global console hooks.
- Modify `lib/core/network/dio_client.dart`
  - Imports `redacting_log_interceptor.dart`.
  - Replaces Dio `LogInterceptor` with `RedactingLogInterceptor`.
- Create `test/core/network/redacting_log_interceptor_test.dart`
  - Proves sensitive headers are replaced with `[REDACTED]`.
  - Proves case-insensitive matching.
  - Proves interceptor logs never include bearer token or cookie values.

---

### Task 1: Add failing tests for sensitive header redaction

**Files:**
- Create: `test/core/network/redacting_log_interceptor_test.dart`
- Create later: `lib/core/network/redacting_log_interceptor.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/core/network/redacting_log_interceptor_test.dart` with this content:

```dart
import 'package:dio/dio.dart';
import 'package:dio/src/dio_mixin.dart' show InterceptorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/network/redacting_log_interceptor.dart';

class _RequestHandler implements RequestInterceptorHandler {
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

class _ResponseHandler implements ResponseInterceptorHandler {
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

void main() {
  group('redactSensitiveHeaders', () {
    test('redacts authorization cookies and api keys case-insensitively', () {
      final redacted = redactSensitiveHeaders({
        'Authorization': 'Bearer secret-token',
        'cookie': 'session=abc123',
        'Set-Cookie': 'refresh=def456',
        'X-API-Key': 'api-secret',
        'Accept-Language': 'pt-BR',
      });

      expect(redacted['Authorization'], '[REDACTED]');
      expect(redacted['cookie'], '[REDACTED]');
      expect(redacted['Set-Cookie'], '[REDACTED]');
      expect(redacted['X-API-Key'], '[REDACTED]');
      expect(redacted['Accept-Language'], 'pt-BR');
      expect(redacted.values, isNot(contains('Bearer secret-token')));
      expect(redacted.values, isNot(contains('session=abc123')));
      expect(redacted.values, isNot(contains('refresh=def456')));
      expect(redacted.values, isNot(contains('api-secret')));
    });
  });

  group('RedactingLogInterceptor', () {
    test('logs request headers without exposing sensitive values', () {
      final logs = <String>[];
      final interceptor = RedactingLogInterceptor(logPrint: logs.add);
      final options = RequestOptions(
        path: '/tracking',
        method: 'GET',
        headers: {
          'Authorization': 'Bearer browser-token',
          'Cookie': 'session=browser-cookie',
          'Accept': 'application/json',
        },
      );
      final handler = _RequestHandler();

      interceptor.onRequest(options, handler);

      final output = logs.join('\n');
      expect(handler.capturedOptions, same(options));
      expect(output, contains('Authorization: [REDACTED]'));
      expect(output, contains('Cookie: [REDACTED]'));
      expect(output, contains('Accept: application/json'));
      expect(output, isNot(contains('browser-token')));
      expect(output, isNot(contains('browser-cookie')));
    });

    test('logs response headers without exposing set-cookie values', () {
      final logs = <String>[];
      final interceptor = RedactingLogInterceptor(logPrint: logs.add);
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/tracking'),
        statusCode: 200,
        headers: Headers.fromMap({
          'set-cookie': ['refresh=response-cookie'],
          'content-type': ['application/json'],
        }),
        data: {'ok': true},
      );
      final handler = _ResponseHandler();

      interceptor.onResponse(response, handler);

      final output = logs.join('\n');
      expect(handler.capturedResponse, same(response));
      expect(output, contains('set-cookie: [REDACTED]'));
      expect(output, contains('content-type: application/json'));
      expect(output, isNot(contains('response-cookie')));
    });
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail because the implementation is missing**

Run:

```bash
flutter test test/core/network/redacting_log_interceptor_test.dart
```

Expected: FAIL with an import error similar to `Target of URI doesn't exist: 'package:lorebase/core/network/redacting_log_interceptor.dart'`.

- [ ] **Step 3: Commit the failing tests only if the team allows red commits**

Do not commit by default because the repository should remain green between commits. Continue to Task 2.

---

### Task 2: Implement the redacting log interceptor

**Files:**
- Create: `lib/core/network/redacting_log_interceptor.dart`
- Test: `test/core/network/redacting_log_interceptor_test.dart`

- [ ] **Step 1: Create the minimal implementation**

Create `lib/core/network/redacting_log_interceptor.dart` with this content:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _redactedValue = '[REDACTED]';
const _sensitiveHeaderNames = <String>{
  'authorization',
  'cookie',
  'set-cookie',
  'x-api-key',
  'api-key',
  'proxy-authorization',
};

typedef LogPrint = void Function(String message);

Map<String, dynamic> redactSensitiveHeaders(Map<String, dynamic> headers) {
  return headers.map((key, value) {
    final normalizedKey = key.toLowerCase();
    if (_sensitiveHeaderNames.contains(normalizedKey)) {
      return MapEntry(key, _redactedValue);
    }
    return MapEntry(key, value);
  });
}

class RedactingLogInterceptor extends Interceptor {
  RedactingLogInterceptor({LogPrint? logPrint})
      : _logPrint = logPrint ?? debugPrint;

  final LogPrint _logPrint;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _logPrint('--> ${options.method} ${options.uri}');
    _logHeaders(redactSensitiveHeaders(options.headers));
    if (options.data != null) {
      _logPrint('Request body: ${options.data}');
    }
    _logPrint('--> END ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logPrint(
      '<-- ${response.statusCode ?? ''} ${response.requestOptions.uri}',
    );
    _logHeaders(_redactResponseHeaders(response.headers));
    if (response.data != null) {
      _logPrint('Response body: ${response.data}');
    }
    _logPrint('<-- END HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logPrint(
      '<-- ERROR ${err.response?.statusCode ?? ''} ${err.requestOptions.uri}',
    );
    _logHeaders(redactSensitiveHeaders(err.requestOptions.headers));
    if (err.response != null) {
      _logHeaders(_redactResponseHeaders(err.response!.headers));
      if (err.response!.data != null) {
        _logPrint('Error body: ${err.response!.data}');
      }
    }
    _logPrint('<-- END ERROR');
    handler.next(err);
  }

  void _logHeaders(Map<String, dynamic> headers) {
    for (final entry in headers.entries) {
      _logPrint('${entry.key}: ${entry.value}');
    }
  }

  Map<String, dynamic> _redactResponseHeaders(Headers headers) {
    final flattenedHeaders = headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    return redactSensitiveHeaders(flattenedHeaders);
  }
}
```

- [ ] **Step 2: Run the focused tests to verify they pass**

Run:

```bash
flutter test test/core/network/redacting_log_interceptor_test.dart
```

Expected: PASS for all tests in `redacting_log_interceptor_test.dart`.

- [ ] **Step 3: Run formatter**

Run:

```bash
dart format lib/core/network/redacting_log_interceptor.dart test/core/network/redacting_log_interceptor_test.dart
```

Expected: Files formatted with no errors.

---

### Task 3: Wire the sanitized interceptor into DioClient

**Files:**
- Modify: `lib/core/network/dio_client.dart`
- Test: existing tests plus analysis

- [ ] **Step 1: Replace the built-in Dio LogInterceptor**

Modify `lib/core/network/dio_client.dart` so the imports and interceptor list match this content:

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'locale_interceptor.dart';
import 'redacting_log_interceptor.dart';

class DioClient {
  static Dio create(Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      LocaleInterceptor(ref),
      ErrorInterceptor(ref),
      RedactingLogInterceptor(),
    ]);

    return dio;
  }
}
```

- [ ] **Step 2: Run focused network tests**

Run:

```bash
flutter test test/core/network/auth_interceptor_test.dart test/core/network/error_interceptor_test.dart test/core/network/redacting_log_interceptor_test.dart
```

Expected: PASS for all focused network tests.

- [ ] **Step 3: Run LSP diagnostics on changed Dart files**

Run diagnostics for:

```text
lib/core/network/dio_client.dart
test/core/network/redacting_log_interceptor_test.dart
lib/core/network/redacting_log_interceptor.dart
```

Expected: no errors.

---

### Task 4: Verify repository quality gates

**Files:**
- No code changes expected.

- [ ] **Step 1: Run analyzer**

Run:

```bash
make analyze
```

Expected: analyzer exits successfully. If it reports style issues in changed files, fix only those issues and rerun `make analyze`.

- [ ] **Step 2: Run relevant tests**

Run:

```bash
flutter test test/core/network/auth_interceptor_test.dart test/core/network/error_interceptor_test.dart test/core/network/redacting_log_interceptor_test.dart
```

Expected: all tests pass.

- [ ] **Step 3: Check worktree status**

Run:

```bash
git status --short
```

Expected changed files include only:

```text
 M lib/core/network/dio_client.dart
?? lib/core/network/redacting_log_interceptor.dart
?? test/core/network/redacting_log_interceptor_test.dart
?? docs/superpowers/plans/2026-05-23-redacting-dio-browser-logs.md
```

There may also be pre-existing WorkQ changes under `.tasks/`; do not manually edit `.tasks` files and do not mark the task done unless the human explicitly asks.

---

## Self-Review

- Spec coverage: The plan keeps logs enabled, redacts `Authorization`, cookies, `Set-Cookie`, API keys, and proxy authorization, and adds tests proving sensitive values are not printed.
- Placeholder scan: The plan contains complete file paths, code snippets, commands, and expected outcomes.
- Type consistency: `RedactingLogInterceptor`, `LogPrint`, and `redactSensitiveHeaders` are introduced in Task 2 and used consistently in tests and `DioClient`.
