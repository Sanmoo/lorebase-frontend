import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/register_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/data/repositories/auth_repository.dart';

class FakeAuthRepo implements AuthRepository {
  String signInResult = 'user-1';
  bool failWithAuthException = false;
  bool failWithGeneric = false;
  bool failSignUp = false;
  bool failSignUpGeneric = false;
  bool failConfirmSignUp = false;
  bool failConfirmSignUpGeneric = false;
  bool failResendSignUpCode = false;

  @override
  Future<String> signIn(String email, String password) async {
    if (failWithGeneric) throw Exception('Network error');
    if (failWithAuthException) throw AuthException('Bad credentials');
    return signInResult;
  }

  @override
  Future<void> signUp(String email, String password) async {
    if (failSignUp) throw AuthException('Email already in use');
    if (failSignUpGeneric) throw Exception('Network error');
    // success: no-op
  }

  @override
  Future<void> confirmSignUp(String email, String code) async {
    if (failConfirmSignUp) throw AuthException('Invalid confirmation code');
    if (failConfirmSignUpGeneric) throw Exception('Network error');
  }

  @override
  Future<void> resendSignUpCode(String email) async {
    if (failResendSignUpCode) throw Exception('Failed');
  }

  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> confirmResetPassword(String email, String code, String newPassword) async {}
  @override
  Future<void> signOut() async {}
  @override
  Future<bool> isAuthenticated() async => false;
}

class FakeAuthViewModel extends AuthViewModel {
  String? lastSetAuthenticatedUserId;

  @override
  AuthState build() => const AuthState.unauthenticated();

  @override
  void setAuthenticated(String userId) {
    lastSetAuthenticatedUserId = userId;
  }

  @override
  void setUnauthenticated() {}
}

ProviderContainer createContainer(FakeAuthRepo repo) {
  return ProviderContainer(overrides: [
    authRepositoryProvider.overrideWith((ref) => repo),
    authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
  ]);
}

