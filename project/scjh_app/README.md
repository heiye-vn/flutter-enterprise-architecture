# scjh_app

企业级 Flutter 应用骨架 —— 业务场景参考真实 CRM / 项目管理系统，用于把 `docs/` 里的教程落到可运行的工程上。

当前状态：**可运行**。内置内存 Mock 后端，`flutter run` 即可走完「登录 → 客户列表 → 客户详情 → 扫码 / 定位 → 设置」全链路，不需要任何服务端。

---

## 快速开始

```bash
flutter pub get

# 代码生成（首次拉代码、或改了 freezed / json_serializable 标注后必须执行）
dart run build_runner build

flutter run
```

演示账号：**任意账号 + 6 位以上密码**。

### 常用启动参数

```bash
# 接真实后端
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=https://your-host/api/v1 \
  --dart-define=FLAVOR=dev
```

### 本机代理可能导致测试失败

如果开了系统代理，`flutter test` 会报 `Unable to connect to flutter_tester process: WebSocketException`。
原因是测试进程的本地 WebSocket 被代理拦截，加环境变量即可：

```bash
NO_PROXY="127.0.0.1,localhost,::1" flutter test
```

### Android 构建前置条件

1. **NDK 28.2.13676358**（Flutter 3.47 默认版本）。没有会在 `assembleDebug` 阶段报
   `Android sdkmanager did not install NDK ...`。用 SDK Manager 或新版 CLI 安装：
   ```bash
   "$LOCALAPPDATA/Android/Sdk/cmdline-tools/latest/bin/android.exe" sdk install "ndk;28.2.13676358"
   ```
2. **`android/gradle.properties` 里关了 Kotlin 增量编译**。Windows 上杀毒软件/文件索引
   会锁住 `caches-jvm` 目录，报 `Could not close incremental caches`。
   等把项目目录加入杀软白名单后，可以删掉 `kotlin.incremental=false` 恢复增量构建。
3. 首次构建要下载 AGP / Kotlin / 依赖，走代理时可能十几分钟，之后就快了。

验证过可产物：`flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`。

### 构建产物体积

同一次代码，不同构建方式差 10 倍以上：

| 产物 | 体积 | 用途 |
|---|---|---|
| `flutter build apk --debug` | **200 MB** | 只给 `flutter run` / 热重载用，**不要拿它对比线上包** |
| `flutter build appbundle --release` | 51 MB（含 3 个 ABI） | 上传应用商店，用户实际下载约 18 MB |
| `flutter build apk --release --split-per-abi` | **arm64 18.4 MB / armv7 16.0 MB** | 真机安装、内测分发 |

debug 包为什么这么大：里面塞了 104 MB 的 `kernel_blob.bin`（Dart JIT 内核，热重载靠它）、
3 个架构各一份 `libflutter.so`（合计 112 MB）、15 MB 的 Vulkan 校验层。
这些在 release 包里**全部不存在**。

release（arm64）的构成基本是固定的：

```
libflutter.so   11.8 MB   Flutter 引擎（固定成本）
libapp.so        6.5 MB   你的 Dart 代码 + 用到的框架代码（AOT）
classes.dex      0.9 MB   Android 胶水层
其余             0.6 MB
```

业务量增长只会撑大 `libapp.so`：从 0 个页面加到 200 个页面，大概多 2–4 MB，
不会出现"功能翻倍、体积翻倍"。

发布命令：

```bash
# 商店（推荐）
flutter build appbundle --release

# 内测分发
flutter build apk --release --split-per-abi

# 需要代码混淆时（保护 Dart 符号，顺带减小体积）
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```

---

## 目录结构

按 **feature-first + 四段式分层** 组织，与 `docs/tutorial_01/15-实战项目-企业App骨架.md` 保持一致。

