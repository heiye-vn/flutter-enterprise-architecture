# 02 Dart 语言进阶

> **本篇目标**：掌握企业级 Dart 代码的四大支柱——空安全、异步（Future/Stream）、并发（Isolate）、泛型与错误体系。学完你写的网络层、数据层代码才够格进生产仓库。
>
> **前置阅读**：[Dart 语言基础](01-Dart语言基础.md)——本篇默认你已掌握类型系统、类与构造函数、模式匹配基础。
>
> **学完你能做什么**：
> - 看懂并写对空安全代码，知道 `late` 和"字段不提升"这两个高频坑
> - 用 async/await + try/on/catch 写出可维护的异步流程，明白它和 Promise 的差异
> - 判断什么场景该用 Stream，什么场景该用 Isolate
> - 手写企业级 `Result<T, E>` 封装和带超时重试的请求函数

---

## 1. 空安全完整规则

Dart 3 空安全是强制的，且与 TS 有本质区别：**TS 的空安全只在编译期（编译后类型擦除），Dart 的空安全编译成机器码后运行时依然成立**。心智可以平移 `strictNullChecks`，但边界不一样。

### 1.1 基础：? 与 !

```dart
// bin/null_basic.dart
void main() {
  String name = '李雷';   // 不可空：赋 null 直接编译错误
  String? nickname;       // 可空：不初始化默认为 null

  // nickname.length;    // ❌ 编译错误：可空值不能直接访问成员
  print(nickname?.length);  // ?. 可选链，同 TS
  print(nickname ?? '无');   // ?? 兜底，同 TS
  print(nickname!.length);   // ! 非空断言：同 TS 的 x!，运行时为 null 则抛异常
}
```

### 1.2 类型提升（type promotion）：局部变量可以，字段不行

TS 里 `if (user) user.name` 是类型收窄；Dart 的**流分析（flow analysis）**同样会对局部变量做提升，但对**类字段不生效**——这是转 Flutter 最早踩的坑之一：

```dart
// bin/null_promotion.dart
class Cart {
  User? _user; // 可空字段

  void bad() {
    if (_user != null) {
      // print(_user.name); // ❌ 编译错误！判空"不算数"
      print(_user!.name);  // 只能 ! —— 但这就是运行时裸奔
    }
  }

  void good() {
    final user = _user; // 团队标准解法：先拷贝到局部变量，让流分析接管
    if (user != null) {
      print(user.name); // ✅ 局部变量被提升为非空 User
    }
  }
}

class User {
  final String name;
  User(this.name);
}

void main() {
  Cart()..good();
}
```

**为什么字段不提升**：字段访问可能触发 getter，而 getter 可被子类覆写、两次调用可能返回不同值，编译器无法保证"判空之后还是非空"。所以规则是——**字段判空后使用，一律先落局部变量**（企业 lint 常配 `unnecessary_non_null_assertion`、部分团队直接禁字段 `!`）。

### 1.3 late：双刃剑

`late` 声明"这个变量稍后赋值、用之前一定有值"，编译器不再要求初始化：

```dart
// bin/null_late.dart
class Controller {
  // 场景1（Flutter 高频惯用法）：
  // 字段依赖 initState / context，构造时给不了 → late 推迟到生命周期里赋
  late final StreamSubscription sub;

  // 场景2：惰性初始化 —— expensive 不被访问就永远不执行
  late final List<String> expensive = _loadHugeList();

  List<String> _loadHugeList() {
    print('执行了昂贵初始化');
    return List.generate(1000000, (i) => 'item$i');
  }
}

void main() {
  final c = Controller();
  print('还没访问 expensive');
  print(c.expensive.length); // 此刻才真正初始化 —— 惰性求值
}
```

`late` 的三个坑，团队评审重点盯：

