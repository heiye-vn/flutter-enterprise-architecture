/// 环境配置。
///
/// 全部通过 `--dart-define` 注入，不为不同环境改动代码，
/// 这样 CI 里一条命令就能打不同包（见教程 14 · 工程化与发布）。
///
/// ```bash
/// flutter run \
///   --dart-define=FLAVOR=dev \
///   --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1 \
///   --dart-define=USE_MOCK=false
/// ```
class EnvConfig {
  const EnvConfig._();

  /// dev / uat / prod
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://crm-uat.example.com/api/v1',
  );

  /// 骨架阶段默认走内存 Mock，保证 clone 下来就能跑。
  /// 接真实后端时传 `--dart-define=USE_MOCK=false`。
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  static bool get isProd => flavor == 'prod';

  static const Duration connectTimeout = Duration(seconds: 15);

  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Mock 模式下模拟的网络延迟，用来验证骨架屏与加载态。
  static const Duration mockLatency = Duration(milliseconds: 450);
}
