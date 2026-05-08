import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/data/repositories/auth_repository.dart';

class FakeAuthRepo implements AuthRepository {
  String signInResult = 'user-1';
  bool failWithAuthException = false;
  bool failWithGeneric = false;

  @override
  Future<String> signIn(String email, String password) async {
    if (failWithAuthException) throw const AuthException('Bad credentials');
    if (failWithGeneric) throw Exception('Network error');
    return signInResult;
  }

  @override
  Future<void> signUp(String email, String password) async {}

  @override
  Future<void> confirmSignUp(String email, String code) async {}

  @override
  Future<void> resendSignUpCode(String email) async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> confirmResetPassword(
      String email, String code, String newPassword) async {}

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

void main() {
  group('LoginViewModel', () {
    test('build() returns default LoginState', () {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(loginViewModelProvider);
      expect(state.email, '');
      expect(state.password, '');
      expect(state.isValid, false);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.obscurePassword, true);
    });

    test('setEmail() updates email and clears error', () {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Set an error first
      notifier.setEmail('');
      notifier.setPassword('');
      notifier.submit(); // triggers validation error
      expect(
        container.read(loginViewModelProvider).errorMessage,
        isNotNull,
      );

      // setEmail should clear the error
      notifier.setEmail('test@email.com');
      final state = container.read(loginViewModelProvider);
      expect(state.email, 'test@email.com');
      expect(state.errorMessage, isNull);
    });

    test('setPassword() updates password and clears error', () {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Set an error first
      notifier.setEmail('');
      notifier.setPassword('');
      notifier.submit(); // triggers validation error
      expect(
        container.read(loginViewModelProvider).errorMessage,
        isNotNull,
      );

      // setPassword should clear the error
      notifier.setPassword('123456');
      final state = container.read(loginViewModelProvider);
      expect(state.password, '123456');
      expect(state.errorMessage, isNull);
    });

    test('toggleObscurePassword() toggles from true to false and back', () {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Default is true
      expect(container.read(loginViewModelProvider).obscurePassword, true);

      // Toggle to false
      notifier.toggleObscurePassword();
      expect(container.read(loginViewModelProvider).obscurePassword, false);

      // Toggle back to true
      notifier.toggleObscurePassword();
      expect(container.read(loginViewModelProvider).obscurePassword, true);
    });

    test('submit() with empty fields sets error and returns false', () async {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(loginViewModelProvider);
      expect(state.errorMessage, 'Preencha e-mail e senha');
      expect(state.isLoading, false);
    });

    test('submit() success transitions isLoading and returns true', () async {
      final repo = FakeAuthRepo();
      final fakeAuthVM = FakeAuthViewModel();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => fakeAuthVM),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Set valid fields
      notifier.setEmail('test@email.com');
      notifier.setPassword('123456');

      final result = await notifier.submit();
      expect(result, true);

      final state = container.read(loginViewModelProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      // Verify setAuthenticated was called with the correct userId
      expect(fakeAuthVM.lastSetAuthenticatedUserId, 'user-1');
    });

    test('submit() with AuthException sets error message', () async {
      final repo = FakeAuthRepo()..failWithAuthException = true;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Set valid fields
      notifier.setEmail('test@email.com');
      notifier.setPassword('123456');

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(loginViewModelProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Bad credentials');
    });

    test('submit() with generic exception sets fallback error', () async {
      final repo = FakeAuthRepo()..failWithGeneric = true;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => repo),
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(loginViewModelProvider.notifier);

      // Set valid fields
      notifier.setEmail('test@email.com');
      notifier.setPassword('123456');

      final result = await notifier.submit();
      expect(result, false);

      final state = container.read(loginViewModelProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'E-mail ou senha incorretos');
    });
  });
}
