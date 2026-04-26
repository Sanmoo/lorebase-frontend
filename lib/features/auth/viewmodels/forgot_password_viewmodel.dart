import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';

part 'forgot_password_viewmodel.g.dart';

enum ForgotPasswordPhase { requestCode, resetPassword }

class ForgotPasswordState {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;
  final bool isLoading;
  final String? errorMessage;
  final ForgotPasswordPhase phase;
  final bool obscurePassword;

  const ForgotPasswordState({
    this.email = '',
    this.code = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.errorMessage,
    this.phase = ForgotPasswordPhase.requestCode,
    this.obscurePassword = true,
  });

  bool get canRequestCode => email.isNotEmpty;

  bool get canResetPassword {
    return code.isNotEmpty &&
        newPassword.isNotEmpty &&
        newPassword == confirmPassword;
  }

  ForgotPasswordState copyWith({
    String? email,
    String? code,
    String? newPassword,
    String? confirmPassword,
    bool? isLoading,
    String? errorMessage,
    ForgotPasswordPhase? phase,
    bool? obscurePassword,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      phase: phase ?? this.phase,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

@riverpod
class ForgotPasswordViewModel extends _$ForgotPasswordViewModel {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setCode(String code) {
    state = state.copyWith(code: code, errorMessage: null);
  }

  void setNewPassword(String password) {
    state = state.copyWith(newPassword: password, errorMessage: null);
  }

  void setConfirmPassword(String password) {
    state = state.copyWith(confirmPassword: password, errorMessage: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> requestCode() async {
    if (!state.canRequestCode) {
      state = state.copyWith(errorMessage: 'Digite seu e-mail');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(state.email);
      state = state.copyWith(isLoading: false, phase: ForgotPasswordPhase.resetPassword);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao enviar código. Tente novamente.',
      );
      return false;
    }
  }

  Future<bool> resetPassword() async {
    if (!state.canResetPassword) {
      if (state.newPassword != state.confirmPassword) {
        state = state.copyWith(errorMessage: 'As senhas não coincidem');
      } else {
        state = state.copyWith(errorMessage: 'Preencha todos os campos');
      }
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.confirmResetPassword(
        state.email,
        state.code,
        state.newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao redefinir senha. Tente novamente.',
      );
      return false;
    }
  }
}
