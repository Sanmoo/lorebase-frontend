import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';

void main() {
  group('LoginState', () {
    group('default state', () {
      test('email is empty', () {
        const state = LoginState();
        expect(state.email, isEmpty);
      });

      test('password is empty', () {
        const state = LoginState();
        expect(state.password, isEmpty);
      });

      test('isValid is false', () {
        const state = LoginState();
        expect(state.isValid, isFalse);
      });

      test('obscurePassword is true', () {
        const state = LoginState();
        expect(state.obscurePassword, isTrue);
      });

      test('isLoading is false', () {
        const state = LoginState();
        expect(state.isLoading, isFalse);
      });

      test('errorMessage is null', () {
        const state = LoginState();
        expect(state.errorMessage, isNull);
      });
    });

    group('isValid', () {
      test('returns true when both email and password are non-empty', () {
        const state = LoginState(email: 'test@email.com', password: '123456');
        expect(state.isValid, isTrue);
      });

      test('returns false when email is empty', () {
        const state = LoginState(password: '123456');
        expect(state.isValid, isFalse);
      });

      test('returns false when password is empty', () {
        const state = LoginState(email: 'test@email.com');
        expect(state.isValid, isFalse);
      });

      test('returns false when both are empty', () {
        const state = LoginState();
        expect(state.isValid, isFalse);
      });
    });

    group('copyWith', () {
      test('preserves unspecified fields', () {
        const state = LoginState(
          email: 'test@email.com',
          obscurePassword: false,
          isLoading: true,
        );
        final copied = state.copyWith(password: '123456');

        expect(copied.email, 'test@email.com');
        expect(copied.obscurePassword, isFalse);
        expect(copied.isLoading, isTrue);
        expect(copied.password, '123456');
      });

      test('clears errorMessage when set to null explicitly', () {
        const state = LoginState(errorMessage: 'some error');
        expect(state.errorMessage, 'some error');

        final cleared = state.copyWith(errorMessage: null);
        expect(cleared.errorMessage, isNull);
      });

      test('returns new instance when no arguments provided', () {
        const state = LoginState(
          email: 'test@email.com',
          password: '123456',
        );
        final copied = state.copyWith();

        expect(identical(state, copied), isFalse);
        expect(copied.email, state.email);
        expect(copied.password, state.password);
      });
    });
  });
}
