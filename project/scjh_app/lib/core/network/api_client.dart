import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import 'api_envelope.dart';

/// 网络层唯一出口。
///
/// 职责边界：
/// - 发请求、解壳、把 DioException 翻译成 [AppException]；
/// - **不做** 业务判断，也不知道 token 的存在（那是拦截器的事）。
///
/// Data 层只面向这个类说"接口语言"，将来换成 GraphQL / gRPC，
/// 也只需要替换这一层。
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// 需要在拦截器里做重放时取用。
  Dio get dio => _dio;

  Future<T> getJson<T>(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.get<dynamic>(
        path,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<T> postJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
      ),
    );
  }

  Future<T> putJson<T>(String path, {Object? data}) {
    return _request<T>(() => _dio.put<dynamic>(path, data: data));
  }

  Future<T> _request<T>(Future<Response<dynamic>> Function() send) async {
    try {
      final response = await send();
      return _unwrap<T>(response.data);
    } on DioException catch (error) {
      throw _translate(error);
    }
  }

  T _unwrap<T>(Object? body) {
    if (body is Map<String, dynamic> && body.containsKey('code')) {
      final envelope = ApiEnvelope.fromJson(body);
      if (!envelope.isSuccess) {
        throw BusinessException(
          code: envelope.code,
          message: envelope.message.isEmpty ? '业务处理失败' : envelope.message,
        );
      }
      final data = envelope.data;
      if (data is T) return data;
      if (data == null) {
        throw const ParseException(message: '响应缺少 data 字段');
      }
      throw ParseException(message: '响应类型不匹配：期望 $T，实际 ${data.runtimeType}');
    }

    if (body is T) return body;
    throw ParseException(message: '无法解析响应：${body.runtimeType}');
  }

  AppException _translate(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return RequestTimeoutException(cause: error);

      case DioExceptionType.connectionError:
        return NetworkException(cause: error);

      case DioExceptionType.badCertificate:
        return const NetworkException(message: '证书校验失败，请检查网络环境');

      case DioExceptionType.cancel:
        return const UnknownException(message: '请求已取消');

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status == 401) return UnauthorizedException(cause: error);

        final body = error.response?.data;
        if (body is Map<String, dynamic> && body.containsKey('code')) {
          final envelope = ApiEnvelope.fromJson(body);
          return BusinessException(
            code: envelope.code,
            message: envelope.message.isEmpty ? 'HTTP $status' : envelope.message,
          );
        }
        return NetworkException(message: '服务异常（HTTP $status）', cause: error);

      case DioExceptionType.unknown:
        return NetworkException(cause: error);
    }
  }
}
