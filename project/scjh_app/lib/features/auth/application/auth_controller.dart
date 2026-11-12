import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../domain/repository/auth_repository.dart';
import 'auth_state.dart';

/// 登录态控制器。
///
/// 只做三件事：暴露状态、登录、登出。
/// 不碰 token、不碰存储 —— 那是 Repository 的职责。
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final user = getIt<AuthRepository>().currentUser;
    return user == null ? const Unauthenticated() : Authenticated(user);
  }

  Future<void> login({
    required String account,
    required String password,
  }) async {
    final user = await getIt<AuthRepository>().login(
      account: account,
      password: password,
    );
    state = Authenticated(user);
  }

  Future<void> logout() async {
    await getIt<AuthRepository>().logout();
    state = const Unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
