/// 本地存储键集中管理。
///
/// 散落在各处的字符串键是后期最难排查的问题之一：
/// 拼错不会报错，只会"取不到值"，而且很难全局搜索。
class StorageKeys {
  const StorageKeys._();

  // 敏感数据 → flutter_secure_storage
  static const String accessToken = 'auth.access_token';
  static const String refreshToken = 'auth.refresh_token';

  // 普通偏好 → shared_preferences
  static const String themeMode = 'ui.theme_mode';
  static const String lastAccount = 'auth.last_account';

  /// 冷启动恢复会话用的用户快照（UserDto 的 JSON）。
  static const String cachedUser = 'auth.cached_user';
}
