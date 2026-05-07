import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/register_viewmodel.dart';

void main() {
  group('RegisterState', () {
    group('passwordStrength', () {
      test('returns weak when too short, no upper, no digit (score 0)', () {
        const state = RegisterState(password: 'abc');
        expect(state.passwordStrength, PasswordStrength.weak);
      });

      test('returns weak when only one condition met — length >= 8 (score 1)',
          () {
        const state = RegisterState(password: 'abcdefgh');
        expect(state.passwordStrength, PasswordStrength.weak);
      });

      test('returns weak when only one condition met — has uppercase (score 1)',
          () {
        const state = RegisterState(password: 'Ab');
        expect(state.passwordStrength, PasswordStrength.weak);
      });

      test('returns weak when only one condition met — has digit (score 1)', () {
        const state = RegisterState(password: 'a1');
        expect(state.passwordStrength, PasswordStrength.weak);
      });

      test('returns medium when score is 2 — length + uppercase', () {
        const state = RegisterState(password: 'Abcdefgh');
        expect(state.passwordStrength, PasswordStrength.medium);
      });

      test('returns medium when score is 2 — length + digit', () {
        const state = RegisterState(password: 'abcdefg1');
        expect(state.passwordStrength, PasswordStrength.medium);
      });

      test('returns medium when score is 2 — uppercase + digit', () {
        const state = RegisterState(password: 'A1');
        expect(state.passwordStrength, PasswordStrength.medium);
      });

      test('returns strong when all conditions met — length + uppercase + digit',
          () {
        const state = RegisterState(password: 'Abcdefg1');
        expect(state.passwordStrength, PasswordStrength.strong);
      });
    });

    group('isValid', () {
      test('returns false when terms not accepted', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'Abcdefg1',
          confirmPassword: 'Abcdefg1',
          termsAccepted: false,
        );
        expect(state.isValid, isFalse);
      });

      test('returns false when passwords do not match', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'Abcdefg1',
          confirmPassword: 'Abcdefg2',
          termsAccepted: true,
        );
        expect(state.isValid, isFalse);
      });

      test('returns false when password is weak', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'abc',
          confirmPassword: 'abc',
          termsAccepted: true,
        );
        expect(state.isValid, isFalse);
      });

      test('returns false when email is empty', () {
        const state = RegisterState(
          password: 'Abcdefg1',
          confirmPassword: 'Abcdefg1',
          termsAccepted: true,
        );
        expect(state.isValid, isFalse);
      });

      test('returns false when confirmPassword is empty', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'Abcdefg1',
          termsAccepted: true,
        );
        expect(state.isValid, isFalse);
      });

      test('returns true when all conditions met', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'Abcdefg1',
          confirmPassword: 'Abcdefg1',
          termsAccepted: true,
        );
        expect(state.isValid, isTrue);
      });
    });

    group('copyWith', () {
      test('preserves unspecified fields', () {
        const state = RegisterState(
          email: 'test@email.com',
          password: 'Abcdefg1',
          obscurePassword: false,
          showConfirmation: true,
        );
        final copied = state.copyWith(confirmPassword: 'Abcdefg1');

        expect(copied.email, 'test@email.com');
        expect(copied.password, 'Abcdefg1');
        expect(copied.obscurePassword, isFalse);
        expect(copied.showConfirmation, isTrue);
        expect(copied.confirmPassword, 'Abcdefg1');
      });

      test('clears errorMessage when set to null explicitly', () {
        const state = RegisterState(errorMessage: 'some error');
        expect(state.errorMessage, 'some error');

        final cleared = state.copyWith(errorMessage: null);
        expect(cleared.errorMessage, isNull);
      });

      test('can set confirmationCode via copyWith', () {
        const state = RegisterState();
        final updated = state.copyWith(confirmationCode: '123456');

        expect(updated.confirmationCode, '123456');
      });

      test('can set termsAccepted via copyWith', () {
        const state = RegisterState();
        final updated = state.copyWith(termsAccepted: true);

        expect(updated.termsAccepted, isTrue);
      });
    });
  });
}
