import 'package:amplify_flutter/amplify_flutter.dart';

abstract class AuthRepository {
  Future<String> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> confirmSignUp(String email, String code);
  Future<void> resendSignUpCode(String email);
  Future<void> resetPassword(String email);
  Future<void> confirmResetPassword(String email, String code, String newPassword);
  Future<void> signOut();
  Future<bool> isAuthenticated();
}

class AmplifyAuthRepository implements AuthRepository {
  @override
  Future<String> signIn(String email, String password) async {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    if (!result.isSignedIn) {
      throw const AuthException('Login failed. Please check your credentials.');
    }
    final session = await Amplify.Auth.fetchAuthSession();
    final user = await Amplify.Auth.getCurrentUser();
    return user.userId;
  }

  @override
  Future<void> signUp(String email, String password) async {
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
    );
    if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
      // Requires email confirmation
      return;
    }
  }

  @override
  Future<void> confirmSignUp(String email, String code) async {
    await Amplify.Auth.confirmSignUp(
      username: email,
      confirmationCode: code,
    );
  }

  @override
  Future<void> resendSignUpCode(String email) async {
    await Amplify.Auth.resendSignUpCode(username: email);
  }

  @override
  Future<void> resetPassword(String email) async {
    await Amplify.Auth.resetPassword(username: email);
  }

  @override
  Future<void> confirmResetPassword(String email, String code, String newPassword) async {
    await Amplify.Auth.confirmResetPassword(
      username: email,
      newPassword: newPassword,
      confirmationCode: code,
    );
  }

  @override
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (_) {
      return false;
    }
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}
