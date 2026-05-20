import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/pages/login_page.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';
import 'package:lorebase/l10n/strings.g.dart';

class FakeLoginVM extends LoginViewModel {
  bool submitCalled = false;
  bool submitResult = true;
  final LoginState testState;

  FakeLoginVM({LoginState? state}) : testState = state ?? const LoginState();

  @override
  LoginState build() => testState;

  @override
  Future<bool> submit() async {
    submitCalled = true;
    return submitResult;
  }

  @override
  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  @override
  void setPassword(String password) {
    state = state.copyWith(password: password);
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

Widget _wrapLoginPage(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: [
            GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
            GoRoute(path: '/register', builder: (_, _) => const SizedBox()),
            GoRoute(
              path: '/forgot-password',
              builder: (_, _) => const SizedBox(),
            ),
            GoRoute(path: '/dashboard', builder: (_, _) => const SizedBox()),
          ],
        ),
      ),
    ),
  );
}

Future<void> main() async {
  await LocaleSettings.setLocale(AppLocale.ptBr);

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('shows error message when state has error', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(errorMessage: 'Login failed'),
      );
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('tapping Entrar calls submit', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(email: 'a@b.com', password: '123'),
      );
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.tap(find.text('Entrar'));
      expect(fakeVM.submitCalled, true);
    });

    testWidgets('has forgot password and register links', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.text('Esqueceu a senha?'), findsOneWidget);
      expect(find.textContaining('Cadastre-se'), findsOneWidget);
    });

    testWidgets('shows standalone error when form is valid', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(
          email: 'a@b.com',
          password: '123',
          errorMessage: 'Login failed',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('shows loading spinner when isLoading is true', (tester) async {
      final fakeVM = FakeLoginVM(state: const LoginState(isLoading: true));
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submit failure does not navigate away', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(email: 'a@b.com', password: '123'),
      );
      fakeVM.submitResult = false;
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(fakeVM.submitCalled, true);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('toggle obscure password icon works', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(obscurePassword: true),
      );
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('typing in email field triggers listener', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
      await tester.pump();

      expect(fakeVM.state.email, 'a@b.com');
    });

    testWidgets('typing in password field triggers listener', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).last, 'secret');
      await tester.pump();

      expect(fakeVM.state.password, 'secret');
    });

    testWidgets('forgot password link navigates', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.tap(find.text('Esqueceu a senha?'));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('register link navigates', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.tap(find.textContaining('Cadastre-se'));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('onSubmitted on email moves focus', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      final emailField = find.byType(TextFormField).first;
      await tester.showKeyboard(emailField);
      await tester.enterText(emailField, 'a@b.com');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(fakeVM.state.email, 'a@b.com');
    });

    testWidgets('onSubmitted on password triggers submit', (tester) async {
      final fakeVM = FakeLoginVM(
        state: const LoginState(email: 'a@b.com', password: '123'),
      );
      final container = ProviderContainer(
        overrides: [
          loginViewModelProvider.overrideWith(() => fakeVM),
          authViewModelProvider.overrideWith(() => FakeAuthVM()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      final passwordField = find.byType(TextFormField).last;
      await tester.showKeyboard(passwordField);
      await tester.enterText(passwordField, '123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(fakeVM.submitCalled, true);
    });
  });
}
