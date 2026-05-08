import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('default message is "Server error occurred"', () {
      const failure = ServerFailure();
      expect(failure.message, 'Server error occurred');
    });

    test('custom message overrides default', () {
      const failure = ServerFailure('Custom server error');
      expect(failure.message, 'Custom server error');
    });
  });

  group('NetworkFailure', () {
    test('default message is "Network error. Check your connection."', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Network error. Check your connection.');
    });

    test('custom message overrides default', () {
      const failure = NetworkFailure('Custom network error');
      expect(failure.message, 'Custom network error');
    });
  });

  group('AuthFailure', () {
    test('default message is "Authentication failed"', () {
      const failure = AuthFailure();
      expect(failure.message, 'Authentication failed');
    });

    test('custom message overrides default', () {
      const failure = AuthFailure('Custom auth error');
      expect(failure.message, 'Custom auth error');
    });
  });

  group('Failure hierarchy', () {
    test('ServerFailure is a Failure', () {
      const failure = ServerFailure();
      expect(failure, isA<Failure>());
    });

    test('NetworkFailure is a Failure', () {
      const failure = NetworkFailure();
      expect(failure, isA<Failure>());
    });

    test('AuthFailure is a Failure', () {
      const failure = AuthFailure();
      expect(failure, isA<Failure>());
    });
  });

  group('Runtime construction', () {
    test('ServerFailure runtime', () {
      // ignore: prefer_const_constructors
      final failure = ServerFailure();
      expect(failure.message, 'Server error occurred');
    });

    test('ServerFailure runtime with custom message', () {
      // ignore: prefer_const_constructors
      final failure = ServerFailure('Custom');
      expect(failure.message, 'Custom');
    });

    test('NetworkFailure runtime', () {
      // ignore: prefer_const_constructors
      final failure = NetworkFailure();
      expect(failure.message, 'Network error. Check your connection.');
    });

    test('AuthFailure runtime', () {
      // ignore: prefer_const_constructors
      final failure = AuthFailure();
      expect(failure.message, 'Authentication failed');
    });
  });
}
