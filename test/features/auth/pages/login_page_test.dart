import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/pages/login_page.dart';
import 'package:lorebase/features/auth/viewmodels/login_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

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
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginPage(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const SizedBox(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const SizedBox(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const SizedBox(),
          ),
        ],
      ),
    ),
  );
}

void main() {
  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(overrides: [
        loginViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('shows error message when state has error', (tester) async {
      final fakeVM =
          FakeLoginVM(state: const LoginState(errorMessage: 'Login failed'));
      final container = ProviderContainer(overrides: [
        loginViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('tapping Entrar calls submit', (tester) async {
      final fakeVM = FakeLoginVM(
          state: const LoginState(email: 'a@b.com', password: '123'));
      final container = ProviderContainer(overrides: [
        loginViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      await tester.tap(find.text('Entrar'));
      expect(fakeVM.submitCalled, true);
    });

    testWidgets('has forgot password and register links', (tester) async {
      final fakeVM = FakeLoginVM();
      final container = ProviderContainer(overrides: [
        loginViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapLoginPage(container));
      await tester.pump();

      expect(find.text('Esqueceu a senha?'), findsOneWidget);
      expect(find.textContaining('Cadastre-se'), findsOneWidget);
    });
  });
}
