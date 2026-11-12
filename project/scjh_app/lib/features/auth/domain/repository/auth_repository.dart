import '../entity/user.dart';

/// 认证仓库契约（Domain 层）。
///
/// 只声明"业务能做什么"，不关心底层是 HTTP、本地缓存还是生物识别。
/// Data 层负责实现它，UI 层只依赖它 —— 这就是依赖倒置。
abstract interface class AuthRepository {
  Future<User> login({required String account, required String password});

  Future<void> logout();

  /// 当前登录用户，未登录为 null。
  User? get currentUser;

  /// 冷启动时从本地恢复会话（同步，供 DI 在 runApp 前调用）。
  void restoreSession();
}
