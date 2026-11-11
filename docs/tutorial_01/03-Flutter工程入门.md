# 03 Flutter 工程入门

> **本篇目标**：在一台干净的 Windows 机器上搭好 Flutter 全套开发环境，创建并运行第一个项目，吃透"热重载（Hot Reload）"的边界，看懂 `pubspec.yaml` 与依赖体系，建立日常调试工作流，最后沉淀出一份可直接复用的**标准企业项目初始化清单**。
>
> **前置阅读**：[项目总览](00-README.md)（版本口径：**Flutter 3.47 / Dart 3.13**，空安全强制）、[Dart 语言进阶](02-Dart语言进阶.md)。
>
> **学完你能做什么**：
> - 独立完成环境搭建，`flutter doctor` 出现任何红叉都能定位原因
> - 说清热重载保留什么、丢什么、什么时候必须重启
> - 像读 `package.json` 一样读 `pubspec.yaml`，并执行企业级选包标准
> - 用 DevTools + 断点 + 日志完成日常问题定位
> - 按企业标准初始化一个新 Flutter 项目（目录、依赖、lint、README 一口气到位）

---

## 1. 环境搭建（Windows）

### 1.1 安装方式怎么选

Flutter SDK 有三种获取方式，企业里我建议前两种：

| 方式 | 命令 / 入口 | 适用场景 | 说明 |
|------|------------|---------|------|
| **git clone（推荐）** | `git clone -b stable https://github.com/flutter/flutter.git C:\src\flutter` | 日常开发 | 升级 = `git pull`，切版本 = `git checkout`，团队可精确锁定 SDK 版本 |
| 官方压缩包 | [官方归档页](https://docs.flutter.dev/release/archive)（国内可从中文镜像站 [docs.flutter.cn](https://docs.flutter.cn) 进入） | 网络受限 / CI 固定版本 | 解压即用，版本由你完全控制 |
| 包管理器（choco/scoop） | `choco install flutter` | 个人尝鲜 | **不建议企业使用**：版本不受你控制，CI 上还要重装 |

安装铁律：

1. **路径不要有中文和空格**（`C:\src\flutter` 是好选择，`D:\软件\flutter` 是事故预备）。
2. **不要装进 `Program Files`**：那需要管理员权限，后续 `dart pub get` 写缓存会碰到权限问题。
3. 把 `C:\src\flutter\bin` 加进系统 **Path** 环境变量。建议手动改：`Win + R → sysdm.cpl → 高级 → 环境变量 → Path → 新建`。（别用 `setx PATH ...`，它有 1024 字符截断风险，PATH 一长就翻车。）

验证安装，**新开一个终端**执行：

```bash
flutter --version
# 输出形如：
# Flutter 3.x.x • channel stable • https://github.com/flutter/flutter
# Framework • ... (revision ...) (2024-xx-xx)
# Engine • ...
# Tools • Dart 3.x • <SDK 路径>
```

### 1.2 国内镜像（强烈建议第一时间配）

Flutter 第一次运行要从 Google 侧下载 Dart SDK 与构建产物，pub 依赖默认从 pub.dev 拉取。国内网络下**必配**两个环境变量（相当于给包管理器换 npm 源）：

| 环境变量 | 作用 | 推荐值 |
|---------|------|--------|
| `PUB_HOSTED_URL` | pub 包下载源（≈ npm 的 registry） | `https://pub.flutter-io.cn` |
| `FLUTTER_STORAGE_BASE_URL` | Flutter 引擎产物 / Dart SDK 下载源 | `https://storage.flutter-io.cn` |

PowerShell 永久写入用户级环境变量：

```powershell
[Environment]::SetEnvironmentVariable('PUB_HOSTED_URL', 'https://pub.flutter-io.cn', 'User')
[Environment]::SetEnvironmentVariable('FLUTTER_STORAGE_BASE_URL', 'https://storage.flutter-io.cn', 'User')
```

写完**重开终端**再跑 `flutter --version`（首次会触发 Dart SDK 下载，此时镜像生效）。

> **坑**：这两个变量是全局的。如果你的团队有私有 pub 仓库（pub 私服），CI 上会覆盖这两个值——本地配置不要提交到代码仓库，README 里写清楚即可。

### 1.3 flutter doctor：体检报告怎么读

```bash
flutter doctor
```

典型输出（版本号以你本机为准）：

```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.x.x, on Microsoft Windows [Version 10.x])
[√] Windows Version
[!] Android toolchain - develop for Android devices
    ! Some Android licenses not accepted. To resolve this, run:
       flutter doctor --android-licenses
[√] Chrome - develop for the web
[√] Android Studio (version 2024.x)
[√] Connected device (2 available)
[√] Network resources
```

读法：

- `√` 正常；`!` 有问题但可跳过（比如不开发 Windows 桌面，Visual Studio 项可以无视）；`✗` 阻断性问题。
- 每一项都有"体检指标"：Flutter SDK、Android 工具链（toolchain）、IDE 插件、已连接设备。
- **加 `-v` 看详情**：`flutter doctor -v` 会打印每一项的具体路径、版本，报错排查第一入口。
- Android 许可未接受是最常见的 `!`：按提示执行 `flutter doctor --android-licenses` 一路 `y` 即可。

### 1.4 Android Studio 与 Android SDK

即使你用 VS Code 写代码，**Android Studio 依然要装**——它承担两件事：Android SDK 管理器 + 模拟器管理器（相当于前端的"浏览器由别人管，但 Chrome 还是要装"）。

安装后（首次启动会自动下载 SDK）确认三件事：

1. **SDK 平台**：`Settings → Languages & Frameworks → Android SDK → SDK Platforms`，勾一个近期稳定版本的 API Level。
2. **SDK 工具**：同页面 `SDK Tools` 标签，确认 `Android SDK Platform-Tools`、`Android Emulator`、`Android SDK Command-line Tools (latest)` 已勾选——**最后这个是 flutter doctor 报 licenses 问题的前置条件**。
3. **JDK 不用单独装**：新版 Android Studio 自带 JetBrains Runtime，Gradle 构建直接用它。

`adb`（Android 调试桥，Android Debug Bridge）位于 `%LOCALAPPDATA%\Android\Sdk\platform-tools`，真机调试靠它。后面把 Flutter 工程跑在 Android 上时，Gradle 会自动从这个 SDK 目录取工具链。

### 1.5 模拟器与真机

**模拟器（Emulator）**：

```bash
flutter emulators                 # 列出本机可用模拟器
flutter emulators --launch <id>   # 启动一个
```

更常用的是在 Android Studio 里 `Device Manager → Create Device` 建一台（推荐 Pixel 系列 + 近期 API Level）。内存 16GB 的开发机开模拟器毫无压力，8GB 会卡但能用。

**真机调试**（比模拟器更能暴露真问题，企业习惯：**日常真机优先**）：

1. 手机开"开发者选项"：`设置 → 关于手机 → 连点"版本号" 7 次`。
2. `开发者选项 → USB 调试` 打开，USB 连电脑。
3. 终端验证：

```bash
adb devices
# List of devices attached
# XXXXXXXX    device     ← 出现这个就是通了；显示 unauthorized 就去手机上点允许弹窗
```

> **坑**：部分国产手机需要额外开"USB 安装"权限，个别品牌还要装厂商驱动（以厂商文档为准）。MIUI/ColorOS 等定制系统还会默认杀后台，调试时把应用设为"电池不优化"。

### 1.6 VS Code 插件与常用命令

插件清单（按优先级）：

| 插件 | 作用 | 必要性 |
|------|------|--------|
| **Flutter**（Dart-Code.flutter，会自动带上 Dart 分析器） | 调试运行、代码补全、重构、热重载快捷键 | 必装 |
| **Error Lens** | 错误直接内联在代码行尾——Dart 分析器很严格，这个插件体验差距巨大 | 强烈建议 |
| **Awesome Flutter Snippets** | `stless`/`stful` 快速生成组件骨架 | 建议 |

装完 Flutter 插件后，VS Code 状态栏右下角会出现**设备选择器**（点它切换目标设备），`F5` 即可调试运行。首次 F5 会生成 `.vscode/launch.json`：

```json
// .vscode/launch.json —— F5 调试入口，相当于前端的 launch 配置
{
  "configurations": [
    {
      "name": "flutter",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart"
    }
  ]
}
```

命令面板（`Ctrl+Shift+P`）里常用的 `Flutter:` / `Dart:` 前缀命令：`Flutter: New Project`、`Dart: Open DevTools`、`Flutter: Clean` 等，具体命令名以插件提示为准。

---

## 2. 第一个项目：创建、运行、热重载

### 2.1 flutter create：一次到位

```bash
flutter create enterprise_app --org com.acme --project-name enterprise_app --platforms android,ios,web
```

参数解释：

- `--org com.acme`：组织反向域名。**企业里这一项必须第一次就想清楚**——它决定了 Android 的 `applicationId` 和 iOS 的 Bundle ID（`com.acme.enterprise_app`），线上应用改包名等于换身份，存量用户、推送、支付、深链全部受影响。
- `--project-name`：必须是合法 Dart 标识符（小写 + 下划线），相当于 `package.json` 的 `name`。
- `--platforms`：生成哪些平台的宿主工程。不传则在 Windows 上默认生成 `android/ios/web/windows` 四套（是的，Windows 上也会生成你编译不了的 `ios/` 目录，这是正常的——方便 mac 同事接手）。

### 2.2 跑起来：Chrome 与 Android 模拟器

```bash
flutter devices        # 列出当前所有可用设备
flutter run -d chrome  # 明确指定跑在 Chrome
flutter run            # 只有一台设备时直接跑
```

两种目标端的体感差异，先有预期：

| | Chrome（Web 端） | Android 模拟器 / 真机 |
|---|---|---|
| 启动速度 | 快，适合纯 UI 调整 | 首次 Gradle 构建慢（几分钟很正常），之后增量很快 |
| 热重载 | **不支持**，只有热重启 | 支持，核心生产力 |
| 还原能力 | 移动端交互（手势、键盘、权限）不真实 | 真实 |
| 适合场景 | 验证布局/样式、快速预览 | 日常主力 |

结论：**UI 初稿在 Chrome 上飞快地写，每天至少一次在模拟器/真机上核对**。桌面端（Windows）用 `flutter run -d windows`，本地调试窗口应用也很方便。

### 2.3 热重载 vs 热重启：原理与边界

这是 Flutter 生产力和 React Fast Refresh 同级别的核心机制，必须搞清楚边界，不然你会陷入"我明明改了为什么没生效"的自我怀疑。

**热重载（Hot Reload，`r` 键或保存文件触发）的原理**：

1. Debug 模式下 Flutter 使用 **JIT（Just-In-Time，即时编译）** 运行 Dart 代码。
2. 文件保存后，工具链把**改动的库**增量编译成 Dart Kernel（`.dill`）的差量。
3. 差量推送到运行中的 Dart VM，VM 热替换受影响类的代码。
4. 框架收到 `reassemble` 信号，**从根开始重新 build Widget 树**——注意：是 Widget 重建，而每个组件持有的 **State 对象不重建**，所以 `_counter` 之类的字段值被保留。

一句话：**代码是新的，状态是旧的**。这就是它像 React Fast Refresh 的地方。

**热重启（Hot Restart，`R` 键）**：重新执行 `main()`，所有 State 清空、路由回到首页，但原生层（Android Activity / iOS ViewController）不重建。

边界对照表：

| 改动 | 热重载（r） | 热重启（R） | 完全重启（stop + run） |
|------|-----------|-----------|----------------------|
| 组件 build 内的 UI / 样式 | 生效，**State 保留** | 生效，State 清空 | 生效 |
| 工具函数、网络层等非组件代码 | 生效 | 生效 | 生效 |
| `main()` / `runApp` 之前的初始化逻辑 | **不会重跑**（入口早已执行过） | **会重跑** | 会重跑 |
| `initState()` 内的修改 | 对已存在的 State **不会重跑**（State 没重建） | 重跑 | 重跑 |
| 全局变量的**当前值** | 保留旧值（框架不回滚运行时状态） | 重置为初始值 | 重置 |
| 新增依赖（`pub add`）、新增 assets 资源 | 不生效 | 不生效 | **必须完全重启** |
| Android/iOS 原生代码、manifest、签名配置 | 不生效 | 不生效 | **必须完全重启** |
| 枚举增删值等结构性变更 | 部分版本受限（以[官方文档](https://docs.flutter.dev/tools/hot-reload)为准） | 生效 | 生效 |

与前端 HMR 的两点关键差异：

1. React Fast Refresh 改非组件模块（工具函数）会触发整页 reload 丢 state；Flutter 热重载对**任何 Dart 代码改动**都只重 build 树、保 State，保留面更大。
2. Flutter Web 端不支持热重载只有热重启——所以调试 Web 时你的主力键是 `R` 不是 `r`。

还有一条常识：**Release 模式是 AOT（Ahead-Of-Time）编译，没有 JIT，没有热重载**。做性能验证用 `flutter run --profile`（接近 release 性能但保留观测能力），详见[性能优化](13-性能优化.md)。

---

## 3. 工程结构：目录职责与 main.dart

### 3.1 目录总览

```
enterprise_app/
├── android/               # Android 宿主工程（内嵌一个 Gradle 工程，相当于 RN 的 android 目录）
│   └── app/
│       └── build.gradle.kts   # applicationId、版本号、minSdk 都在这
├── ios/                   # iOS 宿主工程（Xcode 工程；Windows 上只读不改）
├── web/                   # Web 宿主（index.html、manifest）
├── windows/                # Windows 桌面宿主（Windows 上 create 默认生成）
├── lib/                   # ★ 你 95% 的代码都在这里，相当于 src/
├── test/                  # 单元 / Widget 测试（≈ vitest 的 tests/），见[测试体系](12-测试体系.md)
├── assets/                # 图片、字体、静态配置（需在 pubspec.yaml 声明才可用）
├── pubspec.yaml           # 依赖与元信息（≈ package.json）
├── pubspec.lock           # 锁文件（≈ package-lock.json，**必须提交**）
├── analysis_options.yaml  # lint 配置（≈ .eslintrc）
└── .gitignore             # 模板自带，build/、.dart_tool/ 已忽略
```

前端视角的三个要点：

- `android/`、`ios/` 等目录是**宿主工程（host project）**，Flutter 产物通过嵌入它们打包成原生应用。日常业务开发完全不碰；只在配置签名、权限（manifest）、原生插件时进出。这个心智和 Electron 的 `main.js` 壳、RN 的原生壳一致。
- `.dart_tool/` 是生成目录（依赖解析缓存、配置），**不提交**——它的部分角色相当于 `node_modules`。`build/` 是构建产物，也不提交。
- `analysis_options.yaml` 默认引入 `package:flutter_lints/flutter.yaml`（官方推荐 lint 集，≈ `eslint-config-airbnb` 的官方版）。企业会在此基础上加码，见第 8 节清单。

**关于 `android/` 目录的一个高频困惑**：网上教程给的 `build.gradle` 往往和你本地生成的**长得不一样**，原因是 Flutter 的 Android 模板随 SDK 改过多次——Groovy DSL → Kotlin DSL（`.kts`）、`kotlin-android` 插件 → **AGP 9 的 built-in Kotlin**（3.44 起，老写法会直接构建失败）。**结论：以你 `flutter create` 生成的模板为准，不要照抄教程；老项目升级按官方迁移指南走**（详见 [14 篇 1.5](14-工程化与发布.md)）。

同理，`ios/` 从 3.38 起开始向 `UISceneDelegate` 生命周期迁移，纯 Dart 业务不受影响，带原生代码的项目要跟着改。

### 3.2 main.dart 逐行讲解

`flutter create` 生成的 `lib/main.dart` 是一个计数器示例，我们逐块讲透（注释为讲解版）：

```dart
// lib/main.dart —— 计数器示例（讲解注释版）
import 'package:flutter/material.dart'; // Material 组件库：UI 组件 + 主题 + 布局都在这一个 import 里

void main() {
  // 程序入口。相当于前端 main.ts 里的：
  //   createApp(App).mount('#app')
  // 区别：前端是"挂到 DOM 容器"，Flutter 没有 DOM，runApp 直接把参数变成整个屏幕内容的根
  runApp(const MyApp());
}

// StatelessWidget：无内部状态的组件（04 篇详解）
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // const 构造 + super.key：企业代码标准姿势，04 篇讲它为什么值钱

  @override
  Widget build(BuildContext context) {
    // MaterialApp ≈ 顶层壳：路由表（vue-router）、主题（ConfigProvider）、标题、国际化统一在这配
    return MaterialApp(
      title: 'Enterprise App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // M3 主题：从一个种子色生成整套配色
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'), // 首页；接路由表后这里换成 onGenerateRoute / router 配置
    );
  }
}

// StatefulWidget：有内部状态（_counter）的组件
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title}); // this.title 是"外部传参"，相当于 React 的 props
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // 状态组件 = 不可变配置 + 可变 State，04 篇展开
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // 私有状态：下划线前缀 = 库内私有（01 篇讲过 Dart 的私有性）

  void _incrementCounter() {
    // setState = "改数据 + 标记该组件需要重新 build"
    // ≈ React 的 this.setState / Vue 的 ref.value = x 触发响应式更新
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold：页面级脚手架，提供移动端页面的标准"槽位"
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),           // 顶栏
      body: Center(                                          // 内容区
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium), // 字体样式走主题，不写死
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(           // FAB：右下角悬浮按钮槽位
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

三个必须现在建立的心智：

1. **`runApp` 之后整棵树都是 Widget**——没有 HTML，没有 `index.html` 里的 `<div id="root">`，"文档流"这个概念在 Flutter 里不存在。
2. **`MaterialApp` 是壳不是页面**：它对应前端的"根组件"（App.vue / Root.tsx），负责全局配置。企业项目会拆成 `main.dart`（只做引导）+ `app.dart`（根组件装配），见 3.3。
3. **`Scaffold` 是页面骨架**：顶栏、内容、FAB、抽屉、底部导航都是它的槽位，相当于移动端版的 `<el-container>` 布局壳。**每页一个 Scaffold** 是 Material 应用的惯例。

### 3.3 lib/ 的企业分层（预告）

模板项目把所有代码塞在 `main.dart`，企业项目第一天就要拆：

```
lib/
├── main.dart          # 只做"引导"：确保绑定初始化、启动引导逻辑、runApp
├── app.dart           # 根组件：MaterialApp + 主题 + 路由装配
├── core/              # 与业务无关的基础设施：theme / network / router / widgets
└── features/          # 按业务域组织（feature-first），如 features/login/
```

为什么这么分、每层职责边界，[应用架构设计](09-应用架构设计.md)整篇展开。本篇末尾的初始化清单会直接给出落地命令。

---

## 4. pubspec.yaml 详解：逐字段对照 package.json

### 4.1 逐字段精读

```yaml
# ============================================================
# 元信息区
# ============================================================
name: enterprise_app          # ↔ package.json 的 name；全小写下划线，也是 import 时的包名前缀
description: 企业级示例应用    # ↔ description
publish_to: "none"            # ↔ private: true —— 声明为私有应用，禁止发布到 pub.dev
version: 1.2.0+42             # ↔ version：语义化版本 + 构建号
                               #   加号前 = 版本名（展示给用户），加号后 = Android versionCode / iOS build 号（每次发版必须递增）

# ============================================================
# 运行环境
# ============================================================
environment:
  sdk: ">=3.4.0 <4.0.0"        # ↔ engines：限定 Dart SDK 范围；Dart 3 即空安全基线，写死下限是团队规范

# ============================================================
# 运行时依赖 —— 相当于 dependencies
# ============================================================
dependencies:
  flutter:
    sdk: flutter               # SDK 依赖：绑定本地 Flutter SDK 本体，npm 没有对应物
  cupertino_icons: ^1.0.8      # iOS 风格图标字体
  dio: ^5.4.0                  # 网络请求（07 篇主角）
  go_router:
    git:                       # git 依赖：等某个 PR 合并前的过渡方案（能不用就不用）
      url: https://github.com/flutter/flutter.git
      path: packages/go_router
      ref: fix/xxx

# ============================================================
# 开发期依赖 —— 相当于 devDependencies
# ============================================================
dev_dependencies:
  flutter_test:
    sdk: flutter               # 官方测试框架（≈ vitest + testing-library 的合体）
  flutter_lints: ^4.0.0        # 官方 lint 推荐集

# ============================================================
# Flutter 专属配置
# ============================================================
flutter:
  uses-material-design: true   # 内置 Material 图标字体（Icon(Icons.xxx) 依赖它）
  assets:
    - assets/images/           # 整个目录（⚠️ 只含该目录直属文件，子目录要逐级声明）
    - assets/config/app.json   # 单个文件
  fonts:
    - family: AppFont
      fonts:
        - asset: assets/fonts/AppFont-Regular.ttf
        - asset: assets/fonts/AppFont-Bold.ttf
          weight: 700
```

> 以上版本号仅为示例。落地时以 `pub.dev` 当前稳定版为准，别照抄本文数字。

对照表（背下来）：

| pubspec.yaml | package.json | 差异点 |
|--------------|--------------|--------|
| `name` | `name` | Flutter 的 name 同时是 import 前缀（`package:enterprise_app/...`） |
| `version` | `version` | Flutter 有 `+构建号` 的双段式，前端没有 |
| `publish_to: "none"` | `private: true` | 语义一致 |
| `environment.sdk` | `engines` | pub 的 sdk 约束是**硬约束**，装不上直接失败 |
| `dependencies` | `dependencies` | 一致 |
| `dev_dependencies` | `devDependencies` | 一致 |
| `dependency_overrides` | npm `overrides` / yarn `resolutions` | 见 4.3 |
| `flutter.assets` / `fonts` | 无对应（前端资源由打包器处理） | Flutter 资源**必须声明才能访问** |
| **没有 `scripts`** | `scripts` | pub 没有 scripts 概念！常用方案见下 |

关于 `scripts` 缺失：前端习惯 `npm run dev`，Flutter 里对应关系是——`flutter run`（dev）、`flutter build apk`（build）、`flutter test`（test）。自定义脚本用 shell / `Makefile` / Dart 写小工具（如 [rps](https://pub.dev/packages/rps) 包）；monorepo 多包管理用 [melos](https://melos.invertible.dev)（≈ npm workspaces + lerna 的合体，见[应用架构设计](09-应用架构设计.md)）。

### 4.2 版本约束语法：^ 与范围

```yaml
dependencies:
  dio: ^5.4.0        # 插入符（caret）：>=5.4.0 <6.0.0，允许不破坏性升级
  intl: ">=0.19.0 <0.20.0"  # 显式范围
  collection: 1.18.0 # 精确锁定：只允许这个版本（企业里锁关键库时用）
  path: any         # 任意版本（永远不要写，这里只是展示语法）
```

- `^` 语义与 npm 基本一致：**最左侧非零数字段不变**。`^5.4.0` 放行到 `<6.0.0`；`^0.19.0` 只放行到 `<0.20.0`（0.x 阶段次版本号视为破坏性变更）；`^0.0.3` 甚至锁死到 `0.0.3` 一个版本。
- pub 还支持更细的语法（如 `>=1.0.0 <=1.5.0 <2.0.0`），细节见[官方依赖文档](https://dart.dev/tools/pub/dependencies)。

企业口径：**应用项目的依赖一律 `^`，靠 lockfile 锁死；对外发布的库，约束要给窄一些**（你越激进，下游越容易构建失败）。

### 4.3 依赖覆盖（Dependency Overrides）：dependency_overrides

```yaml
dependency_overrides:
  intl: 0.19.0      # 所有直接/传递依赖统一强制到这个版本 —— ≈ yarn resolutions
  dio:
    path: ../forks/dio   # 本地 fork 联调 —— ≈ npm 的 file: 引用
```

典型用途两个：

1. **传递依赖打架**：A 依赖 `intl 0.18`，B 依赖 `intl 0.19`，冲突时强制统一。
2. **本地 fork 联调**：发现上游 bug，fork 一份修掉，用 `path` 指过去本地验证，PR 合并后删掉覆盖。

> **坑**：`dependency_overrides` 会静默越过所有版本约束，**上线前必须清掉**。企业惯例：PR 改动了这个字段要求 reviewer 显式批准，甚至用 CI 脚本检查。

### 4.4 资源声明（assets）要点

- 声明目录**不递归**：`assets/images/` 不包含 `assets/images/icons/`，子目录要另写一行——最高频新手坑之一。
- 逻辑像素资源变体：放 `2.0x/`、`3.0x/` 子目录自动按设备像素密度匹配（`assets/images/logo.png` + `assets/images/2.0x/logo.png`）。
- 加载：代码里 `Image.asset('assets/images/logo.png')`；根路径以 pubspec 所在目录为基准。
- 大量小图标不用逐个声明，直接声明整个目录。

---

## 5. 依赖管理：pub 命令与企业选包标准

### 5.1 命令对照表：pub vs npm

| 场景 | pub（Dart/Flutter） | npm | 备注 |
|------|--------------------|----|------|
| 按 pubspec 安装 | `flutter pub get` | `npm install` / `npm ci` | clone 项目后第一件事 |
| 新增依赖 | `dart pub add dio`（或 `flutter pub add dio`） | `npm i dio` | 自动写入 pubspec 并选最新稳定版 |
| 加开发依赖 | `flutter pub add dev:flutter_lints` | `npm i -D xxx` | 注意 `dev:` 前缀 |
| 移除依赖 | `dart pub remove dio` | `npm uninstall dio` | |
| 约束内升级 | `flutter pub upgrade` | `npm update` | 都只升到约束范围内 |
| 跨大版本升级 | `flutter pub upgrade --major-versions` | `npm-check-updates -u && npm i` | pub 原生支持，很贴心 |
| 降级 | `flutter pub downgrade [包名]` | `npm i pkg@x.y.z` | downgrade 只回到 lock 内/缓存可用版本 |
| 查看过期 | `flutter pub outdated` | `npm outdated` | 大版本升级前先跑这个 |
| 依赖树 | `flutter pub deps` | `npm ls` | 排查传递依赖冲突 |
| 锁文件 | `pubspec.lock` | `package-lock.json` | 策略见 5.2 |
| 安全审计 | 无完全等价物 | `npm audit` | pub 生态的安全披露机制以[官方说明](https://dart.dev/tools/pub/security)为准 |

### 5.2 lockfile 策略

和 npm 生态同构的规则：

- **应用（App）项目：`pubspec.lock` 必须提交**。"我机器上好的，CI 上挂了"在锁了 lockfile 的项目里几乎绝迹。
- **对外发布的库（package）：不提交 lockfile**。库的 lockfile 不影响下游（下游自己解析），提交反而误导。你的项目 99% 是应用，所以直接记住前半句。
- pubspec.yaml 里的 `^` 约束决定"允许什么"，lockfile 决定"实际用什么"。CI 想严格按 lockfile 安装并拒绝漂移，可查 `--enforce-lockfile` 相关参数（以[官方文档](https://dart.dev/tools/pub/cmd)为准）。

### 5.3 pub.dev 企业选包 checklist

pub.dev 没有 npm 那种下载量一家独大的信号，选包看这套组合指标：

1. **Flutter Favorite 徽章**：官方盖章"推荐用于生产"。第一眼先找它（如 dio、go_router 都有）。
2. **Pub points**：官方对包质量的自动评分（分析器、文档、平台支持、依赖健康度综合分），**低于满分区间的直接警惕**。
3. **Likes 与 Popularity**：人气参考，重要但不唯一——Flutter 生态小众领域好包 likes 不多很正常。
4. **最近更新时间**：超过 6 个月未更新要谨慎；超过一年基本不考虑（除非纯静态工具类）。
5. **issue 健康度**：open issue 数量看绝对值更要看响应——维护者是否回复、是否持续 close。一堆 issue 无人理 = 弃坑前兆。
6. **平台支持矩阵**：包页面顶部有 ANDROID / IOS / WEB / LINUX / MACOS / WINDOWS 标签。**你目标端没标支持的直接排除**，这是硬门槛。
7. **Dart 3 兼容**：SDK 约束还停在 Dart 2 的包，说明作者没跟上空安全时代，后续维护存疑。
8. **依赖树干净度**：`flutter pub deps` 看传递依赖。引一个 UI 库带进来 20 个传递依赖，升级地狱预定。
9. **License**：企业合规项。MIT/BSD 常见；GPL 系慎入移动应用。

一句话原则：**能用官方/Flutter Favorite 就不用三方野包；三方包进生产前，把它的 GitHub issue 列表当尽调报告读一遍**。

### 5.4 起步依赖清单

新项目第一天建议只加这几个（其余等真需要再加，克制是美德）：

| 包 | 角色 | 后续详篇 |
|----|------|---------|
| `dio` | 网络请求 | [网络层设计](07-网络层设计.md) |
| `go_router` | 声明式路由（官方维护） | [路由与导航](05-路由与导航.md) |
| `shared_preferences` | 轻量 KV 存储 | [本地存储](08-本地存储.md) |
| 状态管理（Riverpod / Bloc 按团队选型） | 见 | [状态管理](06-状态管理.md) |

---

## 6. 调试工具总览：DevTools、断点、日志

### 6.1 flutter run 键位表

`flutter run` 启动后终端进入交互模式：

| 键 | 作用 |
|----|------|
| `r` | 热重载（VS Code 里**保存文件**即触发） |
| `R` | 热重启 |
| `p` | 切换布局网格 / 基线线（调 UI 对齐神器） |
| `o` | 切换 Android / iOS 平台模拟样式（预览平台差异组件表现） |
| `s` | 截图 |
| `d` | detach：断开调试但应用继续跑（临时让别人看效果时用） |
| `q` | 退出 |

### 6.2 DevTools 与 Chrome DevTools 对照

DevTools 是 Flutter 官方的调试套件（`flutter run` 时终端会打印入口地址，VS Code 里也可用命令面板打开）。心智完全对标 Chrome DevTools：

| DevTools 面板 | 干什么 | Chrome DevTools 对应 |
|---------------|--------|---------------------|
| **Widget Inspector** | 组件树浏览、点击选中、查看属性、**标出"rebuild 次数异常"的组件** | Elements + React DevTools 的 Components 面板 |
| **Layout Explorer** | 交互式查看选中组件的约束与尺寸（拖动 min/max 直接改 UI） | Elements 的盒模型面板，但可交互 |
| **Performance** | 帧率、每帧构建/光栅化耗时、火焰图 | Performance 面板 |
| **CPU Profiler** | 函数级采样分析 | JavaScript Profiler |
| **Memory** | 堆曲线、快照、泄漏分析 | Memory 面板 |
| **Network** | 应用发出的 HTTP 请求 | Network 面板（三方 http 库是否被自动采集以官方文档为准；dio 通常配合日志拦截器） |
| **Debugger** | 断点、调用栈、变量查看 | Sources 面板 |
| **Logging** | 应用日志流 | Console |

前端同学最该先玩的是 **Widget Inspector**：它对组件树的可视化和 React DevTools 几乎一一对应，而且"选中节点 → 直接在编辑器里跳到源码位置"这个体验比浏览器还好。性能分析三板斧在[性能优化](13-性能优化.md)整篇展开。

### 6.3 断点与日志规范

**断点**：VS Code 里代码行首点一下红点，`F5` 调试运行即可命中；支持条件断点、异常暂停（Debug 面板可勾选"未捕获异常时暂停"）——用法与 Chrome Sources 一致，零学习成本。

**日志**（团队规范建议现在就立）：

```dart
import 'package:flutter/foundation.dart';

// ✅ 推荐：debugPrint —— 自带限流，长日志不丢
debugPrint('订单详情加载成功 orderId=$orderId');

// ❌ 生产代码别用 print：
// 1. 它不会在 release 里被自动移除（不像 console.log 有插件帮你 tree-shake）
// 2. 无限流，日志洪峰时直接拖慢 UI 线程
print('I am slow');
```

企业级做法：封装统一 logger 门面，内部用 `kDebugMode` 控制输出、接入埋点上报（详见[企业级通用能力](11-企业级通用能力.md)）。开发期 `debugPrint` 够用。

### 6.4 flutter analyze 与 dart fix

```bash
flutter analyze          # 静态检查：相当于 eslint --no-fix，CI 必跑
dart fix --dry-run       # 预览可自动修复的问题
dart fix --apply         # 应用自动修复：相当于 eslint --fix
```

Dart 分析器比 ESLint 对 TS 的支持**更严格也更聪明**（类型推断更强、未 await 警告等）。企业里 `flutter analyze` 挂 = CI 挂，别养成"先注释掉警告"的习惯， lint 报的 90% 是真问题。

---

## 7. 多端差异简述：iOS、Web 与 flavors

### 7.1 iOS：签名与 macOS 依赖

硬事实三条：

1. **iOS 构建只在 macOS 上进行**（依赖 Xcode）。Windows 开发者日常在 Android/Chrome 上调试 UI，但 iOS 兼容性验证必须依赖团队里的 mac（或 CI 的 mac 节点，见[工程化与发布](14-工程化与发布.md)）。
2. **真机调试需要签名**：Xcode 里登录 Apple ID 即可自动生成免费开发证书——但**7 天过期**，适合自己天天插着线调试；正式发布需要付费开发者账号（Apple Developer Program，约 99 美元/年）的证书与描述文件（Provisioning Profile）。
3. iOS 模拟器不需要签名，但只能跑在 macOS 上。

对前端团队的对照理解：这相当于"你的项目只能在特定 OS 上出生产包"，跨端不是全免费的——**代码跨端免费，发布流水线各端都要伺候**。

### 7.2 Web 端：能力边界

- 渲染走 HTML/CanvasKit（编译为 WebGL 绘制），首屏体积是真实成本，纯展示类页面可用，重交互后台类应用慎选。
- **没有 `dart:io`**：文件、进程、原生通道等 API 不可用，网络用 `package:http`/`dio` 的 web 适配。选包时看平台标签的意义就在这。
- 热重载不可用，只有热重启。
- 渲染器与加载策略演进较快，细节以[官方 Web 文档](https://docs.flutter.dev/platform-integration/web)为准。

### 7.3 桌面与 flavors 预告

Windows/macOS/Linux 三端支持已稳定，Windows 本机可直接 `flutter run -d windows` 调试桌面版——内部工具型应用（如运营后台）用 Flutter 做桌面是个高性价比选择。

多环境（dev / staging / prod）的构建配置——Android flavors + iOS schemes + `--dart-define`——是工程化标配，[工程化与发布](14-工程化与发布.md)整篇讲透。本篇先建立意识：**环境差异用构建配置解决，永远不要用改代码解决**。

---

## 8. 本篇沉淀：标准企业项目初始化清单

从零到"可以直接开发"的完整动作序列，新项目照抄：

```bash
# ① 创建：org 一次定终身
flutter create enterprise_app --org com.acme --project-name enterprise_app --platforms android,ios,web
cd enterprise_app

# ② 基线依赖（状态管理包按团队选型后加）
flutter pub add dio go_router shared_preferences

# ③ 目录骨架（feature-first 分层，09 篇详述）
mkdir -p lib/core/theme lib/core/network lib/core/router lib/core/widgets \
         lib/features/login/pages lib/features/login/widgets lib/features/login/models \
         assets/images assets/config

# ④ README 里写死团队命令约定
```

```dart
// lib/main.dart —— 企业入口：只做"引导"，不放任何业务
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 用到插件/原生通道前的标准动作，先无脑加上
  runApp(const App());
}
```

```dart
// lib/app.dart —— 根组件：只做"装配"（主题、路由、全局 Provider 都挂这里）
import 'package:flutter/material.dart';

import 'features/login/pages/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2563EB))),
      home: const LoginPage(), // 接入 go_router 后换成 routerConfig
    );
  }
}
```

收尾检查（PR 前自查）：

- [ ] `pubspec.lock` 已提交，`build/`、`.dart_tool/` 已忽略（模板自带，确认即可）
- [ ] `flutter analyze` 零告警
- [ ] `README.md` 写清：环境变量镜像配置、`flutter pub get`、`flutter run`、各端运行说明
- [ ] `analysis_options.yaml` 保持官方推荐集，团队增补规则走评审
- [ ] 模拟器 + 至少一台真机各跑通一次

---

## 自测清单

- [ ] 能说清 `PUB_HOSTED_URL` 与 `FLUTTER_STORAGE_BASE_URL` 各自解决什么下载问题
- [ ] `flutter doctor -v` 有 `✗` 时知道第一排查入口
- [ ] 能讲清热重载与热重启的区别，并说出 3 类"必须完全重启"的改动
- [ ] 不看文档能说出 pubspec 至少 6 个字段与 package.json 的对应关系
- [ ] 能解释为什么 `pubspec.lock` 在应用项目必须提交、在库里不提交
- [ ] 背得出企业选包 checklist 的至少 5 条
- [ ] 能把 DevTools 的 4 个以上面板对应到 Chrome DevTools 的等价物
- [ ] 能回答"为什么 Windows 开发者编译不了 iOS"，以及团队的常规应对方案

## 延伸阅读

- [Flutter 官方文档](https://docs.flutter.dev)（中文镜像：[docs.flutter.cn](https://docs.flutter.cn)）
- [Windows 环境安装指引](https://docs.flutter.dev/get-started/install/windows)
- [在中国使用 Flutter（官方镜像说明）](https://docs.flutter.cn/community/china)
- [热重载官方文档](https://docs.flutter.dev/tools/hot-reload)
- [使用包（pubspec 与依赖）](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [pub 依赖与版本约束语法](https://dart.dev/tools/pub/dependencies)
- [DevTools 总览](https://docs.flutter.dev/tools/devtools/overview)
- [pub.dev 包仓库](https://pub.dev)
- [Flutter Favorite 计划](https://docs.flutter.dev/packages-and-plugins/favorites)
