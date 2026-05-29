import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../l10n/strings.g.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_viewmodel.dart';

part 'login_viewmodel.g.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  LoginState build() => const LoginState();

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      state = state.copyWith(
        errorMessage: t.auth_error_email_password_required,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(authRepositoryProvider);
      final userId = await repository.signIn(state.email, state.password);
      ref.read(authViewModelProvider.notifier).setAuthenticated(userId);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: t.auth_error_invalid_credentials,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: t.auth_error_invalid_credentials,
      );
      return false;
    }
  }
}