1. **未初始化就使用 → 运行时抛 `LateInitializationError`**。`late` 把编译期检查降级成了运行时爆炸，本质和 `!` 一样是"取消检查"，写之前先问自己"赋值时序真的可控吗"。
2. **`late final` 二次赋值 → 运行时抛异常**，同样是运行时才发现。
3. **Flutter 生命周期场景下最危险的坑**：`late` 字段依赖的 Widget 被销毁后才被访问（如异步回调里），直接崩溃。凡 `late` + 异步回调同时出现，评审必问。

> **团队习惯**：能用"可空 + 局部变量提升"就用它，`late` 只保留给"构造后立刻在 `initState` 赋值"和"惰性初始化"两个场景。

### 1.4 与 TS strictNullChecks 的差异速查

| | TS | Dart |
|---|----|------|
| 检查时机 | 仅编译期 | 编译期 + 运行时（AOT 后仍成立） |
| 判空收窄 | 字段也收窄（`if (this.user)` 后可 `.name`） | **字段不收窄**，需拷贝局部变量 |
| 稍后赋值 | `let x!: string`（ definite assignment assertion） | `late`（额外获得惰性求值能力） |
| 底部类型 | `never` | `Never`（同样用于穷尽检查） |

---

## 2. 异步：Future

### 2.1 Future vs Promise

| | TS `Promise<T>` | Dart `Future<T>` |
|---|-----------------|------------------|
| 成功值类型 | 泛型 `T` | 泛型 `T` |
| 错误值类型 | **不受泛型约束**（catch 参数是 `unknown`/`any`） | **同样不受泛型约束**，任何 `Object` 都能被抛出 |
| 微任务语义 | then 走微任务队列 | 微任务队列（`scheduleMicrotask`），事件循环几乎同构 |
| 组合 API | `all` / `allSettled` / `race` | `wait` / `any`（细节见下） |

两者 API 心智高度重合，**核心差异只有一处：错误类型都是"裸"的**——`Future<T>` 只描述成功形态，失败可以是任何被抛出的对象。TS 里有人用 `Promise<Result<T, E>>` 编码错误类型，Dart 里对应方案就是第 5 节的 `Result<T, E>`（Rust 风格），这是企业网络层的主流做法。

```dart
// bin/future_basic.dart
import 'dart:async';

Future<String> fetchName(int id) async {
  await Future<void>.delayed(Duration(milliseconds: 200)); // 模拟网络耗时
  return '用户$id';
}

void main() async {
  // 对应 Promise.all：全部成功才成功
  final all = await Future.wait([
    fetchName(1),
    fetchName(2),
  ]);

  // 对应 Promise.race：谁先完成用谁
  final first = await Future.any([fetchName(3), fetchName(4)]);

  // Future.wait 的 eagerError 参数：
  //   true  = 一有失败立刻抛（近似 Promise.all）
  //   false = 等全部落地再抛第一个错误（近似 allSettled，但结果会丢失）
  // 企业里"多个请求互不依赖、失败不互相拖累"更常用分别 await + Result
  print(all);
  print(first);
}
```

> **注意**：`Future.wait` 要求所有 Future 成功值类型一致（`List<Future<T>>`），异构列表要用 `Future.wait<dynamic>` 或分开 await——TS 里 `Promise.all([a, b])` 自动推断元组类型，Dart 这里要手写，是个小落差。

### 2.2 async/await 与 try/on/catch/finally

语法与 JS 几乎一致，增强点是 `on` 可以**按类型捕获**：

```dart
// bin/future_error.dart
import 'dart:async';

Future<double> parseRatio(String raw) async {
  await Future<void>.delayed(Duration(milliseconds: 50));
  return double.parse(raw); // 解析失败抛 FormatException
}

Future<void> run() async {
  try {
    print(await parseRatio('0.75'));
    print(await parseRatio('abc'));
  } on FormatException catch (e, s) {
    // on：先按类型分流（TS 没有，通常 instanceof 自己写）
    // catch 带两个参数：异常对象 + 堆栈（第 7 节讲堆栈怎么用）
    print('格式错误: $e');
    print('堆栈: $s');
  } on Exception catch (e) {
    print('其他业务异常: $e');
  } catch (e) {
    // 兜底分支：任何类型（包括被 throw 的非 Exception 对象）
    print('未知: $e');
  } finally {
    print('无论如何都执行');
  }
}

void main() => run();
```

