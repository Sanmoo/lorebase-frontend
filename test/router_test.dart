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
        expect(authRedirect(unauthenticated, '/social'), '/login');
        expect(
          authRedirect(unauthenticated, '/social/profile/user-1'),
          '/login',
        );
        expect(
          authRedirect(unauthenticated, '/social/profile/user-1/followers'),
          '/login',
        );
        expect(
          authRedirect(unauthenticated, '/social/profile/user-1/following'),
          '/login',
        );
        expect(authRedirect(unauthenticated, '/series/123'), '/login');
        expect(authRedirect(unauthenticated, '/movies/123'), '/login');
      });
    });

    group('authenticated', () {
      const authenticated = AuthState.authenticated('user1');

      test('stays on protected routes', () {
        expect(authRedirect(authenticated, '/dashboard'), isNull);
        expect(authRedirect(authenticated, '/search'), isNull);
        expect(authRedirect(authenticated, '/tracking'), isNull);
        expect(authRedirect(authenticated, '/recommend'), isNull);
        expect(authRedirect(authenticated, '/social'), isNull);
        expect(authRedirect(authenticated, '/social/profile/user-1'), isNull);
        expect(
          authRedirect(authenticated, '/social/profile/user-1/followers'),
          isNull,
        );
        expect(
          authRedirect(authenticated, '/social/profile/user-1/following'),
          isNull,
        );
        expect(authRedirect(authenticated, '/series/123'), isNull);
        expect(authRedirect(authenticated, '/movies/123'), isNull);
      });

      test('redirects to /dashboard on auth routes', () {
        expect(authRedirect(authenticated, '/login'), '/dashboard');
        expect(authRedirect(authenticated, '/register'), '/dashboard');
        expect(authRedirect(authenticated, '/forgot-password'), '/dashboard');
      });
    });

    group('unknown', () {
      const unknown = AuthState.unknown();

      test('does not redirect protected deep links while auth is loading', () {
        expect(authRedirect(unknown, '/dashboard'), isNull);
        expect(authRedirect(unknown, '/search'), isNull);
        expect(authRedirect(unknown, '/tracking'), isNull);
        expect(authRedirect(unknown, '/social'), isNull);
        expect(authRedirect(unknown, '/recommend'), isNull);
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
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(
            () => _FakeAuthVM(const AuthState.unknown()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });

    test('router redirect redirects unauthenticated to /login', () async {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(
            () => _FakeAuthVM(const AuthState.unauthenticated()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });

    test('social profile route is registered', () {
      final router = _routerForTest();
      final routeMatch = _lastRouteMatch(router, '/social/profile/user-1');

      expect(routeMatch.route.path, '/social/profile/:userId');
    });

    test('social followers route is registered', () {
      final router = _routerForTest();
      final routeMatch = _lastRouteMatch(
        router,
        '/social/profile/user-1/followers',
      );

      expect(routeMatch.route.path, '/social/profile/:userId/followers');
    });

    test('social following route is registered', () {
      final router = _routerForTest();
      final routeMatch = _lastRouteMatch(
        router,
        '/social/profile/user-1/following',
      );

      expect(routeMatch.route.path, '/social/profile/:userId/following');
    });
  });

  group('authRedirect edge cases', () {
    test(
      'unknown with unknown state does not redirect while auth is loading',
      () {
        const unknown = AuthState.unknown();
        expect(authRedirect(unknown, '/unknown'), isNull);
      },
    );

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

GoRouter _routerForTest() {
  final container = ProviderContainer(
    overrides: [
      authViewModelProvider.overrideWith(
        () => _FakeAuthVM(const AuthState.authenticated('user1')),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container.read(routerProvider);
}

RouteMatch _lastRouteMatch(GoRouter router, String path) {
  final matches = router.configuration.findMatch(Uri.parse(path));
  final shellMatch = matches.matches.last as dynamic;
  return shellMatch.matches.last as RouteMatch;
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
