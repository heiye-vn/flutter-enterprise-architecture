import '../domain/entity/user.dart';

/// 登录态。
///
/// 用 sealed class 而不是 `bool isLoggedIn + User? user` 两个字段：
/// 前者保证"已登录一定有 user"，编译器帮你排除非法状态。
sealed class AuthState {
  const AuthState();

  bool get isAuthenticated => this is Authenticated;

  User? get currentUser => switch (this) {
    Authenticated(:final user) => user,
    _ => null,
  };
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  final User user;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}
