import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('toString includes message and statusCode', () {
      const ex = ServerException(message: 'Oops', statusCode: 500);
      expect(ex.toString(), 'ServerException: Oops (status: 500)');
    });

    test('toString when statusCode is null', () {
      const ex = ServerException(message: 'Oops');
      expect(ex.toString(), 'ServerException: Oops (status: null)');
    });
  });

  group('NetworkException', () {
    test('toString', () {
      const ex = NetworkException(message: 'No connection');
      expect(ex.toString(), 'NetworkException: No connection');
    });
  });

  group('AuthException', () {
    test('toString', () {
      const ex = AuthException(message: 'Unauthorized');
      expect(ex.toString(), 'AuthException: Unauthorized');
    });
  });
}
