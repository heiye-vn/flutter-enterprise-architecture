import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// 刷新 token 的回调。返回 null 表示刷新失败，需要重新登录。
typedef TokenRefreshCallback = Future<String?> Function();

/// 鉴权拦截器：注入 token + 401 自动刷新并重放。
///
/// 关键点是**刷新要串行化**：10 个请求同时 401 时，
/// 只允许发起一次 refresh，其余请求等待同一个 Future，
/// 否则会拿旧 token 反复刷、把服务端的 refresh token 打失效。
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.onRefresh,
    this.skipPaths = const {'/auth/login', '/auth/refresh'},
  });

  final SecureStorage storage;
  final TokenRefreshCallback onRefresh;
  final Set<String> skipPaths;

  /// 由 DI 注入，用于重放请求。
  late Dio dio;

  Future<String?>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = storage.accessToken;
    if (token != null && token.isNotEmpty && !_skip(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra['__retried'] == true;

    if (err.response?.statusCode != 401 || alreadyRetried || _skip(options.path)) {
      return handler.next(err);
    }

    final newToken = await _refreshOnce();
    if (newToken == null) {
      await storage.clear();
      return handler.next(err);
    }

    try {
      options
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['__retried'] = true;
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshOnce() {
    return _refreshing ??= onRefresh().whenComplete(() => _refreshing = null);
  }

  bool _skip(String path) => skipPaths.any(path.contains);
}
