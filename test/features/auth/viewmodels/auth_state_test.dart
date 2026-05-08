import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

void main() {
  group('AuthState', () {
    group('unknown', () {
      test('isLoading is true', () {
        const state = AuthState.unknown();
        expect(state.isLoading, isTrue);
      });

      test('isAuthenticated is false', () {
        const state = AuthState.unknown();
        expect(state.isAuthenticated, isFalse);
      });

      test('status is AuthStatus.unknown', () {
        const state = AuthState.unknown();
        expect(state.status, AuthStatus.unknown);
      });
    });

    group('authenticated', () {
      test('isLoading is false', () {
        const state = AuthState.authenticated('id123');
        expect(state.isLoading, isFalse);
      });

      test('isAuthenticated is true', () {
        const state = AuthState.authenticated('id123');
        expect(state.isAuthenticated, isTrue);
      });

      test('userId is set', () {
        const state = AuthState.authenticated('id123');
        expect(state.userId, 'id123');
      });

      test('status is AuthStatus.authenticated', () {
        const state = AuthState.authenticated('id123');
        expect(state.status, AuthStatus.authenticated);
      });
    });

    group('unauthenticated', () {
      test('isLoading is false', () {
        const state = AuthState.unauthenticated();
        expect(state.isLoading, isFalse);
      });

      test('isAuthenticated is false', () {
        const state = AuthState.unauthenticated();
        expect(state.isAuthenticated, isFalse);
      });

      test('status is AuthStatus.unauthenticated', () {
        const state = AuthState.unauthenticated();
        expect(state.status, AuthStatus.unauthenticated);
      });

      test('userId is null', () {
        const state = AuthState.unauthenticated();
        expect(state.userId, isNull);
      });
    });

    group('copyWith', () {
      test('preserves unspecified fields when changing status', () {
        const state = AuthState.authenticated('id123');
        final copied = state.copyWith(status: AuthStatus.unauthenticated);

        expect(copied.status, AuthStatus.unauthenticated);
        expect(copied.userId, 'id123');
      });

      test('preserves unspecified fields when changing errorMessage', () {
        const state = AuthState.authenticated('id123');
        final copied = state.copyWith(errorMessage: 'session expired');

        expect(copied.status, AuthStatus.authenticated);
        expect(copied.userId, 'id123');
        expect(copied.errorMessage, 'session expired');
      });

      test('clears errorMessage when set to null explicitly', () {
        const original = AuthState.unknown();
        final withError = original.copyWith(errorMessage: 'some error');
        expect(withError.errorMessage, 'some error');

        final cleared = withError.copyWith(errorMessage: null);
        expect(cleared.errorMessage, isNull);
      });

      test('returns new instance when no arguments provided', () {
        const state = AuthState.authenticated('id123');
        final copied = state.copyWith();

        expect(identical(state, copied), isFalse);
        expect(copied.status, state.status);
        expect(copied.userId, state.userId);
      });

      test('clears errorMessage when not provided', () {
        const state = AuthState.unauthenticated();
        final copied = state.copyWith(
          status: AuthStatus.authenticated,
        );
        expect(copied.errorMessage, isNull);
      });

      test('copyWith with userId overrides', () {
        const state = AuthState.unauthenticated();
        final copied = state.copyWith(userId: 'new-id');
        expect(copied.userId, 'new-id');
      });
    });

    group('runtime (non-const) construction', () {
      test('authenticated constructor works at runtime', () {
        // ignore: prefer_const_constructors
        final state = AuthState.authenticated('runtime-user');
        expect(state.userId, 'runtime-user');
        expect(state.isAuthenticated, true);
      });

      test('unauthenticated constructor works at runtime', () {
        // ignore: prefer_const_constructors
        final state = AuthState.unauthenticated();
        expect(state.status, AuthStatus.unauthenticated);
      });

      test('unknown constructor works at runtime', () {
        // ignore: prefer_const_constructors
        final state = AuthState.unknown();
        expect(state.isLoading, true);
        expect(state.userId, isNull);
      });
    });
  });
}
