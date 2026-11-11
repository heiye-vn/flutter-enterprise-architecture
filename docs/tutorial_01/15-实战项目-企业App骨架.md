# 15 · 实战项目：企业 App 骨架（全系列收官串联）

> **本篇目标**：以企业移动 CRM「MobiCRM」为目标，把 01–14 篇的技术选型**全部串起来**。跟着 8 个 Step 做完，你会得到一个可继续开发的企业级骨架：分层目录、DI、登录（含 token 刷新）、列表分页、表单、主题持久化、测试与监控。所有代码与第 09 篇架构完全一致——09 讲"为什么"，本篇讲"从零搭到能跑"。前置阅读：全系列 01–14（收官串联篇，通读后再看收益最大；急用可按下方目录回查）。
>
> **学完你能做什么**：fork 即用的企业骨架；掌握"新模块接入"标准四段式（domain→data→application→presentation）；用 mock 一个 Repository 的成本测完登录全流程。

## 0. 全系列目录

| # | 篇章 | # | 篇章 |
|---|---|---|---|
| 01 | [Dart 语言基础](01-Dart语言基础.md) | 09 | [应用架构设计](09-应用架构设计.md) |
| 02 | [Dart 语言进阶](02-Dart语言进阶.md) | 10 | [平台交互与混合开发](10-平台交互与混合开发.md) |
| 03 | [Flutter 工程入门](03-Flutter工程入门.md) | 11 | [企业级通用能力](11-企业级通用能力.md) |
| 04 | [Widget 与布局](04-Widget与布局.md) | 12 | [测试体系](12-测试体系.md) |
| 05 | [路由与导航](05-路由与导航.md) | 13 | [性能优化](13-性能优化.md) |
| 06 | [状态管理](06-状态管理.md) | 14 | [工程化与发布](14-工程化与发布.md) |
| 07 | [网络层设计](07-网络层设计.md) | 15 | **本篇（实战串联）** |
| 08 | [本地存储](08-本地存储.md) | 16 | [版本演进与迁移速查](16-版本演进与迁移速查.md) |

## 1. 项目需求与功能清单

企业销售团队的移动 CRM，首期五功能：

| 功能 | 要点 | 用到的技术 | 对应篇章 |
|---|---|---|---|
| 登录 | 账号密码、token 刷新、自动登录、退出 | AsyncNotifier + dio 拦截器 + secure_storage | 06/07/08/09 |
| 客户列表 | 分页、下拉刷新、上拉加载、空/错/加载态 | Notifier + RefreshIndicator | 06/11 |
| 客户详情 | 路由参数传 id，按需加载 | FutureProvider.family + go_router | 05/06 |
| 跟进表单 | 校验、防重复提交 | Form + Riverpod | 10 |
| 设置 | 主题切换持久化、退出登录清理链路 | Hive + Notifier | 08/09 |

技术栈：**go_router 18 + Riverpod 3.x + get_it/injectable + dio + Hive + flutter_secure_storage + json_serializable/freezed + Sentry**。选型理由在 05–09 篇，不重复论证。

## 2. 里程碑规划

| Step | 内容 | 对应阅读 | 完成标志 | 自检点 |
|---|---|---|---|---|
| 1 | 工程初始化 | 01 | `pub get` 通过、`analyze` 零告警 | doctor 全绿？版本兼容？ |
| 2 | 目录骨架 | 09 | 目录建好、占位文件就绪 | 能说出每层职责？ |
| 3 | 核心基座（主题/路由/网络/存储/DI） | 05/07/08 | App 能起、路由能跳 | redirect 在 loading 期不误跳？ |
| 4 | 登录模块 | 09（重读） | 登录/自动登录/退出全通 | token 落地？401 能刷新？ |
| 5 | 列表分页 | 06/11 | 四态 + 分页 + 刷新全对 | 空态能下拉刷新？ |
| 6 | 详情与表单 | 10 | 详情可看、表单可交 | 连点只发一次请求？ |
| 7 | 设置页 | 08 | 主题重启保留、退出干净 | 退出后回登录页？缓存失效？ |
| 8 | 质量收尾 | 12/14 | 测试绿 + Sentry 收到事件 | 断网能测登录吗？ |

## 3. Step 1：工程初始化

