import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/pages/forgot_password_page.dart';
import 'package:lorebase/features/auth/viewmodels/forgot_password_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

class FakeForgotPasswordVM extends ForgotPasswordViewModel {
  bool requestCodeCalled = false;
  bool resetPasswordCalled = false;
  final ForgotPasswordState testState;

  FakeForgotPasswordVM({ForgotPasswordState? state})
      : testState = state ?? const ForgotPasswordState();

  @override
  ForgotPasswordState build() => testState;

  @override
  Future<bool> requestCode() async {
    requestCodeCalled = true;
    return true;
  }

  @override
  Future<bool> resetPassword() async {
    resetPasswordCalled = true;
    return true;
  }

  @override
  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  @override
  void setCode(String code) {
    state = state.copyWith(code: code);
  }

  @override
  void setNewPassword(String p) {
    state = state.copyWith(newPassword: p);
  }

  @override
  void setConfirmPassword(String p) {
    state = state.copyWith(confirmPassword: p);
  }

  @override
  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }
}

class FakeAuthVM extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
  @override
  void setAuthenticated(String userId) {}
  @override
  void setUnauthenticated() {}
}

Widget _wrap(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/forgot-password',
        routes: [
          GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const ForgotPasswordPage(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('ForgotPasswordPage', () {
    ProviderContainer createContainer(FakeForgotPasswordVM fakeVM) {
      return ProviderContainer(overrides: [
        forgotPasswordViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
    }

    testWidgets('phase 1: shows email field and send button', (tester) async {
      final fakeVM = FakeForgotPasswordVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Enviar código'), findsOneWidget);
      expect(find.text('Recuperar senha'), findsOneWidget);
    });

    testWidgets('phase 2: shows code, password, confirm fields',
        (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(
          phase: ForgotPasswordPhase.resetPassword,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      // Should show reset button, not the request code button
      expect(find.text('Redefinir senha'), findsOneWidget);
    });

    testWidgets('shows error message when state has error', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(errorMessage: 'Invalid email'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('has back to login link', (tester) async {
      final fakeVM = FakeForgotPasswordVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Voltar para o login'), findsOneWidget);
    });

    testWidgets('tapping send button calls requestCode', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(email: 'test@email.com'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Enviar código'));
      expect(fakeVM.requestCodeCalled, true);
    });

    testWidgets('requestCode success shows snackbar', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(email: 'test@email.com'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Enviar código'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Código enviado para seu e-mail'), findsOneWidget);
    });

    testWidgets('tapping reset password button calls resetPassword and navigates',
        (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(
          phase: ForgotPasswordPhase.resetPassword,
          email: 'test@email.com',
          code: '123456',
          newPassword: 'newPass',
          confirmPassword: 'newPass',
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Redefinir senha'));
      await tester.tap(find.text('Redefinir senha'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeVM.resetPasswordCalled, true);
      expect(find.text('Redefinir senha'), findsNothing);
    });
  });
}
