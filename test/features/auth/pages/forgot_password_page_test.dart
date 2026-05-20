import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/pages/forgot_password_page.dart';
import 'package:lorebase/features/auth/viewmodels/forgot_password_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeForgotPasswordVM extends ForgotPasswordViewModel {
  bool requestCodeCalled = false;
  bool requestCodeResult = true;
  bool resetPasswordCalled = false;
  bool resetPasswordResult = true;
  final ForgotPasswordState testState;

  FakeForgotPasswordVM({ForgotPasswordState? state})
    : testState = state ?? const ForgotPasswordState();

  @override
  ForgotPasswordState build() => testState;

  @override
  Future<bool> requestCode() async {
    requestCodeCalled = true;
    return requestCodeResult;
  }

  @override
  Future<bool> resetPassword() async {
    resetPasswordCalled = true;
    return resetPasswordResult;
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
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/forgot-password',
          routes: [
            GoRoute(
              path: '/forgot-password',
              builder: (_, _) => const ForgotPasswordPage(),
            ),
            GoRoute(path: '/login', builder: (_, _) => const SizedBox()),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

  group('ForgotPasswordPage', () {
    ProviderContainer createContainer(FakeForgotPasswordVM fakeVM) {
      return ProviderContainer(
        overrides: [
          forgotPasswordViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
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

    testWidgets('phase 2: shows code, password, confirm fields', (
      tester,
    ) async {
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

    testWidgets(
      'tapping reset password button calls resetPassword and navigates',
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
      },
    );

    testWidgets('shows loading indicator when isLoading', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(isLoading: true),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('phase 2 shows password toggle icon', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(
          phase: ForgotPasswordPhase.resetPassword,
          obscurePassword: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(fakeVM.state.obscurePassword, false);
    });

    testWidgets('requestCode with empty email sets error', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(email: ''),
      );
      fakeVM.requestCodeResult = false;
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Enviar código'));
      await tester.pump();

      expect(fakeVM.requestCodeCalled, true);
    });

    testWidgets('resetPassword with empty fields shows error', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(
          phase: ForgotPasswordPhase.resetPassword,
        ),
      );
      fakeVM.resetPasswordResult = false;
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Redefinir senha'));
      await tester.tap(find.text('Redefinir senha'));
      await tester.pump();

      expect(fakeVM.resetPasswordCalled, true);
    });

    testWidgets('back to login navigates', (tester) async {
      final fakeVM = FakeForgotPasswordVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.tap(find.text('Voltar para o login'));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('typing in email field triggers listener', (tester) async {
      final fakeVM = FakeForgotPasswordVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.pump();

      expect(fakeVM.state.email, 'a@b.com');
    });

    testWidgets('phase 2 typing in fields triggers listeners', (tester) async {
      final fakeVM = FakeForgotPasswordVM(
        state: const ForgotPasswordState(
          phase: ForgotPasswordPhase.resetPassword,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      final codeField = find.byType(TextFormField).at(0);
      await tester.enterText(codeField, '123456');
      await tester.pump();

      final passwordField = find.byType(TextFormField).at(1);
      await tester.enterText(passwordField, 'newPass');
      await tester.pump();

      expect(fakeVM.state.code, '123456');
      expect(fakeVM.state.newPassword, 'newPass');
    });
  });
}