```bash
flutter create mobi_crm --org com.company --platforms android,ios
cd mobi_crm
# 建好 Step 2 目录、贴入全部文件后：
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

`pubspec.yaml` 关键片段（版本为撰写时稳定版，以 `flutter pub outdated` 为准）：

```yaml
# pubspec.yaml（节选）
# 版本基线：Flutter 3.47 / Dart 3.13（2026-11 稳定版）。
# 除标注外，具体版本号以 pub.dev 当日最新稳定版为准，不要照抄。
name: mobi_crm
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
  go_router: ^18.1.4             # 路由（v18 起 SDK 基线 Flutter 3.44/Dart 3.12）
  flutter_riverpod: ^3.5.0       # 状态（3.x；2.x 迁移见 06 篇 5.2.1）
  get_it: ^7.6.7                 # DI 容器
  injectable: ^2.4.2             # DI 注解
  dio: ^5.4.3                    # 网络
  hive: ^2.2.3                   # 本地 KV（原库更新停滞，选型时先在 pub.dev 复核是否有更活跃的维护版本）
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.2.2 # token 存储
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1     # 若用 freezed 3.x，注解与生成器需同时升级
  sentry_flutter: ^8.2.0         # 监控
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.11
  json_serializable: ^6.8.0
  freezed: ^2.5.2
  injectable_generator: ^2.6.0
  mocktail: ^1.0.4
```

`analysis_options.yaml`——企业门禁，CI 里 `flutter analyze` 零告警是合并前提：

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - "**/*.g.dart"                        # json_serializable 产物
    - "**/*.freezed.dart"                  # freezed 产物
    - "lib/core/di/injection.config.dart"  # injectable 产物
linter:
  rules:
    prefer_const_constructors: true   # 最大化 const，减少 rebuild
    avoid_print: true                 # 日志统一走 12 篇方案
    use_super_parameters: true        # Dart 3 super 参数
    always_use_package_imports: true  # 禁相对 import，跨层引用一眼可见（09 篇铁律可执行化）
```

## 4. Step 2：目录骨架

与第 09 篇推荐树完全一致，本篇逐文件填充：

```
lib/
├── main.dart                          # 入口：Hive/DI/Sentry + runApp
├── app.dart                           # 根组件：MaterialApp.router
├── core/
│   ├── config/env_config.dart         # 环境与 baseUrl
│   ├── constants/storage_keys.dart    # 存储键常量
│   ├── error/app_exception.dart       # 统一异常
│   ├── network/api_client.dart        # dio 封装 + 响应壳解包
│   ├── network/auth_interceptor.dart  # 鉴权注入 + 401 刷新重放
│   ├── storage/secure_storage.dart    # token（secure_storage）
│   ├── storage/prefs_repository.dart  # 偏好（Hive）
│   ├── router/app_router.dart         # GoRouter + 登录守卫
│   ├── theme/app_theme.dart           # 亮/暗主题
│   ├── di/injection.dart              # configureDependencies
│   └── widgets/{empty_view,error_view}.dart  # 通用空态/错误态
├── features/
│   ├── auth/     # data(dto/datasource/repository) + domain + application + presentation
│   ├── customer/ # 四段式同上
│   └── settings/
└── test/          # auth_controller_test.dart + login_form_test.dart
```

## 5. Step 3：核心基座

### 5.1 Theme 封装

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const seed = Color(0xFF1A73E9);
  // 注：useMaterial3 自 3.16 起默认 true，这里保留只为模板完整；
  // 取色一律走 colorScheme 的角色（surface/surfaceContainerXxx），不要写死 Colors.xxx
  static ThemeData get light => ThemeData(
      useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: seed),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
  static ThemeData get dark => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()));
}
```

### 5.2 GoRouter 配置（含登录守卫）

第 05 篇讲了 go_router 基础，这里给"和 Riverpod 联动"的最终形态。核心问题只有一个：GoRouter 的 `refreshListenable` 需要 `Listenable`，而登录态在 Riverpod 里——做一座桥：

```dart
// lib/core/router/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_crm/features/auth/application/auth_providers.dart';
import 'package:mobi_crm/features/auth/presentation/login/login_screen.dart';
import 'package:mobi_crm/features/customer/presentation/detail/customer_detail_screen.dart';
import 'package:mobi_crm/features/customer/presentation/list/customer_list_screen.dart';
import 'package:mobi_crm/features/settings/presentation/settings_screen.dart';

