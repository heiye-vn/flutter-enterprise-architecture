import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasource/auth_api.dart';
import '../../features/auth/data/datasource/auth_api_mock.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repository/auth_repository.dart';
import '../../features/customer/data/datasource/customer_api.dart';
import '../../features/customer/data/datasource/customer_api_mock.dart';
import '../../features/customer/data/repository/customer_repository_impl.dart';
import '../../features/customer/domain/repository/customer_repository.dart';
import '../../platform/location/fake_location_service.dart';
import '../../platform/location/location_service.dart';
import '../../platform/scanner/fake_scanner_service.dart';
import '../../platform/scanner/scanner_service.dart';
import '../config/env_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../storage/prefs_repository.dart';
import '../storage/secure_storage.dart';

/// 全局服务定位器。
///
/// 这里刻意**只用 get_it 管理基础设施**（网络、存储、仓库、原生能力），
/// UI 状态交给 Riverpod。
///
/// 职责划分：
/// - get_it：无状态或长生命周期的服务，任何地方都能同步取到；
/// - Riverpod：与 Widget 生命周期绑定的状态。
///
/// 这样做的好处是 Controller 里不用为了拿一个 Repository 去建一堆 Provider 依赖链。
/// 后面如果引入 `injectable` 做代码生成，只需要把这个文件换成 `@InjectableInit()`，
/// 其余代码不受影响。
final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await _registerStorage();
  _registerNetwork();
  _registerDataSources();
  _registerRepositories();
  _registerCapabilities();
}

Future<void> _registerStorage() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<PrefsRepository>(PrefsRepository(prefs));

  final secure = SecureStorage(const FlutterSecureStorage());
  await secure.init();
  getIt.registerSingleton<SecureStorage>(secure);
}

void _registerNetwork() {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: EnvConfig.connectTimeout,
      receiveTimeout: EnvConfig.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );

  final apiClient = ApiClient(dio);
  getIt
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<ApiClient>(apiClient);

  // 拦截器需要 apiClient 做刷新、需要 dio 做重放，
  // 所以放在这两者注册之后构造，避免循环依赖。
  final interceptor = AuthInterceptor(
    storage: getIt<SecureStorage>(),
    onRefresh: () async {
      final refreshToken = getIt<SecureStorage>().refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) return null;
      try {
        final json = await apiClient.postJson<Map<String, dynamic>>(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final token = json['accessToken'] as String?;
        if (token != null) {
          await getIt<SecureStorage>().saveTokens(accessToken: token);
        }
        return token;
      } on Object {
        return null;
      }
    },
  )..dio = dio;

  dio.interceptors.add(interceptor);
}

void _registerDataSources() {
  if (EnvConfig.useMock) {
    getIt
      ..registerLazySingleton<AuthApi>(() => const AuthApiMock())
      ..registerLazySingleton<CustomerApi>(() => CustomerApiMock());
  } else {
    getIt
      ..registerLazySingleton<AuthApi>(
        () => AuthApiRemote(getIt<ApiClient>()),
      )
      ..registerLazySingleton<CustomerApi>(
        () => CustomerApiRemote(getIt<ApiClient>()),
      );
  }
}

void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(() {
    final repository = AuthRepositoryImpl(
      api: getIt<AuthApi>(),
      storage: getIt<SecureStorage>(),
      prefs: getIt<PrefsRepository>(),
    );
    // 冷启动恢复登录态，必须在首次读取 currentUser 之前完成。
    repository.restoreSession();
    return repository;
  });

  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomerApi>()),
  );
}

/// 原生能力注册。
///
/// **接真实插件时只改这里两行**：
/// ```dart
/// getIt.registerLazySingleton<ScannerService>(() => MobileScannerService());
/// getIt.registerLazySingleton<LocationService>(() => GeolocatorLocationService());
/// ```
/// 业务页面一行都不用动。
void _registerCapabilities() {
  getIt
    ..registerLazySingleton<ScannerService>(() => const FakeScannerService())
    ..registerLazySingleton<LocationService>(() => const FakeLocationService());
}
