import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/data/repositories/auth_repository.dart';

void main() {
  group('AmplifyAuthRepository', () {
    late AmplifyAuthRepository repo;

    setUp(() {
      repo = AmplifyAuthRepository();
    });

    group('signIn', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.signIn('test@test.com', 'password'),
          throwsA(isA<Error>()),
        );
      });
    });

    group('signUp', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.signUp('test@test.com', 'password'),
          throwsA(isA<Error>()),
        );
      });
    });

    group('confirmSignUp', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.confirmSignUp('test@test.com', '123456'),
          throwsA(isA<Error>()),
        );
      });
    });

    group('resendSignUpCode', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.resendSignUpCode('test@test.com'),
          throwsA(isA<Error>()),
        );
      });
    });

    group('resetPassword', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.resetPassword('test@test.com'),
          throwsA(isA<Error>()),
        );
      });
    });

    group('confirmResetPassword', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.confirmResetPassword(
            'test@test.com',
            '123456',
            'newPassword',
          ),
          throwsA(isA<Error>()),
        );
      });
    });

    group('signOut', () {
      test('throws when Amplify is not configured', () async {
        expect(
          () => repo.signOut(),
          throwsA(isA<Error>()),
        );
      });
    });

    group('isAuthenticated', () {
      test('returns false when Amplify is not configured', () async {
        final result = await repo.isAuthenticated();
        expect(result, false);
      });
    });
  });

  group('AuthException', () {
    test('stores message', () {
      const exception = AuthException('test error');
      expect(exception.message, 'test error');
    });

    test('toString returns message', () {
      const exception = AuthException('display message');
      expect(exception.toString(), 'display message');
    });
  });
}