/// 桥：把 authControllerProvider 的每次变化转成 notifyListeners（官方推荐姿势）
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh, // 登录态一变，redirect 重跑
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(
          path: '/home',
          builder: (c, s) => const CustomerListScreen(),
          routes: [
            GoRoute( // /home/customer/C001
                path: 'customer/:id',
                builder: (c, s) => CustomerDetailScreen(customerId: s.pathParameters['id']!)),
            GoRoute(path: 'settings', builder: (c, s) => const SettingsScreen()),
          ]),
    ],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      // ★ 自动登录进行中：原地等待，不误判为未登录（闪登录页的经典 bug）
      if (auth.isLoading && !auth.hasValue) return null;
      final authed = auth.value != null;
      final onLogin = state.matchedLocation == '/login';
      if (!authed) return onLogin ? null : '/login'; // 未登录一律去登录页
      if (onLogin) return '/home';                   // 已登录禁回登录页
      return null;
    },
  );
});
```

设计决策：登录成功**不在按钮回调里跳转**——`state` 一变，`refreshListenable` 触发 redirect 统一接管（09 篇的"单一后果出口"）；多端互踢、强制下线来了，改的只有 redirect。

### 5.3 ApiClient 最终组装

第 07 篇的设计在此收口（`ApiException` 类见 07/09 篇，放 `lib/core/error/app_exception.dart`）：

```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:mobi_crm/core/config/env_config.dart';
import 'package:mobi_crm/core/network/auth_interceptor.dart';
import 'package:mobi_crm/core/storage/secure_storage.dart';

@lazySingleton
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
        baseUrl: EnvConfig.instance.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'}))
      ..interceptors.add(AuthInterceptor(this, _storage)); // 07 篇拦截器
  }
  late final Dio _dio;
  final SecureStorage _storage;
  Dio get dio => _dio;
  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? query}) async {
    final resp = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return _unwrap(resp.data!);
  }
  Future<Map<String, dynamic>> postJson(String path, {Object? data}) async {
    final resp = await _dio.post<Map<String, dynamic>>(path, data: data);
    return _unwrap(resp.data!);
  }
  /// 解包企业响应壳 {code, message, data}：非 0 一律抛 ApiException
  Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    final code = (body['code'] as num).toInt();
    if (code != 0) throw ApiException(code, body['message'] as String? ?? '服务异常');
    return (body['data'] as Map<String, dynamic>?) ?? const {};
  }
}
```

鉴权拦截器 `AuthInterceptor` 直接沿用第 07 篇（onRequest 注入 `Bearer token`；onError 捕 401 → `post('/auth/refresh')` → 存新 token → `dio.fetch(err.requestOptions)` 重放），挂进 `ApiClient` 构造即可。环境配置 `EnvConfig`（`lib/core/config/env_config.dart`）为单例：`baseUrl` 用 `String.fromEnvironment('API_BASE_URL', defaultValue: 'https://crm-uat.example.com/api/v1')`，`--dart-define` 切换（详见第 14 篇 CI）。

### 5.4 存储基座（引用第 08 篇）

`SecureStorage`（`lib/core/storage/secure_storage.dart`）即 08 篇最终形态：`readToken / readRefreshToken / saveToken / saveRefreshToken / clear`，内部用 `FlutterSecureStorage` 按 `StorageKeys` 常量读写，`@lazySingleton` 注册。Hive 偏好仓储（import `hive_flutter`/`injectable`/`storage_keys`，完整版见 08 篇）：

```dart
// lib/core/storage/prefs_repository.dart（关键实现）
@lazySingleton
class PrefsRepository {
  static const _boxName = 'prefs';
  /// main() 里最先调用：Hive 全局初始化 + 打开偏好盒
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }
  Future<ThemeMode?> readThemeMode() async {
    final v = Hive.box(_boxName).get(StorageKeys.themeMode) as String?;
    return (v == null) ? null : ThemeMode.values.where((e) => e.name == v).firstOrNull;
  }
  Future<void> saveThemeMode(ThemeMode mode) async =>
      Hive.box(_boxName).put(StorageKeys.themeMode, mode.name);
}
```

`initHive` 做成 static 是刻意的：Hive box 全局注册，实例方法全用 `Hive.box(...)` 全局取，**避免"main 里 new 的实例"与"get_it 里的单例"各持一份状态**的坑。

## 6. Step 4：登录模块（完整代码走读，本篇最重）

按第 09 篇分层自下而上。Data 层两份 DTO——请求体如下，响应体 `login_response_dto.dart` 同构：`token/refreshToken/userId/userNickname/userAvatar` 五字段 + `fromJson` 工厂（注解 `createToJson: false`）：

```dart
// lib/features/auth/data/dto/login_request_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'login_request_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginRequestDto {
  LoginRequestDto({required this.account, required this.password});
  final String account;
  final String password;
  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}
```

Domain 层——Entity 与接口。**这一层是纯 Dart，一个 Flutter import 都没有**，业务可脱离 UI 测试的根基：

```dart
// ── lib/features/auth/domain/entity/user.dart ──
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({required String id, required String name, String? avatar}) = _User;
}