```text
lib/
├── main.dart                    # 入口：绑定 → 注册依赖 → runApp
├── app.dart                     # 根组件：主题 + 路由 + 本地化
├── core/
│   ├── config/env_config.dart       # --dart-define 注入的环境与开关
│   ├── constants/storage_keys.dart  # 存储键集中管理
│   ├── error/app_exception.dart     # sealed 异常体系 + 统一文案
│   ├── network/
│   │   ├── api_client.dart          # 唯一网络出口，解壳 + 异常翻译
│   │   ├── api_envelope.dart        # 统一响应壳
│   │   ├── auth_interceptor.dart    # 注入 token + 401 串行刷新重放
│   │   └── page_result.dart         # 分页结果形状
│   ├── storage/
│   │   ├── secure_storage.dart      # token（Keychain / Keystore）
│   │   └── prefs_repository.dart    # 偏好（shared_preferences）
│   ├── router/
│   │   ├── app_router.dart          # GoRouter + 登录守卫 + 底部导航壳
│   │   └── home_shell.dart
│   ├── theme/app_theme.dart         # 设计令牌 + 亮/暗主题
│   ├── di/injection.dart            # get_it 装配
│   ├── utils/formatters.dart
│   └── widgets/{empty_view,error_view}.dart
├── features/
│   ├── auth/          # domain / data / application / presentation
│   ├── customer/      # 同上，列表分页 + 详情 + 原生能力调用
│   └── settings/      # 主题切换、环境信息、退出登录
└── platform/          # 原生能力抽象层（可替换实现）
    ├── permission/    # CapabilityPermission + PermissionGate 降级 UI
    ├── scanner/       # ScannerService 抽象 + Fake 实现
    └── location/      # LocationService 抽象 + Fake 实现
```

每层职责：

| 层 | 能做 | 不能做 |
|---|---|---|
| `domain` | 定义实体、仓库契约 | 不 import dio / flutter / json |
| `data` | DTO、数据源、仓库实现、DTO→实体转换 | 不做业务判断 |
| `application` | Riverpod 控制器、状态编排 | 不碰 Widget、不碰 token |
| `presentation` | Widget、交互、错误回流 | 不直接调 API |

---

## 几个关键设计

### 1. 分层边界：token 不出 Data 层

`AuthRepositoryImpl` 负责存 token、写缓存、恢复会话；`AuthController` 只知道「登录成功/失败」。
所以 401 自动刷新可以在拦截器里对全 App 透明完成，页面一行代码都不用改。

### 2. 401 刷新是串行化的

`AuthInterceptor._refreshOnce()` 用 `_refreshing ??=` 保证并发 401 只发一次 refresh，
其余请求等待同一个 Future。否则 10 个请求同时 401 会把 refresh token 打失效。

### 3. 路由守卫用 refreshListenable，不是重建 GoRouter

`authControllerProvider` 变化 → `RouterRefreshNotifier` 通知 → GoRouter 重算 redirect。
只在布尔值真的变化时才 `notifyListeners()`，避免用户信息变动触发全量重定向。

### 4. 首帧就知道登录态

`main()` 里 `await configureDependencies()` → `SecureStorage.init()` → `AuthRepository.restoreSession()`，
全部在 `runApp` 之前完成。所以不会出现「闪一下登录页再跳回首页」。

### 5. 两种 loading 分开

`AsyncValue.loading` = 首屏没数据，显示转圈；
`CustomerListState.loadingMore` = 已有数据在加载下一页，只在底部显示小菊花。
混在一起是列表页最常见的体验问题。

### 6. 空态/错误态必须可滚动

`EmptyView` / `ErrorView` 都用 `SingleChildScrollView + ConstrainedBox(minHeight)` 包了一层。
`RefreshIndicator` 要求子节点可滚动，否则空态下没法下拉刷新。

---

## 设计系统（自建组件库）

没有引第三方 UI 库。`core/theme/` + `core/widgets/` 就是一套小型设计系统。

### 令牌层

| 文件 | 内容 |
|---|---|
| `core/theme/app_tokens.dart` | `AppSpacing`（4 的倍数阶梯）、`AppRadius`、`AppDuration`、`AppPalette`、`AppColors`、`AppTypography` |
| `core/theme/app_theme.dart` | 把令牌灌进 `ThemeData`，统一 AppBar / Card / Input / Button / NavigationBar / Dialog / SnackBar 的形状 |

`AppColors` 是 `ThemeExtension`，随亮暗主题自动切换，不会出现"深色模式下手写白色背景"这种问题：

```dart
final colors = AppColors.of(context);
Container(color: colors.surface, ...)
```

### 组件层（`core/widgets/`）

统一从 `app_widgets.dart` 导入：

