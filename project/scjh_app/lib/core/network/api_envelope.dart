/// 后端统一响应壳。
///
/// ```json
/// { "code": 200, "message": "ok", "data": { ... } }
/// ```
///
/// 字段名做了兼容（code/status、message/msg、data/result），
/// 接不同后端时只需要改这一个文件。
class ApiEnvelope {
  const ApiEnvelope({required this.code, required this.message, this.data});

  final int code;
  final String message;
  final Object? data;

  /// 成功码。0 和 200 都放行，避免不同服务端风格打架。
  bool get isSuccess => code == 0 || code == 200;

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    final rawCode = json['code'] ?? json['status'];
    return ApiEnvelope(
      code: rawCode is int ? rawCode : int.tryParse('$rawCode') ?? -1,
      message: '${json['message'] ?? json['msg'] ?? ''}',
      data: json['data'] ?? json['result'],
    );
  }
}