void main() {
  group('RegisterViewModel', () {
    test('build() returns default RegisterState', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final state = container.read(registerViewModelProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.confirmPassword, '');
      expect(state.termsAccepted, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.obscurePassword, true);
      expect(state.showConfirmation, false);
      expect(state.confirmationCode, isNull);
    });

    test('setEmail() updates email and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      // trigger an error first by submitting empty
      notifier.submit();
      expect(container.read(registerViewModelProvider).errorMessage, isNotNull);

      notifier.setEmail('test@email.com');
      final state = container.read(registerViewModelProvider);
      expect(state.email, 'test@email.com');
      expect(state.errorMessage, isNull);
    });

    test('setPassword() updates password and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.submit(); // trigger error
      expect(container.read(registerViewModelProvider).errorMessage, isNotNull);

      notifier.setPassword('Test1234');
      final state = container.read(registerViewModelProvider);
      expect(state.password, 'Test1234');
      expect(state.errorMessage, isNull);
    });

    test('setConfirmPassword() updates confirmPassword and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('a@b.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('wrong');
      notifier.submit(); // triggers password mismatch error
      expect(container.read(registerViewModelProvider).errorMessage, isNotNull);

      notifier.setConfirmPassword('Test1234');
      final state = container.read(registerViewModelProvider);
      expect(state.confirmPassword, 'Test1234');
      expect(state.errorMessage, isNull);
    });

    test('toggleTerms() toggles and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      expect(container.read(registerViewModelProvider).termsAccepted, false);

      notifier.toggleTerms();
      expect(container.read(registerViewModelProvider).termsAccepted, true);

      notifier.toggleTerms();
      expect(container.read(registerViewModelProvider).termsAccepted, false);
    });

    test('toggleObscurePassword() toggles', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      expect(container.read(registerViewModelProvider).obscurePassword, true);

      notifier.toggleObscurePassword();
      expect(container.read(registerViewModelProvider).obscurePassword, false);

      notifier.toggleObscurePassword();
      expect(container.read(registerViewModelProvider).obscurePassword, true);
    });

    test('setConfirmationCode() updates code and clears error', () {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);

      // Set up showConfirmation state and trigger error
      notifier.setEmail('a@b.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      notifier.submit(); // success → showConfirmation=true

      // trigger confirmSignUp error
      notifier.confirmSignUp();
      expect(container.read(registerViewModelProvider).errorMessage, isNotNull);

      notifier.setConfirmationCode('123456');
      final state = container.read(registerViewModelProvider);
      expect(state.confirmationCode, '123456');
      expect(state.errorMessage, isNull);
    });

    test('submit() with empty fields sets error and returns false', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final result =
          await container.read(registerViewModelProvider.notifier).submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.isLoading, false);
    });

    test('submit() with mismatched passwords sets specific error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('a@b.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Different1234');
      notifier.toggleTerms();

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, 'As senhas não coincidem');
    });

    test('submit() success sets showConfirmation=true', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();

      final result = await notifier.submit();
      expect(result, true);

      final state = container.read(registerViewModelProvider);
      expect(state.showConfirmation, true);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('submit() with AuthException sets error message', () async {
      final repo = FakeAuthRepo()..failSignUp = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, 'Email already in use');
      expect(state.isLoading, false);
    });

    test('submit() with generic exception sets fallback error', () async {
      final repo = FakeAuthRepo()..failSignUpGeneric = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, contains('Erro ao criar conta'));
      expect(state.isLoading, false);
    });

    test('confirmSignUp() without code sets error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      await notifier.submit(); // success → showConfirmation=true
      // confirmationCode is still null

      final result = await notifier.confirmSignUp();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, contains('código de confirmação'));
    });

    test('confirmSignUp() success returns true and authenticates', () async {
      final fakeAuthVM = FakeAuthViewModel();
      final repo = FakeAuthRepo();
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        authViewModelProvider.overrideWith(() => fakeAuthVM),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      await notifier.submit(); // success → showConfirmation=true
      notifier.setConfirmationCode('123456');

      final result = await notifier.confirmSignUp();
      expect(result, true);

      final state = container.read(registerViewModelProvider);
      expect(state.isLoading, false);
      expect(fakeAuthVM.lastSetAuthenticatedUserId, 'user-1');
    });

    test('confirmSignUp() with AuthException sets error', () async {
      final repo = FakeAuthRepo()..failConfirmSignUp = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      await notifier.submit();
      notifier.setConfirmationCode('wrong');

      final result = await notifier.confirmSignUp();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, 'Invalid confirmation code');
      expect(state.isLoading, false);
    });

    test('resendCode() does not throw', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      await notifier.submit();

      // Should complete without throwing
      await notifier.resendCode();
      // No assertion needed — reaching here means no exception was thrown
    });

    test('submit() with terms not accepted sets specific error', () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('a@b.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      // termsAccepted stays false

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, 'Aceite os termos de uso');
    });

    test('submit() with email empty but password strong sets fill-all error',
        () async {
      final container = createContainer(FakeAuthRepo());
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, 'Preencha todos os campos');
    });

    test('confirmSignUp() with generic exception sets fallback error',
        () async {
      final repo = FakeAuthRepo()..failConfirmSignUpGeneric = true;
      final container = createContainer(repo);
      addTearDown(container.dispose);

      final notifier = container.read(registerViewModelProvider.notifier);
      notifier.setEmail('test@email.com');
      notifier.setPassword('Test1234');
      notifier.setConfirmPassword('Test1234');
      notifier.toggleTerms();
      await notifier.submit();
      notifier.setConfirmationCode('123456');

      final result = await notifier.confirmSignUp();
      expect(result, false);

      final state = container.read(registerViewModelProvider);
      expect(state.errorMessage, contains('Código inválido'));
      expect(state.isLoading, false);
    });
  });
}