三个企业级红线，评审必抓：

1. **禁止裸 then 链**：一律 `async/await` + try/catch，then 嵌套就是回调地狱还难统一处理错误。
2. **禁止吞异常**：空 `catch {}` 是重大问题。确实无法处理的，`rethrow` 上抛或至少记录日志（第 7 节）。
3. **fire-and-forget 必须显式标记**：异步调用不 await，异常会变成无人认领的 Zone 错误，极难排查。用 `unawaited(doSomething())`（`dart:async` 提供）明确表达"我知道它返回 Future 且故意不等"，配套 lint `unawaited_futures` 会逼你写。

---

## 3. Stream

### 3.1 心智定位：对应 RxJS Observable

`Stream<T>` 是"异步的序列"——`Future<T>` 是单值，`Stream<T>` 是多值。对照表：

| RxJS | Dart Stream |
|------|-------------|
| `Observable`（cold，每个订阅独立执行） | 单订阅 Stream（只允许一个 listener，二次 listen 抛 `StateError`） |
| `Subject` / 热流 | `StreamController.broadcast()` 广播流 |
| `for await...of` / `takeUntil` | `await for`（自动到流结束/抛错退出） |
| `observable.subscribe(next, error, complete)` | `stream.listen(onData, onError, onDone)` |
| 操作符 `map`/`filter`/`debounce` | 有 `map`/`where`；`debounce` 等**没有内置**，要用 `rxdart` 包 |
| 订阅退订 | `listen` 返回 `StreamSubscription`，调用 `sub.cancel()` |

### 3.2 基础用法与单订阅 vs 广播

```dart
// bin/stream_basic.dart
import 'dart:async';

void main() async {
  // 快速构造：fromIterable / periodic
  final nums = Stream<int>.periodic(
    Duration(milliseconds: 300),
    (i) => i,
  ).take(5); // take 后只有 5 个事件，然后自动 done

  // listen 方式（命令式）：别忘了 cancel，否则资源泄漏
  final sub = nums.listen(
    (data) => print('listen 收到 $data'),
    onError: (Object e) => print('出错 $e'),
    onDone: () => print('完成'),
  );
  await sub.cancel();

  // await for 方式（声明式）：读起来和同步 for 一样，是团队首选
  await for (final n in Stream<int>.fromIterable([10, 20, 30])) {
    print('await for 收到 $n');
  }
}
```

`StreamController` 是"手写热流"的工具，也是 BLoC / IM 消息分发这类企业场景的地基：

```dart
// bin/stream_controller.dart
import 'dart:async';

class MessageBus {
  final _controller = StreamController<String>.broadcast(); // 广播：多 listener 各自收到全部事件

  Stream<String> get stream => _controller.stream; // 对外只暴露流，不暴露控制器

  void send(String msg) => _controller.add(msg);

  Future<void> dispose() => _controller.close(); // 用完必须关！
}

void main() async {
  final bus = MessageBus();
  final sub = bus.stream.listen(print); // 广播流支持多个订阅者
  final sub2 = bus.stream.listen((m) => print('副本: $m'));

  bus.send('订单已支付');
  bus.send('库存已扣减');

  await sub.cancel();
  await sub2.cancel();
  await bus.dispose();
}
```

> **单订阅 vs 广播的选择**：默认用单订阅（背压、资源语义更清晰，类似 RxJS cold observable）；只有"多个消费者监听同一事件源"时才用 broadcast。**坑**：广播流没有缓冲，listen 之前发生的事件直接丢失——订阅时机要早于事件产生。

