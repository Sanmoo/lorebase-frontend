import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/forgot_password_viewmodel.dart';

void main() {
  group('ForgotPasswordState', () {
    group('canRequestCode', () {
      test('returns true when email is not empty', () {
        const state = ForgotPasswordState(email: 'test@email.com');
        expect(state.canRequestCode, isTrue);
      });

      test('returns false when email is empty (default)', () {
        const state = ForgotPasswordState();
        expect(state.canRequestCode, isFalse);
      });

      test('returns false when email is empty string explicitly', () {
        const state = ForgotPasswordState(email: '');
        expect(state.canRequestCode, isFalse);
      });
    });

    group('canResetPassword', () {
      test('returns false when code is empty', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          newPassword: 'Abcdefg1',
          confirmPassword: 'Abcdefg1',
        );
        expect(state.canResetPassword, isFalse);
      });

      test('returns false when newPassword is empty', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          code: '123456',
          confirmPassword: 'Abcdefg1',
        );
        expect(state.canResetPassword, isFalse);
      });

      test('returns false when confirmPassword is empty', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          code: '123456',
          newPassword: 'Abcdefg1',
        );
        expect(state.canResetPassword, isFalse);
      });

      test('returns false when passwords do not match', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          code: '123456',
          newPassword: 'Abcdefg1',
          confirmPassword: 'Different',
        );
        expect(state.canResetPassword, isFalse);
      });

      test('returns true when all fields filled and passwords match', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          code: '123456',
          newPassword: 'Abcdefg1',
          confirmPassword: 'Abcdefg1',
        );
        expect(state.canResetPassword, isTrue);
      });
    });

    group('copyWith', () {
      test('preserves unspecified fields', () {
        const state = ForgotPasswordState(
          email: 'test@email.com',
          phase: ForgotPasswordPhase.resetPassword,
          obscurePassword: false,
        );
        final copied = state.copyWith(code: '123456');

        expect(copied.email, 'test@email.com');
        expect(copied.phase, ForgotPasswordPhase.resetPassword);
        expect(copied.obscurePassword, isFalse);
        expect(copied.code, '123456');
      });

      test('clears errorMessage when set to null explicitly', () {
        const state = ForgotPasswordState(errorMessage: 'some error');
        expect(state.errorMessage, 'some error');

        final cleared = state.copyWith(errorMessage: null);
        expect(cleared.errorMessage, isNull);
      });

      test('can change phase via copyWith', () {
        const state = ForgotPasswordState();
        final updated =
            state.copyWith(phase: ForgotPasswordPhase.resetPassword);

        expect(updated.phase, ForgotPasswordPhase.resetPassword);
      });

      test('returns new instance when no arguments provided', () {
        const state = ForgotPasswordState(email: 'test@email.com');
        final copied = state.copyWith();

        expect(identical(state, copied), isFalse);
        expect(copied.email, state.email);
        expect(copied.phase, state.phase);
      });
    });
  });
}
