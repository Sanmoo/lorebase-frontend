import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/cache/cache_providers.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() {
    _checkAuth();
    return const AuthState.unknown();
  }

  Future<void> _checkAuth() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final isAuthenticated = await repository.isAuthenticated();
      if (isAuthenticated) {
        state = const AuthState.authenticated('');
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signOut() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
    } catch (_) {
      // Ignore sign-out errors
    }
    await ref.read(cacheServiceProvider).clearAll();
    state = const AuthState.unauthenticated();
  }

  void setAuthenticated(String userId) {
    state = AuthState.authenticated(userId);
  }

  void setUnauthenticated() {
    state = const AuthState.unauthenticated();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AmplifyAuthRepository();
});