### 3.3 async* 生成器：产出流的函数

```dart
// bin/stream_generator.dart
import 'dart:async';

// async* = 返回 Stream 的函数；yield = 产出单个事件
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 1; i--) {
    await Future<void>.delayed(Duration(seconds: 1));
    yield i;
  }
}

void main() async {
  await for (final n in countdown(3)) {
    print(n); // 3 秒倒计时
  }
}
```

**何时该用 Stream**（企业判断标准）：

- 值随时间**多次到达**：WebSocket / IM 长连接消息、推送、行情、输入框实时联想 → Stream
- 数据库/文件变化监听、BLoC 状态流 → Stream
- 只是一次性的"拿数据"（哪怕很慢）→ `Future` 就够了，别上 Stream
- 需要 debounce/throttle 等操作符 → `rxdart`（07 篇搜索联想场景实战）

---

## 4. Isolate：Dart 的"Web Worker"

### 4.1 先讲清事件循环：为什么单线程会卡

Dart 的并发模型和 JS 几乎同构：每个 Isolate 内部是**单线程 + 事件循环**，两个队列——微任务队列（`scheduleMicrotask`）优先于事件队列（IO 完成回调、`Future.delayed`、定时器）。所以你从 JS 迁移过来，"绝不能阻塞主线程"的直觉直接适用：**卡 16ms 就掉一帧**，几十万条 JSON `fromJson` 直接冻结 UI。

差别在出口：JS 有 Web Worker，Dart 有 Isolate——而且更彻底：**每个 Isolate 有独立内存堆，彼此不共享任何状态，只能消息传递（数据被深拷贝）**，没有锁、没有竞态。可以理解为"没有 SharedArrayBuffer 的 Worker"，更像轻量进程。

### 4.2 两种用法：Isolate.run 与 compute

```dart
// bin/isolate_demo.dart
import 'dart:convert';
import 'dart:isolate';

// 大 JSON 解析：10 万条记录，主线程解析会掉帧
List<Map<String, dynamic>> parseHugeJson(String source) {
  return (jsonDecode(source) as List)
      .map((e) => e as Map<String, dynamic>)
      .toList();
}

void main() async {
  // 造 10 万条记录的 JSON 字符串
  final huge = jsonEncode(
    List.generate(
      100000,
      (i) => {'id': i, 'title': '商品 $i', 'price': i * 1.5},
    ),
  );

  final sw = Stopwatch()..start();

  // Isolate.run（Dart 2.19+）：把函数扔到新 Isolate 执行，await 拿回结果
  // 对应 Web Worker 的 new Worker + postMessage，但一行搞定
  final result = await Isolate.run(() => parseHugeJson(huge));

  print('解析 ${result.length} 条，耗时 ${sw.elapsedMilliseconds}ms，主线程全程流畅');
}
```

Flutter 里的惯用封装是 `compute(fn, arg)`（来自 `package:flutter/foundation`）：

```dart
// lib/services/json_service.dart（Flutter 项目内）
// import 'package:flutter/foundation.dart';
//
// final products = await compute(parseHugeJson, hugeJson);
// 参数通过消息传递拷贝过去，返回值拷贝回来 —— API 和 Isolate.run 几乎等价
```

企业选型：

- **多大才需要 Isolate**：几十 KB 的 JSON 主线程无感；几百 KB 起肉眼可见卡顿；MB 级必须搬走。经验阈值不精确，用 12 篇的 DevTools Timeline 实测为准。
- **高频场景**：大 JSON / 大 CSV 解析、图片编解码、加密解密、复杂本地搜索索引。
- **坑**：传给 Isolate 的参数和闭包捕获会被拷贝，不要把巨大对象传两个来回；Flutter Web 上 Isolate 无真并行（`compute` 会退化为主线程执行，以官方文档为准）。

---

## 5. 泛型实战

### 5.1 泛型类/方法与约束

