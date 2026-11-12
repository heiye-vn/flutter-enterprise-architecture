/// 能力权限状态。
///
/// 特意不用 `permission_handler` 的枚举，而是自定义一层：
/// 业务代码不应该关心底层是 Android 的 `Permission.location` 还是 iOS 的
/// `AVAuthorizationStatus`，换实现时这里不用动。
enum CapabilityPermission {
  /// 已授权，可以直接用。
  granted,

  /// 本次拒绝，可以再次询问。
  denied,

  /// 永久拒绝，只能引导用户去系统设置。
  permanentlyDenied,
}
