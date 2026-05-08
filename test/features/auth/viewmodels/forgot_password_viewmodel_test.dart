import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/forgot_password_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/data/repositories/auth_repository.dart';

class FakeAuthRepo implements AuthRepository {
  bool failResetPassword = false;
  bool failConfirmResetPassword = false;
  bool failWithGeneric = false;

  @override
  Future<String> signIn(String email, String password) async => 'user-1';
  @override
  Future<void> signUp(String email, String password) async {}
  @override
  Future<void> confirmSignUp(String email, String code) async {}
  @override
  Future<void> resendSignUpCode(String email) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> resetPassword(String email) async {
    if (failResetPassword) throw const AuthException('Email not found');
    if (failWithGeneric) throw Exception('Network error');
  }

  @override
  Future<void> confirmResetPassword(
      String email, String code, String newPassword) async {
    if (failConfirmResetPassword) throw const AuthException('Invalid code');
    if (failWithGeneric) throw Exception('Network error');
  }
}

void main() {
  group('ForgotPasswordViewModel', () {
    ProviderContainer createContainer(FakeAuthRepo repo) {
      return ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
      ]);
    }

    test('build() default state (phase=requestCode)', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.email, '');
      expect(state.code, '');
      expect(state.newPassword, '');
      expect(state.confirmPassword, '');
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.phase, ForgotPasswordPhase.requestCode);
      expect(state.obscurePassword, true);
    });

    test('setEmail() updates email and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.requestCode(); // triggers validation error
      expect(
        container.read(forgotPasswordViewModelProvider).errorMessage,
        isNotNull,
      );

      notifier.setEmail('test@email.com');
      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.email, 'test@email.com');
      expect(state.errorMessage, isNull);
    });

    test('setCode() updates code and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      // Move to resetPassword phase
      notifier.setEmail('test@email.com');
      notifier.requestCode();

      notifier.resetPassword(); // triggers validation error (empty code)
      expect(
        container.read(forgotPasswordViewModelProvider).errorMessage,
        isNotNull,
      );

      notifier.setCode('123456');
      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.code, '123456');
      expect(state.errorMessage, isNull);
    });

    test('setNewPassword() updates password and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.requestCode();

      notifier.resetPassword(); // triggers error
      expect(
        container.read(forgotPasswordViewModelProvider).errorMessage,
        isNotNull,
      );

      notifier.setNewPassword('NewPass1');
      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.newPassword, 'NewPass1');
      expect(state.errorMessage, isNull);
    });

    test('setConfirmPassword() updates confirmPassword and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.requestCode();
      notifier.setCode('123456');
      notifier.setNewPassword('NewPass1');
      notifier.setConfirmPassword('wrong');
      notifier.resetPassword(); // triggers mismatch error
      expect(
        container.read(forgotPasswordViewModelProvider).errorMessage,
        isNotNull,
      );

      notifier.setConfirmPassword('NewPass1');
      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.confirmPassword, 'NewPass1');
      expect(state.errorMessage, isNull);
    });

    test('toggleObscurePassword() toggles', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      expect(
        container.read(forgotPasswordViewModelProvider).obscurePassword,
        true,
      );

      notifier.toggleObscurePassword();
      expect(
        container.read(forgotPasswordViewModelProvider).obscurePassword,
        false,
      );

      notifier.toggleObscurePassword();
      expect(
        container.read(forgotPasswordViewModelProvider).obscurePassword,
        true,
      );
    });

    test('requestCode() with empty email sets error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final result = await container
          .read(forgotPasswordViewModelProvider.notifier)
          .requestCode();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, contains('e-mail'));
    });

    test('requestCode() success changes phase to resetPassword', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');

      final result = await notifier.requestCode();
      expect(result, true);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.phase, ForgotPasswordPhase.resetPassword);
      expect(state.isLoading, false);
    });

    test('requestCode() with AuthException sets error', () async {
      final repo = FakeAuthRepo()..failResetPassword = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('notfound@email.com');

      final result = await notifier.requestCode();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, 'Email not found');
      expect(state.isLoading, false);
    });

    test('requestCode() with generic exception sets fallback error', () async {
      final repo = FakeAuthRepo()..failWithGeneric = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');

      final result = await notifier.requestCode();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, contains('Erro ao enviar código'));
      expect(state.isLoading, false);
    });

    test('resetPassword() with mismatched passwords sets error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      await notifier.requestCode(); // → phase=resetPassword
      notifier.setCode('123456');
      notifier.setNewPassword('NewPass1');
      notifier.setConfirmPassword('Different1');

      final result = await notifier.resetPassword();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, 'As senhas não coincidem');
    });

    test('resetPassword() with empty fields sets error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      await notifier.requestCode();
      // code, newPassword, confirmPassword are all empty

      final result = await notifier.resetPassword();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, contains('Preencha todos'));
    });

    test('resetPassword() success returns true', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      await notifier.requestCode();
      notifier.setCode('123456');
      notifier.setNewPassword('NewPass1');
      notifier.setConfirmPassword('NewPass1');

      final result = await notifier.resetPassword();
      expect(result, true);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.isLoading, false);
    });

    test('resetPassword() with AuthException sets error', () async {
      final repo = FakeAuthRepo()..failConfirmResetPassword = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      await notifier.requestCode();
      notifier.setCode('wrong');
      notifier.setNewPassword('NewPass1');
      notifier.setConfirmPassword('NewPass1');

      final result = await notifier.resetPassword();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, 'Invalid code');
      expect(state.isLoading, false);
    });

    test('resetPassword() with generic exception sets fallback error',
        () async {
      final repo = FakeAuthRepo()..failWithGeneric = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier =
          container.read(forgotPasswordViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      await notifier.requestCode();
      notifier.setCode('123456');
      notifier.setNewPassword('NewPass1');
      notifier.setConfirmPassword('NewPass1');

      final result = await notifier.resetPassword();
      expect(result, false);

      final state = container.read(forgotPasswordViewModelProvider);
      expect(state.errorMessage, contains('Erro ao redefinir senha'));
      expect(state.isLoading, false);
    });
  });
}

class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
  @override
  void setAuthenticated(String userId) {}
  @override
  void setUnauthenticated() {}
}