泛型语法对 TS 开发者零门槛，两处小差异：`extends` 约束（对应 TS 的 `T extends X`），以及**支持默认类型参数**（TS 没有）：

```dart
// bin/generic_demo.dart
// 约束：T 必须是 num 或其子类，方法体内才能用 + 号
T sum<T extends num>(List<T> values) {
  var total = 0;
  for (final v in values) {
    total += v; // 没有约束这里编译不过
  }
  return total as T;
}

// 泛型 + whereType：从 dynamic 集合安全提取指定类型（JSON 处理高频）
void main() {
  print(sum([1, 2, 3]));       // 6
  print(sum([1.5, 2.5]));      // 4.0

  final mixed = <Object?>[1, 'a', 2, 'b', 3];
  print(mixed.whereType<int>().toList()); // [1, 2, 3]
}
```

### 5.2 手写 Result<T, E>：企业网络层的地基

01 篇结尾写过简版 `Result<T>`；生产版有两处升级：**错误类型也参数化**（`E`），以及**把 `Future` 转成 `Result` 的工厂**——从此异步错误全在类型里，调用方无法"忘记处理"：

```dart
// bin/result.dart

// E extends Object = String：E 可省略，默认 String（Dart 泛型支持默认类型参数）
sealed class Result<T, E extends Object = String> {
  const Result();

  // 核心工厂：把"会抛异常的 Future"降服成"类型安全的 Result"
  // 之后网络层所有请求都从这里走 —— 错误从"天上飞的异常"变成"手里拿的值"
  static Future<Result<T, E>> guard<T, E extends Object>(
    Future<T> Function() task,
  ) async {
    try {
      return Ok(await task());
    } on Exception catch (e, s) {
      // Error（程序 bug）不在此拦截，让它崩，第 7 节解释
      return Err(E == String ? e.toString() : (e as E), s);
    }
  }

  R when<R>({
    required R Function(T value) ok,
    required R Function(E error, StackTrace stackTrace) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final error, :final stackTrace) => err(error, stackTrace),
    };
  }

  // map：成功时变换，失败原样透传（链式处理利器）
  Result<R, E> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok(:final value) => Ok(transform(value)),
      Err() => this as Result<R, E>,
    };
  }
}

class Ok<T, E> extends Result<T, E> {
  final T value;
  const Ok(this.value);
}

class Err<T, E> extends Result<T, E> {
  final E error;
  final StackTrace stackTrace;
  const Err(this.error, this.stackTrace);
}
```

`sealed` 的意义在 01 篇讲过：外部**无法**新增子类，`when`/`switch` 漏分支编译报错。团队里调用网络层因此被强制写出"成/败都处理"的代码，把"忘了 catch 导致白屏"这类事故在编译期消灭。07 网络篇会把 `dio` 异常翻译成自定义错误类型填进 `E`。

> 生产提示：这个类正是 `freezed` 最经典的用武之地（自动生成 `copyWith`/`==`/序列化），第 8 节介绍。

---

## 6. mixin

### 6.1 with 与线性化规则

mixin 是"可组合的能力片段"。与 Vue mixin 的关键差异：**Dart 的组合顺序是确定性的**，叫线性化（linearization）——`class C extends B with M1, M2` 中，成员查找顺序是 `M2 → M1 → B → C`，**越后面的 mixin 优先级越高**，没有 Vue mixin 那种"谁覆盖谁靠命名冲突运气"的问题：

```dart
// bin/mixin_demo.dart
mixin Loggable {
  // mixin 不能有构造函数，这是它和 class 的根本区别
  void log(String msg) => print('[$runtimeType] $msg');
}

mixin Timestamped {
  void log(String msg) => print('[时间戳版] $msg'); // 与 Loggable 同签名

  void stamp() => print(DateTime.now());
}

class OrderService extends Object with Loggable, Timestamped {
  // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  // 查找顺序: Timestamped → Loggable → Object
  // 同签名方法中 Timestamped 靠后，所以它的 log 胜出（线性化规则，确定性覆盖）
  void submit() {
    log('提交订单'); // 打印 [时间戳版] 提交订单
    stamp();
  }
}

void main() {
  OrderService().submit();
}
```

