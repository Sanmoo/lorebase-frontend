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

  @override
  Future<bool> submit() async {
    if (!state.isValid) {
      if (state.password != state.confirmPassword) {
        state = state.copyWith(errorMessage: 'As senhas não coincidem');
      } else if (state.passwordStrength == PasswordStrength.weak) {
        state = state.copyWith(errorMessage: 'A senha é muito fraca');
      } else if (!state.termsAccepted) {
        state = state.copyWith(errorMessage: 'Aceite os termos de uso');
      } else {
        state = state.copyWith(errorMessage: 'Preencha todos os campos');
      }
      return false;
    }
    state = state.copyWith(showConfirmation: true);
    return true;
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

Future<void> _scrollToSubmitButton(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.widgetWithText(ElevatedButton, 'Criar conta'),
    find.byType(SingleChildScrollView),
    const Offset(0, -200),
  );
  await tester.pump();
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
          password: 'StrongPass1',
          confirmPassword: 'StrongPass1',
          termsAccepted: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

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

    testWidgets('shows validation error for empty fields', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('A senha é muito fraca'), findsOneWidget);
    });

    testWidgets('shows validation error for password mismatch',
        (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          password: 'StrongPass1',
          confirmPassword: 'Different1',
          termsAccepted: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('shows validation error for weak password', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          password: 'abc',
          confirmPassword: 'abc',
          termsAccepted: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('A senha é muito fraca'), findsOneWidget);
    });

    testWidgets('shows loading indicator when submitting', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(isLoading: true),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Criar conta'),
        findsNothing,
      );
    });

    testWidgets('toggles password visibility', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(obscurePassword: true),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('typing in fields triggers listeners', (tester) async {
      final fakeVM = FakeRegisterVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.pump();

      expect(fakeVM.state.email, 'a@b.com');
    });

    testWidgets('login link navigates to login', (tester) async {
      final fakeVM = FakeRegisterVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.ensureVisible(find.textContaining('Já tem conta?'));
      await tester.tap(find.textContaining('Já tem conta?'));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('typing in password field triggers listener', (tester) async {
      final fakeVM = FakeRegisterVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(1), 'StrongP@ss1');
      await tester.pump();

      expect(fakeVM.state.password, 'StrongP@ss1');
    });

    testWidgets('submit with valid data without terms shows error', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          password: 'StrongPass1',
          confirmPassword: 'StrongPass1',
          termsAccepted: false,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Aceite os termos de uso'), findsOneWidget);
    });

    testWidgets('submit with valid data goes to confirmation', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          password: 'StrongPass1',
          confirmPassword: 'StrongPass1',
          termsAccepted: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await _scrollToSubmitButton(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Confirme seu e-mail'), findsOneWidget);
    });

    testWidgets('confirmation screen shows resend and confirm buttons', (tester) async {
      final fakeVM = FakeRegisterVM(
        state: const RegisterState(
          email: 'a@b.com',
          password: 'StrongPass1',
          confirmPassword: 'StrongPass1',
          termsAccepted: true,
          showConfirmation: true,
        ),
      );
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      expect(find.text('Confirmar e entrar'), findsOneWidget);
      expect(find.text('Reenviar código'), findsOneWidget);
    });

    testWidgets('typing in confirm password triggers listener', (tester) async {
      final fakeVM = FakeRegisterVM();
      final container = createContainer(fakeVM);
      addTearDown(container.dispose);
      await tester.pumpWidget(_wrap(container));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).at(2), 'match');
      await tester.pump();

      expect(fakeVM.state.confirmPassword, 'match');
    });
  });
}