// ── lib/features/auth/domain/repository/auth_repository.dart ──
// （import 'package:mobi_crm/features/auth/domain/entity/user.dart';）
/// Application 层唯一认识的抽象（09 篇铁律三）
abstract class AuthRepository {
  Future<User> login(String account, String password);
  Future<User?> restoreSession(); // 自动登录：无 token/token 失效 → null
  Future<void> logout();
}
```

Data 层——远程数据源 `AuthApi`（`lib/features/auth/data/datasource/auth_api.dart`，`@lazySingleton`，构造注入 `ApiClient`）只说"接口语言"：`login(dto)` → `postJson('/auth/login', data: dto.toJson())` → `LoginResponseDto.fromJson`；`fetchMe()` → `getJson('/auth/me')` → 手工转 `User`。Repository 实现防腐转换 + 副作用（存 token）收口，**token 永远不出 Data 层**——Controller 与 UI 自始至终不知道 token 的存在，这正是 401 刷新能对全 App 透明完成的原因：

```dart
// lib/features/auth/data/repository/auth_repository_impl.dart
import 'package:injectable/injectable.dart';

import 'package:mobi_crm/core/storage/secure_storage.dart';
import 'package:mobi_crm/features/auth/data/datasource/auth_api.dart';
import 'package:mobi_crm/features/auth/data/dto/login_request_dto.dart';
import 'package:mobi_crm/features/auth/domain/entity/user.dart';
import 'package:mobi_crm/features/auth/domain/repository/auth_repository.dart';

@LazySingleton(as: AuthRepository) // 注册为接口类型（09 篇 6.2）
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._storage);
  final AuthApi _api;
  final SecureStorage _storage;

  @override
  Future<User> login(String account, String password) async {
    final resp = await _api.login(LoginRequestDto(account: account, password: password));
    await _storage.saveToken(resp.token);
    await _storage.saveRefreshToken(resp.refreshToken);
    // 防腐转换：userId/userNickname → id/name，映射只写这一处
    return User(id: resp.userId, name: resp.userNickname, avatar: resp.userAvatar);
  }
  @override
  Future<User?> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    try {
      return await _api.fetchMe();
    } catch (_) {
      await _storage.clear(); // token 失效：静默清凭证回落未登录
      return null;
    }
  }
  @override
  Future<void> logout() => _storage.clear();
}
```

Application 层——桥接 Provider 与 Controller（与 09 篇第 7 节完全一致）：

```dart
// lib/features/auth/application/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:mobi_crm/core/di/injection.dart';
import 'package:mobi_crm/features/auth/application/auth_controller.dart';
import 'package:mobi_crm/features/auth/domain/repository/auth_repository.dart';

/// ★ get_it → Riverpod 桥接（测试时 overrideWithValue 替换，见 Step 8）
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);
```

```dart
// lib/features/auth/application/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobi_crm/features/auth/application/auth_providers.dart';
import 'package:mobi_crm/features/auth/domain/entity/user.dart';

/// 登录态：state = 当前用户（null = 未登录）
/// AsyncValue 自带 loading/data/error 三态 = 免费的状态机（09 篇 8 节的取舍）
class AuthController extends AsyncNotifier<User?> {
  late final AuthRepository _repo = ref.read(authRepositoryProvider);
  @override
  Future<User?> build() => _repo.restoreSession(); // 冷启动自动登录
  Future<void> login(String account, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.login(account, password));
  }
  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }
}
```

DI 入口 `lib/core/di/injection.dart`：`final getIt = GetIt.instance;` 加一个 `@InjectableInit()` 标注的 `Future<void> configureDependencies() async => getIt.init();`（`injection.config.dart` 由 build_runner 生成，勿手改，import 它即可）。

入口与根组件。注意 `UncontrolledProviderScope`：main 里要先读 Provider 恢复主题，必须自持 container：

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:mobi_crm/app.dart';
import 'package:mobi_crm/core/di/injection.dart';
import 'package:mobi_crm/core/storage/prefs_repository.dart';
import 'package:mobi_crm/features/settings/application/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsRepository.initHive(); // 1. Hive（DI 单例依赖它）
  await configureDependencies();    // 2. get_it/injectable 全量注册
  final container = ProviderContainer();
  await container.read(themeControllerProvider.notifier).restore(); // 3. 恢复主题
  await SentryFlutter.init(         // 4. Sentry 包裹 runApp（第 12 篇方案）
    (options) {
      options.dsn = 'https://your-dsn@sentry.example.com/1';
      options.tracesSampleRate = 1.0; // 生产建议 0.2 以下
    },
    appRunner: () => runApp(
      UncontrolledProviderScope( // 持有已恢复主题的容器，而非全新 ProviderScope
          container: container, child: const MobiCrmApp()),
    ),
  );
}
```

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobi_crm/core/router/app_router.dart';
import 'package:mobi_crm/core/theme/app_theme.dart';
import 'package:mobi_crm/features/settings/application/theme_controller.dart';

