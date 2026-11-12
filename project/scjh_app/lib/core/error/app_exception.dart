/// 全 App 统一异常体系。
///
/// 用 Dart 3 的 `sealed class`，调用方可以做穷尽匹配：
/// 将来新增一种异常类型，所有 switch 会直接编译报错，
/// 而不是静默走进 default 分支。
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// 可以直接展示给用户的文案。
  final String message;

  /// 原始错误，只用于日志上报，不要展示。
  final Object? cause;

  @override
  String toString() => '$runtimeType($message)';
}

/// 网络不可达、DNS 失败、连接被拒。
final class NetworkException extends AppException {
  const NetworkException({
    String message = '网络连接失败，请检查网络后重试',
    super.cause,
  }) : super(message);
}

/// 请求超时。
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    String message = '请求超时，请稍后重试',
    super.cause,
  }) : super(message);
}

/// 401：登录态失效，需要重新登录。
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = '登录已失效，请重新登录',
    super.cause,
  }) : super(message);
}

/// 后端返回的业务错误（HTTP 200，但 code 不是成功码）。
final class BusinessException extends AppException {
  const BusinessException({required this.code, required String message})
    : super(message);

  final int code;
}

/// 响应结构不符合预期。
final class ParseException extends AppException {
  const ParseException({String message = '数据解析失败', super.cause})
    : super(message);
}

/// 未归类的错误。
final class UnknownException extends AppException {
  const UnknownException({String message = '发生未知错误', super.cause})
    : super(message);
}

/// 把任意异常收敛成一句用户能看懂的话。
String readableMessage(Object error) => switch (error) {
  AppException(:final message) => message,
  _ => '发生未知错误，请稍后重试',
};
