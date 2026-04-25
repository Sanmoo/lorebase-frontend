enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.userId,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(String userId)
      : this._(status: AuthStatus.authenticated, userId: userId);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: errorMessage,
    );
  }
}