| 组件 | 说明 |
|---|---|
| `AppCard` | 卡片：0.5px 描边、无阴影，亮暗两套都干净 |
| `AppTag` | 标签：5 种语义色 × soft / outline 两种样式 |
| `AppAvatar` / `AppAvatarHeader` | 头像：姓名首字 + **名字哈希决定的稳定底色** |
| `AppButton` | 按钮：primary / secondary / ghost / danger × medium / small，内置 loading 与禁用态 |
| `AppSearchBar` | 搜索条：胶囊外形、清除按钮跟随输入、可选扫码入口 |
| `AppListTile` | 列表项：leading + 三行文本 + trailing + chevron |
| `AppSection` / `AppInfoRow` | 分组卡片 + 键值行，自动插分隔线、标签列对齐 |
| `AppTextField` | 外置标签输入框（中文表单不用上浮 label，视觉更稳） |
| `AppSkeleton` / `AppSkeletonList` | 骨架屏：移动高光带，形状与真实列表对齐 |
| `EmptyView` / `ErrorView` | 空态 / 错误态，保证在 `RefreshIndicator` 下可滚动 |

### 活文档

「我的 → 组件预览」，或直接访问 `/dev/components`。全部令牌与组件在**亮色 / 暗色**两套主题下一屏可查。改样式先在这里看，再回业务页。

> Flutter 里 UI 库不能混用：每套库自带独立的 Theme、字号阶梯和间距基准，
> 混用会出现按钮高度、水波纹半径不一致这类割裂感。这套自建组件是唯一来源。

---

## 扩展原生能力

这是本骨架最重要的一个设计点：**业务页面不 import 任何插件**，只依赖 `platform/` 下的抽象接口。

以扫码为例，当前是 `FakeScannerService`（延迟 700ms 返回演示编码 `KH20261000`）。
换成真实插件只需三步：

```dart
// 1. 新增实现
// lib/platform/scanner/mobile_scanner_service.dart
class MobileScannerService implements ScannerService {
  @override
  Future<CapabilityPermission> ensurePermission() async { /* permission_handler */ }

  @override
  Future<ScanResult?> scan(BuildContext context) async {
    // 推一个扫码页，返回 ScanResult
  }
}

// 2. 换 DI 注册（lib/core/di/injection.dart）
getIt.registerLazySingleton<ScannerService>(() => MobileScannerService());

// 3. 页面代码零改动
```

建议的接入顺序（难度递进）：

| 阶段 | 能力 | 推荐包 | 学到什么 |
|---|---|---|---|
| Lv1 | 扫码 | `mobile_scanner` | 权限、相机生命周期、页面回传 |
| Lv1 | 定位 + 地图 | `geolocator` + `flutter_map` | 持续数据流、坐标纠偏（WGS84→GCJ-02） |
| Lv2 | 蓝牙设备 | `flutter_blue_plus` | 扫描/连接/订阅特征值/超时重连的异步状态机 |
| Lv3 | 离线优先 | `drift` | 本地库、同步队列、冲突合并 |
| Lv4 | 自写 Plugin | `pigeon` | 平台通道、强类型接口生成 |

> `PermissionGate` 已经把「权限被拒时的降级 UI」抽象好了：
> 扫码不可用 → 手动输入编号；定位不可用 → 手工选点位。
> 新增能力时记得先想清楚降级路径，再写实现。

---

## Mock 与真实后端

| 开关 | 位置 | 说明 |
|---|---|---|
| `USE_MOCK` | `lib/core/config/env_config.dart` | 默认 `true`，走内存假数据 |
| Mock 数据源 | `features/*/data/datasource/*_api_mock.dart` | 与 `*_api.dart` 的接口一一对应 |
| 真实数据源 | `features/*/data/datasource/*_api.dart` | 走 `ApiClient` |

Mock 数据是确定性生成的：48 条客户、pageSize 20，够翻 3 页，
能验证分页、下拉刷新、加载更多、空态四条链路。

`CustomerApiMock.demoScannableCode` 与 `FakeScannerService.demoCode` 有意对齐，
扫码后能精确过滤出一条记录，用来验证「扫码 → 查询」闭环。

---

## 测试

```bash
NO_PROXY="127.0.0.1,localhost,::1" flutter test
```

已覆盖：

- `test/core/utils/formatters_test.dart` — 日期格式化边界
- `test/core/widgets/empty_view_test.dart` — 空态渲染与溢出
- `test/features/auth/login_form_test.dart` — 表单校验（需注册 `PrefsRepository`）
- `test/features/customer/customer_api_mock_test.dart` — 分页边界、关键字命中、越界页码

---

## 下一步待办

- [ ] 客户新增/编辑表单（复杂表单、级联选择、附件上传）
- [ ] 审批流只读详情 + 底部操作栏（状态机）
- [ ] 树形选择组件（对标原项目的 `da-tree`）
- [ ] `drift` 离线缓存 + 同步队列
- [ ] `ScannerService` / `LocationService` 的真实实现
- [ ] 用 `injectable` 替换手写 DI（可选）