`super` 在 mixin 里沿线性化链向上调用，是 mixin 间协作的正规姿势（比如"滚动监听 mixin"在 child 的 `super.dispose()` 之后注销自己）。

### 6.2 企业用途

mixin 适合"横切能力"——所有页面/组件都要、但与业务继承链无关的东西：

```dart
// lib/mixins/error_handler.dart（Flutter 项目内节选）
// mixin ErrorHandler on State<StfulWidget> {
//   // 约束宿主：on State<...> 表示只有页面状态类能混入，
//   // mixin 内因此能访问 setState / context 等宿主能力
//   void showError(String message) {
//     if (!mounted) return; // 防止页面已销毁还 setState
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
// }
//
// class OrderPageState extends State<OrderPage>
//     with ErrorHandler, AutomaticKeepAliveClientMixin { ... }
//
// Flutter 自带的 SingleTickerProviderStateMixin（AnimationController 必需）、
// AutomaticKeepAliveClientMixin（列表页切 tab 保活）都是 mixin——
// 你其实早就在"用" mixin，只是现在才认识它
```

> **团队习惯**（同 Vue 的教训）：mixin 单一能力、命名 `XxxMixin`/`Xxxable`；一个类 mixin 超过 3 个就该重构。Mixin 里持有状态（字段）时要格外小心来源可读性——读者看到 `stamp()` 得知道去哪个 mixin 找。

---

## 7. 错误处理体系

### 7.1 Exception vs Error：该 catch 的和不该 catch 的

Dart 把可抛对象分两类，**处置策略完全不同**：

| | `Exception`（含自定义） | `Error` |
|---|--------------------------|---------|
| 语义 | **预期内的失败**：网络断了、JSON 脏了、余额不足 | **程序 bug**：下标越界 `RangeError`、空断言失败 `TypeError`、late 未初始化 `LateInitializationError` |
| 该怎么办 | catch 并转成业务提示（toast / Result.Err） | **不要 catch**——让它崩，修代码本身 |
| 类比 | TS `catch` 业务异常 | catch 了 `TypeError` 只是把 bug 埋进土里，崩溃监控全瞎 |

`catch (e)` 不分类型全拦，会把 Error 也拦下来——所以团队规范**优先用 `on XxxException catch (e)` 精确捕获**，兜底 `catch` 只放在最外层（配崩溃监控）。

### 7.2 自定义异常层级：网络层实例

```dart
// lib/exceptions/app_exception.dart
/// 全部业务异常的祖先：调用方可以用 on AppException 一网打尽
sealed class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace; // 保留现场，崩溃监控必需

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// 网络层异常族（07 篇会在 dio 拦截器里精确翻译这些类型）
final class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

final class TimeoutException extends AppException {
  const TimeoutException(super.message, [super.stackTrace]);
}

final class ApiException extends AppException {
  final int code; // 后端业务码：401 未登录、1003 参数错……
  const ApiException(this.code, super.message, [super.stackTrace]);

  @override
  String toString() => 'ApiException($code): $message';
}
```

### 7.3 StackTrace 与两条铁律

```dart
// bin/error_rules.dart
import 'dart:async';

Future<void> load() async {
  try {
    await Future<void>.delayed(
      Duration(milliseconds: 100),
      () => throw const FormatException('字段格式错误'),
    );
  } on FormatException catch (e, s) {
    // s 就是 StackTrace：上报崩溃监控（Sentry / Crashlytics，14 篇）必须带上它
    print('捕获: $e');

    rethrow; // ✅ 铁律1：处理不了就 rethrow —— 保留原始堆栈继续上抛

    // throw e; // ❌ 千万别！这会【重置堆栈】，监控里看到的崩溃点变成这一行
  }
}

void main() async {
  try {
    await load();
  } on FormatException {
    print('最外层收尾处理');
  }
  // 铁律2：绝对不写空 catch。吞掉的异常 = 用户白屏 + 日志无声 + 排查无门。
  // 真的要"忽略"，至少写明原因：
  // } catch (e) { log('预期内的 xxx，忽略: $e'); }
}
```