class MobiCrmApp extends ConsumerWidget {
  const MobiCrmApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MobiCRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeControllerProvider), // 主题变化即时生效
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
```

Presentation 层——`LoginScreen`（`lib/features/auth/presentation/login/login_screen.dart`，ConsumerWidget）负责错误回流，页面本体只是 `Scaffold > Center > SizedBox(width: 360, child: LoginForm())`，关键代码：

```dart
// 错误回流：成功由路由守卫接管，这里只兜底展示失败（09 篇时序图终点）
ref.listen(authControllerProvider, (prev, next) {
  if (next.hasError) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_msg(next.error!))));
  }
});
// String _msg(Object e) => e is ApiException ? e.message : '登录失败，请稍后重试';
```

```dart
// lib/features/auth/presentation/login/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobi_crm/features/auth/application/auth_providers.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // 校验不过：到此为止
    // 事件上行：read + notifier，单向数据流唯一合法入口
    await ref.read(authControllerProvider.notifier)
        .login(_accountCtrl.text.trim(), _pwdCtrl.text);
    // 故意不写 context.go('/home')：跳转由 redirect 统一接管
  }
  @override
  Widget build(BuildContext context) {
    // 状态下行：watch + select，只订阅 isLoading
    final loading = ref.watch(authControllerProvider.select((s) => s.isLoading));
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('MobiCRM 登录', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          TextFormField(
            controller: _accountCtrl,
            decoration: const InputDecoration(
                labelText: '账号', prefixIcon: Icon(Icons.person)),
            validator: (v) => (v == null || v.trim().isEmpty) ? '请输入账号' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pwdCtrl,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: '密码', prefixIcon: Icon(Icons.lock)),
            validator: (v) => (v == null || v.length < 6) ? '密码至少 6 位' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: loading ? null : _submit, // 加载中禁点：防重复第一道闸
              child: loading ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('登录')),
          ),
        ],
      ),
    );
  }
}
```

至此 `flutter run`：未登录自动到 `/login`，登录成功自动落 `/home`，杀进程重启自动登录，401 时静默刷新——**09 篇的时序图全部落地**。

## 7. Step 5：列表分页模块（综合 06/07/11 篇）

Domain 层与 auth 同款四段式。Entity `Customer`（`lib/features/customer/domain/entity/customer.dart`，freezed）：`id/name` 必填，`company/phone/lastFollowUpAt` 可空。接口：

```dart
// lib/features/customer/domain/repository/customer_repository.dart
import 'package:mobi_crm/features/customer/domain/entity/customer.dart';

/// Dart 3 record 一次返回"数据 + 总数"，免建 PageResult 类
typedef CustomerPage = ({List<Customer> items, int total});

abstract class CustomerRepository {
  Future<CustomerPage> list({required int page, required int pageSize});
  Future<Customer> detail(String id);
  Future<void> addFollowUp(String customerId, String content);
}
```

```dart
// lib/features/customer/data/repository/customer_repository_impl.dart
import 'package:injectable/injectable.dart';

import 'package:mobi_crm/core/network/api_client.dart';
import 'package:mobi_crm/features/customer/domain/entity/customer.dart';
import 'package:mobi_crm/features/customer/domain/repository/customer_repository.dart';

@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._client);
  final ApiClient _client;

  Customer _fromMap(Map<dynamic, dynamic> e) => Customer(
      id: e['id'] as String, name: e['name'] as String,
      company: e['company'] as String?, phone: e['phone'] as String?,
      lastFollowUpAt: e['lastFollowUpAt'] as String?);
  @override
  Future<CustomerPage> list({required int page, required int pageSize}) async {
    final data = await _client
        .getJson('/customers', query: {'page': page, 'pageSize': pageSize});
    final items = (data['items'] as List).map(_fromMap).toList();
    return (items: items, total: (data['total'] as num).toInt());
  }
  @override
  Future<Customer> detail(String id) async =>
      _fromMap(await _client.getJson('/customers/$id'));
  @override
  Future<void> addFollowUp(String customerId, String content) async =>
      _client.postJson('/customers/$customerId/follow-ups', data: {'content': content});
}
```

Application 层——分页状态机（`PagingState` 即 09 篇 8 节同款 freezed 类）：

```dart
// lib/features/customer/application/customer_list_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get_it/get_it.dart';

import 'package:mobi_crm/core/di/injection.dart';
import 'package:mobi_crm/features/customer/domain/entity/customer.dart';
import 'package:mobi_crm/features/customer/domain/repository/customer_repository.dart';

