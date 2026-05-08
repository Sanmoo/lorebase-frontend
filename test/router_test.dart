import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/router.dart';

void main() {
  group('authRedirect', () {
    group('unauthenticated', () {
      const unauthenticated = AuthState.unauthenticated();

      test('stays on auth routes', () {
        expect(authRedirect(unauthenticated, '/login'), isNull);
        expect(authRedirect(unauthenticated, '/register'), isNull);
        expect(authRedirect(unauthenticated, '/forgot-password'), isNull);
      });

      test('redirects to /login on protected routes', () {
        expect(authRedirect(unauthenticated, '/dashboard'), '/login');
        expect(authRedirect(unauthenticated, '/search'), '/login');
        expect(authRedirect(unauthenticated, '/tracking'), '/login');
        expect(authRedirect(unauthenticated, '/recommend'), '/login');
        expect(authRedirect(unauthenticated, '/series/123'), '/login');
      });
    });

    group('authenticated', () {
      const authenticated = AuthState.authenticated('user1');

      test('stays on protected routes', () {
        expect(authRedirect(authenticated, '/dashboard'), isNull);
        expect(authRedirect(authenticated, '/search'), isNull);
        expect(authRedirect(authenticated, '/tracking'), isNull);
        expect(authRedirect(authenticated, '/recommend'), isNull);
        expect(authRedirect(authenticated, '/series/123'), isNull);
      });

      test('redirects to /dashboard on auth routes', () {
        expect(authRedirect(authenticated, '/login'), '/dashboard');
        expect(authRedirect(authenticated, '/register'), '/dashboard');
        expect(authRedirect(authenticated, '/forgot-password'), '/dashboard');
      });
    });

    group('unknown', () {
      const unknown = AuthState.unknown();

      test('redirects to /login on protected routes', () {
        expect(authRedirect(unknown, '/dashboard'), '/login');
        expect(authRedirect(unknown, '/search'), '/login');
      });

      test('stays on auth routes', () {
        expect(authRedirect(unknown, '/login'), isNull);
        expect(authRedirect(unknown, '/register'), isNull);
        expect(authRedirect(unknown, '/forgot-password'), isNull);
      });
    });
  });

  group('routerProvider', () {
    test('creates GoRouter with initialLocation /login', () {
      final container = ProviderContainer(overrides: [
        authViewModelProvider.overrideWith(
          () => _FakeAuthVM(const AuthState.unknown()),
        ),
      ]);
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });

    test('router redirect redirects unauthenticated to /login', () async {
      final container = ProviderContainer(overrides: [
        authViewModelProvider.overrideWith(
          () => _FakeAuthVM(const AuthState.unauthenticated()),
        ),
      ]);
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });
  });

  group('authRedirect edge cases', () {
    test('unknown with unknown state redirects to login', () {
      const unknown = AuthState.unknown();
      expect(authRedirect(unknown, '/unknown'), '/login');
    });

    test('authenticated on unknown non-auth route stays', () {
      const authenticated = AuthState.authenticated('user1');
      expect(authRedirect(authenticated, '/unknown'), isNull);
    });

    test('unauthenticated on root returns /login', () {
      const unauthenticated = AuthState.unauthenticated();
      expect(authRedirect(unauthenticated, '/'), '/login');
    });

    test('authenticated on root stays', () {
      const authenticated = AuthState.authenticated('user1');
      expect(authRedirect(authenticated, '/'), isNull);
    });
  });
}

class _FakeAuthVM extends AuthViewModel {
  final AuthState authState;
  _FakeAuthVM(this.authState);

  @override
  AuthState build() => authState;

  @override
  void setAuthenticated(String userId) {}

  @override
  void setUnauthenticated() {}

  @override
  Future<void> signOut() async {}
}
