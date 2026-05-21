import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_viewmodel.dart';

part 'register_viewmodel.g.dart';

enum PasswordStrength { weak, medium, strong }

class RegisterState {
  final String email;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;
  final bool showConfirmation;
  final String? confirmationCode;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.termsAccepted = false,
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
    this.showConfirmation = false,
    this.confirmationCode,
  });

  PasswordStrength get passwordStrength {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;

    switch (score) {
      case 0:
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.medium;
      default:
        return PasswordStrength.strong;
    }
  }

  bool get isValid {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        termsAccepted &&
        password == confirmPassword &&
        passwordStrength != PasswordStrength.weak;
  }

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    bool? termsAccepted,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
    bool? showConfirmation,
    String? confirmationCode,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      showConfirmation: showConfirmation ?? this.showConfirmation,
      confirmationCode: confirmationCode ?? this.confirmationCode,
    );
  }
}

@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  @override
  RegisterState build() => const RegisterState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      errorMessage: null,
    );
  }

  void toggleTerms() {
    state = state.copyWith(
      termsAccepted: !state.termsAccepted,
      errorMessage: null,
    );
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setConfirmationCode(String code) {
    state = state.copyWith(confirmationCode: code, errorMessage: null);
  }

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

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signUp(state.email, state.password);
      state = state.copyWith(isLoading: false, showConfirmation: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _signUpErrorMessage(e),
      );
      return false;
    }
  }

  String _signUpErrorMessage(Object error) {
    final text = error.toString();
    if (text.contains('UsernameExistsException') ||
        text.contains('User already exists')) {
      return 'Este email já está cadastrado. Faça login ou use outro email.';
    }
    return 'Erro ao criar conta. Tente novamente.';
  }

  Future<bool> confirmSignUp() async {
    if (state.confirmationCode == null || state.confirmationCode!.isEmpty) {
      state = state.copyWith(errorMessage: 'Digite o código de confirmação');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmSignUp(state.email, state.confirmationCode!);
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Código inválido. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> resendCode() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resendSignUpCode(state.email);
    } catch (_) {
      // Silently fail
    }
  }

  Future<bool> resendExistingAccountCode() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resendSignUpCode(state.email);
      state = state.copyWith(isLoading: false, showConfirmation: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível reenviar o código. Tente novamente.',
      );
      return false;
    }
  }
}