part 'customer_list_controller.freezed.dart';

@freezed
class PagingState<T> with _$PagingState<T> {
  const factory PagingState({
    @Default([]) List<T> items,          // 已加载条目
    @Default(1) int page,                // 当前页码
    @Default(0) int total,               // 服务端总数
    @Default(true) bool hasMore,         // 是否还有下一页
    @Default(false) bool isLoading,     // 首屏/下拉刷新中
    @Default(false) bool isLoadingMore, // 上拉加载中
    Object? error,                       // 首屏错误（null 即成功）
  }) = _PagingState<T>;
}

final customerListControllerProvider =
    NotifierProvider<CustomerListController, PagingState<Customer>>(
        CustomerListController.new);

class CustomerListController extends Notifier<PagingState<Customer>> {
  static const pageSize = 20;
  late final CustomerRepository _repo = getIt<CustomerRepository>();
  @override
  PagingState<Customer> build() {
    Future.microtask(refresh); // 首次进入自动加载（build 必须同步返回初值）
    return const PagingState();
  }
  /// 首屏 / 下拉刷新
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null, page: 1, items: []);
    try {
      final r = await _repo.list(page: 1, pageSize: pageSize);
      state = state.copyWith(isLoading: false, items: r.items, total: r.total,
          hasMore: r.items.length < r.total);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
  /// 上拉加载下一页：isLoadingMore 即防重复闸门
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = state.page + 1;
      final r = await _repo.list(page: next, pageSize: pageSize);
      state = state.copyWith(isLoadingMore: false, page: next,
          items: [...state.items, ...r.items], // 不可变拼接，绝不原地改
          hasMore: state.items.length + r.items.length < r.total);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }
}
```

Presentation 层——四态齐全（加载/错误/空/数据），滚动距底 100px 自动 loadMore：

```dart
// lib/features/customer/presentation/list/customer_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_crm/core/widgets/empty_view.dart';
import 'package:mobi_crm/core/widgets/error_view.dart';
import 'package:mobi_crm/features/customer/application/customer_list_controller.dart';
import 'package:mobi_crm/features/customer/domain/entity/customer.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerListControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('客户'),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/home/settings')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(customerListControllerProvider.notifier).refresh,
        child: _Body(state: state),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});
  final PagingState<Customer> state;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ① 加载态（首屏）
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    // ② 错误态：给重试出口，别让用户死在白屏里
    if (state.error != null) {
      return ErrorView(
          onRetry: ref.read(customerListControllerProvider.notifier).refresh);
    }
    // ③ 空态
    if (state.items.isEmpty) return const EmptyView(message: '暂无客户');
    // ④ 数据态：滚动到距底 100px 内触发加载下一页
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 100) {
          ref.read(customerListControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.separated(
        // hasMore 时多占一个"底部加载指示器"位
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == state.items.length) {
            return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                    child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))));
          }
          final c = state.items[i];
          return ListTile(
            leading: CircleAvatar(child: Text(c.name.substring(0, 1))),
            title: Text(c.name),
            subtitle: Text('${c.company ?? '-'} · ${c.phone ?? '-'}'),
            onTap: () => context.go('/home/customer/${c.id}'), // 深链接式路径
          );
        },
      ),
    );
  }
}
```

`core/widgets` 两枚通用态组件（全 App 复用）：`ErrorView`（`lib/core/widgets/error_view.dart`：图标 + "加载失败"文案 + `onRetry` 回调的 TextButton，`Center + Column(min)` 布局）；`EmptyView`（`lib/core/widgets/empty_view.dart`：图标 + 文案，外层 `SingleChildScrollView(physics: AlwaysScrollableScrollPhysics)` + `ConstrainedBox(minHeight)` 保证空态也能下拉刷新——RefreshIndicator 要求子件可滚动）。两个都是 StatelessWidget，不到 20 行，不再占版面。

## 8. Step 6：详情与表单模块（精简走读）

详情页用 `FutureProvider.family`——**无交互的纯读取**，连 Notifier 都不用建；UI 用 `when(loading/error/data)` 三态渲染（与列表页同构，error 态给 `ref.invalidate` 重试）。核心就三行（`lib/features/customer/application/customer_detail_provider.dart`，import `get_it` 与 customer 模块类型后）：

```dart
/// family：一个 id 一份缓存；ref.invalidate 后自动重拉
final customerDetailProvider = FutureProvider.family<Customer, String>((ref, id) {
  return getIt<CustomerRepository>().detail(id);
});
```

表单模块重点讲**防重复提交**（第 10 篇知识的落地）。跟进记录表单核心逻辑：

```dart
// lib/features/customer/presentation/form/follow_up_form.dart（核心节选）
class _FollowUpFormState extends ConsumerState<FollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  bool _submitting = false; // ★ 防重复提交的本地闸门

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true); // 闸门先关：连点第二次直接短路
    try {
      final ok = await AsyncValue.guard(() => getIt<CustomerRepository>()
          .addFollowUp(widget.customerId, _contentCtrl.text.trim()));
      if (ok.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('提交失败，请重试')));
        }
      } else if (mounted) {
        ref.invalidate(customerDetailProvider(widget.customerId)); // 刷新详情
        context.pop(); // 回退
      }
    } finally {
      if (mounted) setState(() => _submitting = false); // 无论成败最后开闸
    }
  }  // build：FilledButton(onPressed: _submitting ? null : _submit, ...)
}
```

三道防线：**按钮禁用**（可见反馈）→ **`_submitting` 短路**（逻辑保险）→ 服务端幂等键（后端兜底）。企业弱网环境只做第一道必出重复记录。

## 9. Step 7：设置页

```dart
// lib/features/settings/application/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'package:mobi_crm/core/di/injection.dart';
import 'package:mobi_crm/core/storage/prefs_repository.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

