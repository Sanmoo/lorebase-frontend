import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/cache/cache_service.dart';
import 'package:lorebase/core/cache/cache_providers.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/data/repositories/auth_repository.dart';

class FakeAuthRepo implements AuthRepository {
  bool authenticated = false;
  bool throwOnIsAuthenticated = false;
  bool signOutCalled = false;
  bool signOutThrows = false;

  @override
  Future<bool> isAuthenticated() async {
    if (throwOnIsAuthenticated) throw Exception('Auth check failed');
    return authenticated;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    if (signOutThrows) throw Exception('Sign out failed');
  }

  @override
  Future<String> signIn(String email, String password) async => 'user-1';

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
}

void main() {
  group('AuthViewModel', () {
    test('build() returns AuthState.unknown', () {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepo()),
      ]);
      addTearDown(container.dispose);

      final state = container.read(authViewModelProvider);
      expect(state, const AuthState.unknown());
    });

    test('_checkAuth sets authenticated when isAuthenticated returns true',
        () async {
      final repo = FakeAuthRepo()..authenticated = true;
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      container.listen(authViewModelProvider, (_, __) {});
      container.read(authViewModelProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, true);
    });

    test('_checkAuth sets unauthenticated when isAuthenticated returns false',
        () async {
      final repo = FakeAuthRepo()..authenticated = false;
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      container.listen(authViewModelProvider, (_, __) {});
      container.read(authViewModelProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
    });

    test('_checkAuth handles isAuthenticated error gracefully', () async {
      final repo = FakeAuthRepo()..throwOnIsAuthenticated = true;
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
      ]);
      addTearDown(container.dispose);

      container.listen(authViewModelProvider, (_, __) {});
      container.read(authViewModelProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('signOut calls repository.signOut', () async {
      final repo = FakeAuthRepo();
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.signOut();

      expect(repo.signOutCalled, true);
    });

    test('signOut sets state to unauthenticated', () async {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepo()),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.signOut();

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('signOut handles repository errors gracefully', () async {
      final repo = FakeAuthRepo()..signOutThrows = true;
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        cacheServiceProvider.overrideWith((ref) => CacheService()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.signOut();

      // Should still set state to unauthenticated
      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(repo.signOutCalled, true);
    });

    test('setAuthenticated updates state with userId', () {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepo()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      notifier.setAuthenticated('user-42');

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, true);
      expect(state.userId, 'user-42');
    });

    test('setUnauthenticated updates state', () {
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => FakeAuthRepo()),
      ]);
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);
      notifier.setAuthenticated('user-1');
      notifier.setUnauthenticated();

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.status, AuthStatus.unauthenticated);
    });
  });

  group('authRepositoryProvider', () {
    test('is a Provider of AuthRepository', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isA<AuthRepository>());
      expect(repo, isA<AmplifyAuthRepository>());
    });
  });
}