把 7.1–7.3 合起来就是团队错误处理约定：**底层（网络/存储）抛类型化异常 → 中层（Repository）转 `Result.Err` → UI 层展示**。异常只在中转层被捕获一次，不许层层 try/catch 包俄罗斯套娃。

---

## 8. 工程工具链

写完语言特性，过一遍你每天都会碰的工具（03 篇搭环境时逐一实操）：

| 工具/包 | 类比前端 | 作用与使用时机 |
|---------|---------|----------------|
| `pub`（pubspec.yaml） | npm + package.json | 依赖与资源声明三合一；`dart pub add dio` 装包，`pubspec.lock` **必须提交 git**（作用同 package-lock.json） |
| 分析器 + lint | ESLint | `dart analyze` 静态检查；项目根 `analysis_options.yaml` 继承 `flutter_lints`，团队在此追加规则（如 `unawaited_futures`） |
| `dart format` | Prettier | 格式化零配置零争论，CI 里强制跑；别在代码风格上浪费评审时间 |
| `build_runner` | Vite / tsc 的"生成"角色 | 代码生成器的统一驱动：`dart run build_runner build --delete-conflicting-outputs` |
| `json_serializable` | 无直接对应（TS 手写类型） | 注解生成 `fromJson`/`toJson`，替代手写 01 篇那种样板工厂；07 网络篇主力 |
| `freezed` | 无直接对应（TS 需要 discriminated union 手写 + never 穷尽） | 一行注解生成密封类 union、`copyWith`、`==`、序列化；第 5 节的 `Result` 生产版基本都用 freezed 写 |

> 先记住结论即可：**模型层 = freezed + json_serializable，build_runner 一键生成**。为什么生成而不是手写？手写 `fromJson` 500 行模型类会耗掉一个人天，且字段改动时极易漏改——这是 07 网络篇的主场，届时完整实战。

---

## 9. 综合练习：带超时与重试的 fetchRetry

把本篇全部要点串起来：**泛型 Result + 异常层级 + 超时 + 指数退避重试**。这就是企业网络层的雏形。