class ThemeController extends Notifier<ThemeMode> {
  late final PrefsRepository _prefs = getIt<PrefsRepository>();
  @override
  ThemeMode build() => ThemeMode.system; // 默认跟系统
  /// main() 里恢复持久化的主题（见 Step 4 的 main.dart）
  Future<void> restore() async {
    state = await _prefs.readThemeMode() ?? ThemeMode.system;
  }
  Future<void> setMode(ThemeMode mode) async {
    state = mode;                      // 先改内存：UI 即时生效
    await _prefs.saveThemeMode(mode); // 再落盘：重启保留
  }
}
```

```dart
// lib/features/settings/presentation/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobi_crm/features/auth/application/auth_providers.dart';
import 'package:mobi_crm/features/customer/application/customer_list_controller.dart';
import 'package:mobi_crm/features/settings/application/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(children: [
        ...ThemeMode.values.map((m) => RadioListTile<ThemeMode>(
            value: m, groupValue: mode,
            title: Text(switch (m) {
              ThemeMode.system => '跟随系统',
              ThemeMode.light => '浅色',
              ThemeMode.dark => '深色',
            }),
            onChanged: (v) => ref.read(themeControllerProvider.notifier).setMode(v!))),
        const Divider(),
        ListTile(leading: const Icon(Icons.logout), title: const Text('退出登录'),
            onTap: () => _logout(ref)),
      ]),
    );
  }
  /// 退出清理链路：能显式调用的就显式（09 篇 11 节结论，不上事件总线）
  Future<void> _logout(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout(); // ① 清 token，state=null
    ref.invalidate(customerListControllerProvider); // ② 显式清已知缓存
    // ③ 路由由 redirect 自动回 /login —— UI 不参与任何清理后的跳转
  }
}
```

对照 09 篇第 11 节：这就是"跨模块通信用 Provider + 显式调用"的落地示范。

## 10. Step 8：质量收尾（引用 12/14 篇）

### 10.1 单元测试：mock 登录全流程

架构的回报时刻——**不开网络、不起真机，测完登录状态机**，用 mocktail（无 codegen，文档里少一步构建）：

```dart
// test/features/auth/auth_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobi_crm/features/auth/application/auth_controller.dart';
import 'package:mobi_crm/features/auth/application/auth_providers.dart';
import 'package:mobi_crm/features/auth/domain/entity/user.dart';
import 'package:mobi_crm/features/auth/domain/repository/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  setUp(() => repo = MockAuthRepository());
  // ★ 桥接替换点：override 掉 get_it 桥，注入 mock
  ProviderContainer createContainer() {
    final c = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(c.dispose);
    return c;
  }
  test('登录成功：state 变为 AsyncData(user)', () async {
    final user = User(id: 'u1', name: '张三');
    when(() => repo.restoreSession()).thenAnswer((_) async => null);
    when(() => repo.login('zhang', '123456')).thenAnswer((_) async => user);
    final container = createContainer();
    final controller = container.read(authControllerProvider.notifier);
    await container.pump(); // 让 build() 里的 restoreSession 完成
    await controller.login('zhang', '123456');
    expect(container.read(authControllerProvider).value, user);
    verify(() => repo.login('zhang', '123456')).called(1);
  });
}
```

`flutter test` 全绿，0 次真实网络——这就是 09 篇"可测试"承诺的兑付。

### 10.2 Widget 测试：登录表单校验

```dart
// test/widget/login_form_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobi_crm/features/auth/application/auth_providers.dart';
import 'package:mobi_crm/features/auth/domain/repository/auth_repository.dart';
import 'package:mobi_crm/features/auth/presentation/login/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('空账号提交：出现校验提示，不发请求', (tester) async {
    final repo = MockAuthRepository();
    when(() => repo.restoreSession()).thenAnswer((_) async => null);
    when(() => repo.login(any(), any()))
        .thenAnswer((_) async => throw Exception('不应被调用'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('请输入账号'), findsOneWidget); // 校验拦截
    verifyNever(() => repo.login(any(), any()));
  });
}
```

### 10.3 Sentry 验证

`main.dart` 已在 Step 4 就位。收尾动作：在登录按钮里临时 `throw` 一次，到 Sentry 后台确认收到事件（含设备信息、路由面包屑）；错误分类与上报策略见第 12 篇。

## 11. 下一步扩展方向（可练手的需求清单）

| 方向 | 要做什么 | 复用本骨架的哪里 | 主要新知识 |
|---|---|---|---|
| IM 即时沟通 | WebSocket 长连接 + 消息流 | Data 层新增 `datasource/ws/`，Notifier 持流 | 05/06/09 |
| 文件上传 | 客户资料/名片 OCR | `ApiClient` 加 multipart，表单加进度条 | 07 |
| 离线同步 | 本地缓存 + 断网可用 | Repository 变多数据源（Hive + dio） | 08/09（UseCase 层登场时机） |
| 推送 | 厂商通道 + 前台路由联动 | 真正全局低频事件：09 篇事件总线用武之地 | 平台通道 |
| 扫码/地图 | 客户签到打卡 | `core/` 新增能力模块 | 混合开发（16 篇预告） |

练手顺序建议：先做文件上传（一天量级），最后碰离线同步（全系列知识点联考）。

## 12. 附录：常见编译报错速查（新手前 10 坑）

| # | 报错/现象 | 原因 | 解法 |
|---|---|---|---|
| 1 | `Target of URI doesn't exist: 'xxx.freezed.dart'` | 建了类没跑 build_runner | `dart run build_runner build --delete-conflicting-outputs` |
| 2 | `The getter 'copyWith' isn't defined ...` | freezed 生成文件过期/缺失 | 同上；改注解后必须重跑 |
| 3 | `The part 'xxx.g.dart' can't be found` | `part` 声明了却没生成 | 确认 json_serializable 在 dev_dependencies，重跑构建 |
| 4 | `HiveError: Cannot open box...` | 忘了 initHive/openBox | main 里最先调 `PrefsRepository.initHive()` |
| 5 | 运行时 `type 'Null' is not a subtype of String` | 后端字段可空却声明非空 | DTO 字段改可空或加默认值，别 `as String` 硬转 |
| 6 | `Bad state: No ProviderScope found` | runApp 没包 ProviderScope | `runApp(const ProviderScope(child: App()))` |
| 7 | 页面循环跳转/闪登录页 | redirect 在自动登录 loading 期误判 | Step 3 的 `isLoading && !hasValue` 前置判断 |
| 8 | `Missing concrete implementation of ...` | 接口加方法后实现类未补 | IDE 灯泡补全再逐个实现 |
| 9 | Android `Namespace not specified` | 老模板 gradle 缺 namespace | `android/build.gradle` 加 `namespace 'com.company.mobi_crm'` |
| 10 | pub get 卡死/超时 | 默认源境内不稳 | 配镜像 `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL` |

## 自测清单

- [ ] 八个 Step 的"完成标志"全部打勾了吗？
- [ ] 能不查文档手写"新模块四段式"吗？能解释 `GoRouterRefreshNotifier` 这座桥为什么存在吗？
- [ ] 能说清"token 永不出 Data 层"带来的三个好处吗？
- [ ] 拔掉网线跑 `flutter test`——登录用例还是绿的吗？（是，则架构落地成功）
- [ ] 防重复提交的三道防线能背出来吗？
- [ ] 退出登录的清理链路涉及几个模块？各自如何被触发？

## 延伸阅读

- 回看：[应用架构设计](09-应用架构设计.md)（本篇每一步的理论出处）、[网络层设计](07-网络层设计.md)（401 并发锁完整版）、[性能优化](13-性能优化.md)（列表与重建优化）、[企业级通用能力](11-企业级通用能力.md)（分页、空态、埋点的通用做法）
- 官方：go_router 与 Riverpod 集成示例（`docs.flutter.cn`）；Sentry Flutter 文档 `docs.sentry.io/platforms/flutter`。下一站：[版本演进与迁移速查](16-版本演进与迁移速查.md)——升级 SDK 前必查；然后是能力扩展清单（见上节）
