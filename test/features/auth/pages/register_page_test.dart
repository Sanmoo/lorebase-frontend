import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lorebase/features/auth/pages/register_page.dart';
import 'package:lorebase/features/auth/viewmodels/register_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:lorebase/features/auth/viewmodels/auth_state.dart';

class FakeRegisterVM extends RegisterViewModel {
  final RegisterState testState;
  FakeRegisterVM({RegisterState? state})
      : testState = state ?? const RegisterState();

  @override
  RegisterState build() => testState;
  @override
  Future<bool> submit() async {
    state = testState.copyWith(showConfirmation: true);
    return true;
  }
  @override
  void setEmail(String e) => state = state.copyWith(email: e);
  @override
  void setPassword(String p) => state = state.copyWith(password: p);
  @override
  void setConfirmPassword(String p) =>
      state = state.copyWith(confirmPassword: p);
  @override
  void toggleTerms() =>
      state = state.copyWith(termsAccepted: !state.termsAccepted);
  @override
  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  @override
  void setConfirmationCode(String c) =>
      state = state.copyWith(confirmationCode: c);
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
        initialLocation: '/register',
        routes: [
          GoRoute(
              path: '/register', builder: (_, __) => const RegisterPage()),
          GoRoute(path: '/login', builder: (_, __) => const SizedBox()),
          GoRoute(
              path: '/dashboard', builder: (_, __) => const SizedBox()),
        ],
      ),
    ),
  );
}

void main() {
  group('RegisterPage', () {
    ProviderContainer createContainer(FakeRegisterVM fakeVM) {
      return ProviderContainer(overrides: [
        registerViewModelProvider.overrideWith(() => fakeVM),
        authViewModelProvider.overrideWith(() => FakeAuthVM()),
      ]);
    }

    testWidgets('renders without crashing', (tester) async {
      final container = createContainer(FakeRegisterVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();
      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('shows confirmation screen after submit', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          showConfirmation: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
      expect(find.text('Confirmar e entrar'), findsOneWidget);
    });

    testWidgets('shows error message when state has error', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(errorMessage: 'Email in use'),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Email in use'), findsOneWidget);
    });

    testWidgets('has login link', (tester) async {
      final container = createContainer(FakeRegisterVM());
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.textContaining('Já tem conta?'), findsOneWidget);
    });
  });
}
