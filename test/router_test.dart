import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
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
}