```dart
// bin/fetch_retry.dart
// 运行：dart run bin/fetch_retry.dart
import 'dart:async';
import 'dart:math';

// ============================================================
// 第一部分：异常 + Result（第 5、7 节的成果，稍作精简）
// ============================================================
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

final class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value),
      Err(:final error) => err(error),
    };
  }
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final AppException error;
  const Err(this.error);
}

// ============================================================
// 第二部分：fetchRetry —— 核心练习
// ============================================================
const maxRetries = 3;
const baseDelay = Duration(milliseconds: 200);
const requestTimeout = Duration(milliseconds: 300);

/// 带超时与指数退避重试的通用任务执行器
/// [task]    要执行的异步任务（对应网络请求）
/// [retries] 额外重试次数
/// [timeout] 单次尝试的超时上限
Future<Result<T>> fetchRetry<T>(
  Future<T> Function() task, {
  int retries = maxRetries,
  Duration timeout = requestTimeout,
}) async {
  var lastError = const AppException('未知错误');

  for (var attempt = 0; attempt <= retries; attempt++) {
    try {
      // .timeout：超时抛 TimeoutException（dart:async）
      final value = await task().timeout(timeout);
      return Ok(value);
    } on TimeoutException {
      // timeout 抛的是 dart:async 的 TimeoutException，转成自己的体系
      lastError = const TimeoutException('请求超时');
    } on AppException catch (e) {
      lastError = e;
    } on Exception catch (e) {
      lastError = NetworkException(e.toString());
    }
    // （注意：刻意不写兜底 catch —— Error 类 bug 必须让它崩，见第 7 节）

    if (attempt < retries) {
      // 指数退避：200ms → 400ms → 800ms，配合抖动防止重试风暴
      final jitter = Random().nextInt(100);
      final delay = baseDelay * (1 << attempt) + Duration(milliseconds: jitter);
      print('第 ${attempt + 1} 次失败（$lastError），${delay.inMilliseconds}ms 后重试…');
      await Future<void>.delayed(delay);
    }
  }

  return Err(lastError);
}

// ============================================================
// 第三部分：模拟一个"抽风"的接口 + 页面层调用
// ============================================================
var callCount = 0;

/// 模拟后端：前 2 次超时，第 3 次成功
Future<Map<String, dynamic>> flakyApi() async {
  callCount++;
  if (callCount <= 2) {
    await Future<void>.delayed(const Duration(seconds: 1)); // 超过 timeout，必超时
    return {'code': 0};
  }
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return {'code': 0, 'data': '操作成功'};
}

Future<void> main() async {
  final result = await fetchRetry(flakyApi); // 泛型自动推断为 Result<Map<String, dynamic>>

  result.when(
    ok: (json) => print('最终成功：$json'),
    err: (e) => print('最终失败：$e（共尝试 ${maxRetries + 1} 次）'),
  );
}
```

输出（耗时不定，含随机抖动）：

```
第 1 次失败（TimeoutException: 请求超时），2xxms 后重试…
第 2 次失败（TimeoutException: 请求超时），4xxms 后重试…
最终成功：{code: 0, data: 操作成功}
```

这段 100 行代码把本篇全部内容串了起来：`sealed`/`switch` 穷尽（Result）、`on` 类型化捕获、异常层级设计、超时转译、指数退避、泛型任务抽象。07 网络篇会把 `flakyApi` 换成 `dio` 请求，把重试逻辑挪进拦截器，就是生产级网络层。

---

## 自测清单

- [ ] 能解释为什么判空后的**字段**仍不能直接用、标准解法是什么
- [ ] 能说出 `late` 的两个合法场景和三个运行时风险
- [ ] 能说出 `Future<T>` 与 `Promise<T>` 在错误类型上的共同"缺陷"，以及企业里的补法（Result）
- [ ] 知道 `Future.wait` 的 `eagerError` 与 `Promise.all` / `allSettled` 的对应关系
- [ ] 能区分单订阅 Stream 与广播流，并说出广播流"订阅前事件丢失"的坑
- [ ] 能解释 Dart 单线程为什么不会因重计算而"天然安全"，以及什么活该搬去 Isolate
- [ ] 能说出 `Exception` 与 `Error` 的处置差异，以及 `rethrow` 与 `throw e` 的区别
- [ ] 能画出"底层抛异常 → Repository 转 Result → UI 展示"的错误流转约定

## 延伸阅读

- [空安全（Null Safety）完整规则](https://dart.dev/null-safety/understanding-null-safety)
- [异步编程：Future / async-await](https://dart.dev/language/async)
- [异步编程：Stream](https://dart.dev/libraries/async/using-streams)
- [dart:async 库文档（StreamController / unawaited 等）](https://dart.dev/libraries/async)
- [并发与 Isolate（Dart 3 并发模型）](https://dart.dev/language/concurrency)
- [泛型（Generics）](https://dart.dev/language/generics)
- [Mixin 与线性化](https://dart.dev/language/mixins)
- [错误处理（Exceptions）](https://dart.dev/language/error-handling)
- [Effective Dart：错误抛出与捕获约定](https://dart.dev/effective-dart/usage#error-handling)
- [build_runner 使用指南](https://dart.dev/tools/build_runner)
- [包与 pub 工具](https://dart.dev/guides/packages)
