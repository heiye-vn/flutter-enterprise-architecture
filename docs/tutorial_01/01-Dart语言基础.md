# 01 Dart 语言基础

> **本篇目标**：把 Dart 3 的核心语法一次性讲透，全程对照 JS/TS。读完你写的 Dart 代码应该能通过团队 `flutter analyze`，而不是"能跑就行"的 Demo 代码。
>
> **前置阅读**：[项目总览](00-README.md)——了解学习路线与版本口径（**Flutter 3.47 / Dart 3.13**，空安全强制）。
>
> **学完你能做什么**：写出符合企业 lint 规范的 Dart 代码；避开 `const`/`dynamic`/集合操作的高频坑；独立设计模型类、枚举、扩展方法，并知道它们与 JS/TS 的细微差异。

本篇所有完整示例都标注文件路径，放 `bin/` 下运行：`dart run bin/demo.dart`。另外记住一个设定：**每个 `.dart` 文件就是一个独立的库（library）**，文件名小写下划线风格——后面讲私有性时会用到。

---

## 1. 变量与类型系统

### 1.1 基本类型一览

| Dart | TS 大致对应 | 说明 |
|------|------------|------|
| `int` / `double` | `number` | Dart 区分整数与浮点；`num` 是两者共同父类 |
| `String` | `string` | 单双引号等价，UTF-16 |
| `bool` | `boolean` | **严格布尔**，没有 truthy/falsy（大坑，见 1.3） |
| `List<T>` | `T[]` / `Array<T>` | 有序可重复 |
| `Map<K, V>` | `Record<string, V>`（作为字典用时） | 键可以是任意类型 |
| `Set<T>` | `Set<T>` | 无序不重复 |
| `Record`（Dart 3） | 元组 / 匿名对象 | `(1, 'a')`，8.3 模式匹配用到 |

注意 `int` 和 `double` 是不同的静态类型，`num` 可以同时接收两者：

```dart
// bin/type_demo.dart
void main() {
  int a = 5;
  double b = 2.5;
  num c = a; // num 是 int/double 的父类，类似 TS 里 number 只有一档，Dart 细分
  c = b;     // OK

  // 常用数字操作（挑企业代码里高频的）
  print(5 / 2);                 // 2.5，除法结果总是 double，和 JS 一致
  print(5 ~/ 2);                // 2，截断除法（truncating division），Dart 特有
  print(b.toStringAsFixed(1));  // "2.5"，价格展示常用
  print(int.tryParse('abc'));   // null；parse 解不了会抛异常（02 篇展开）
}
```

> **坑**：Dart 编译到 Web 时 `int` 会被实现为 double 的特殊形态，超长整数运算在 Web 端可能有精度差异（企业项目若涉及 ID 大整数，以官方文档为准）。

### 1.2 声明方式：var / final / const

这是前端转 Dart 的**第一大坑区**。先看结论表：

| 声明 | 含义 | JS/TS 对照 |
|------|------|------------|
| `var x = 1` | 类型推断，之后类型锁定 | TS 的 `let x = 1`（推断后不能换类型） |
| `final x = 1` | 运行期只能赋值一次 | JS 的 `const`（绑定不可变，**内容可变**） |
| `const x = 1` | **编译期常量**，深度不可变 | JS 没有对应物；`Object.freeze` 只冻结一层，也不等价 |

```dart
// bin/const_demo.dart
void main() {
  // var：推断后类型就锁死了，这和 JS 里随便换类型完全不同
  var count = 10;
  // count = 'ten'; // ❌ 编译错误：A value of type 'String' can't be assigned

  // final：绑定不可变，内容可变 —— 这才是 JS const 的对应物
  final list = [1, 2];
  list.add(3); // ✅ 合法，等价于 JS 的 const arr = []; arr.push(3)

  // const：编译期常量，整个值深度冻结
  const frozen = [1, 2];
  // frozen.add(3); // ❌ 运行时抛错：Cannot add to an unmodifiable list
}
```

**把 `const` 讲透**——三条核心规则：① **编译期求值**，`DateTime.now()`、网络返回值、随机数都不可能是 `const`，但可以是 `final`；② **深度不可变**，`const []`、`const {}` 的整个值及内部元素都不可修改；③ **规范化（canonicalization）**，相同字面量的 `const` 值在内存中是**同一个实例**，用 `identical()` 验证：

```dart
// bin/const_canonical.dart
class Point {
  final int x;
  final int y;
  const Point(this.x, this.y); // const 构造函数：所有字段必须 final
}

void main() {
  const a = Point(1, 2);
  const b = Point(1, 2);
  print(identical(a, b)); // true！同一个实例，编译器复用

  final c = Point(1, 2);
  final d = Point(1, 2);
  print(identical(c, d)); // false，final 每次都 new

  // const 上下文（const context）：外层是 const 时，内部构造自动 const，不必层层写
  // 这是 Flutter 中 const TextStyle(...) 省略内部 const 的原因（04 篇大量出现）
  const theme = [Point(1, 1), Point(2, 2)];
  print(theme.length);
}
```

> **为什么企业代码疯狂追求 const**：Flutter 里 `const` Widget 会被框架识别为"和上次完全相同"，跳过重建，是零成本性能优化。团队 lint 一般会开 `prefer_const_constructors`、`prefer_const_literals_to_create_immutables`，你代码里报的很多黄条就是它在提醒你补 `const`。习惯上：默认 `final`/`var`，只在编译期常量场景写 `const`；局部变量优先 `var`/`final` 而非显式类型标注（Effective Dart 惯例），但**公开 API（类的字段、函数签名）必须显式标注类型**。

### 1.3 bool：没有 truthy/falsy

JS 里 `if (list.length)` 天经地义，Dart 直接编译报错。布尔判断只能用 `bool`：

```dart
// bin/bool_demo.dart
void main() {
  final list = [];
  // if (list.length) {}     // ❌ 编译错误：条件必须是 bool
  if (list.isEmpty) {}       // ✅
  if (list.isNotEmpty) {}    // ✅ 集合有专用属性，别写 !list.isEmpty
  // if ('') {}              // ❌ 空字符串不是 falsy；if (0) {} 同理
}
```

把 JS 的 truthy 直觉全部清空：`0`、`''`、`[]`、`null` 在 Dart 里都**不能**直接当条件用，判断空一律用 `isEmpty` / `isNotEmpty` / `!= null`。

### 1.4 dynamic vs Object：对应 TS 的 any vs unknown

| Dart | TS | 行为 |
|------|----|------|
| `dynamic` | `any` | **关闭静态检查**，随便调，运行时才知道对错 |
| `Object?` | `unknown` | 只能调用 Object 自身的成员（`toString` 等），做任何事前必须先收窄（`is` 判断） |

```dart
// bin/dynamic_demo.dart
void main() {
  dynamic a = 'hello';
  a.foo(); // ✅ 编译通过，运行时崩溃 —— 和 TS any 一样危险

  Object b = 'hello';
  // b.foo(); // ❌ 编译错误：Object 没有这个方法，在编译期就被拦下
  if (b is String) print(b.length); // ✅ 收窄后才能用，对应 TS unknown 的类型守卫
}
```

> **团队习惯**：`dynamic` 在代码评审里等同于 `any`，见到就要求解释理由。合法用途基本只有一种——处理 `jsonDecode` 返回的动态结构（07 网络篇会讲怎么尽早消灭它）。**优先用 `Object?` + `is` 收窄**，让错误暴露在编译期。
>
> 另一个 JS 习惯要戒掉：`var x;` 裸声明不带初始值，Dart 里它会被推断为 `dynamic` 并初始化为 `null`，是隐患源头。永远写全初始化或显式可空类型（02 篇）。

---

## 2. 字符串

```dart
// bin/string_demo.dart
void main() {
  // 插值：$var 或 ${表达式}，对应 JS 模板字符串
  final user = '李雷';
  print('你好，$user，合计：${29.9 * 3} 元'); // 复杂表达式用 ${}

  // 多行字符串：三个引号，类似 JS 的反引号换行
  final sql = '''
    SELECT * FROM orders WHERE user_id = 'u_1001'
  ''';

  // 原始字符串：r 前缀不做转义，正则表达式常用
  final pattern = r'\d{4}-\d{2}-\d{2}';

  // == 就是内容比较（String 重载了 ==），没有 ===
  print('abc' == 'abc'); // true

  // 常用方法（挑企业高频的）
  final s = '  Hello Dart  ';
  print(s.trim());                    // 去两端空白；substring 越界会抛 RangeError
  print('a,b,c'.split(','));           // ['a', 'b', 'c']
  print('a-b-c'.replaceAll('-', '_')); // 'a_b_c'
  print('flutter'.padLeft(10, '*'));   // '**flutter'，单号补位常用
  print('hello'.contains('ell'));      // 对应 JS includes

  // 拼接：+ 或相邻字面量自动连接（Dart 特色，'a' 'b' == 'ab'）
  print('a' 'b');
}
```

> **坑**：`substring(start, end)` 的 `end` 是开区间且越界抛异常，不像 JS 的 `slice` 有宽容行为，取子串前先判长度。

---

## 3. 函数

### 3.1 参数形态：与 JS 完全不同的三种

JS 的函数参数本质上是"全部可选的位置参数"，Dart 则分三种，企业 API 设计必须选对：

```dart
// bin/func_demo.dart
// 1. 位置必选参数：和 JS 前几个参数一样
// 2. 命名参数 {}：调用时必须写参数名，默认【可选】，required 才必填
void createUser({required String name, int age = 18, String? dept}) {
  print('$name $age $dept');
}

// 3. 可选位置参数 []：按顺序传、可省略，但必须放在参数表最后
String formatPrice(double raw, [int decimals = 2, String? prefix]) {
  return '${prefix ?? '¥'}${raw.toStringAsFixed(decimals)}';
}

void main() {
  // 命名参数：类似"JS 只用解构对象传参"的函数
  createUser(name: '韩梅梅', dept: '研发'); // age 用默认值 18

  // 可选位置参数：必须按顺序，不能跳过 decimals 只给 prefix
  print(formatPrice(9.9));
  print(formatPrice(9.9, 1, '\$'));

  // 坑：默认值只能给"可选"参数，必选参数不允许默认值
  // void f(String name = 'x') {} // ❌ 必选参数不能有默认值
}
```

与 TS 的关键差异：TS 的解构参数 `{ name }: { name: string }` 默认**全部必填**（除非加 `?`）；Dart 命名参数默认**全部可选**，必填反而要加 `required`。团队习惯：3 个以上参数、或参数有业务含义时一律用命名参数——`createUser('韩梅梅', null, true)` 这种 JS 式调用没人看得懂，`createUser(name: '韩梅梅', active: true)` 才可维护。

### 3.2 匿名函数、箭头函数与 typedef

```dart
// bin/func_lambda.dart
// typedef：函数类型的别名，对应 TS 的 type Handler = (code: number) => void
typedef OnError = void Function(int code, String message);

int doubleIt(int x) => x * 2; // 箭头 => 只能接"单个表达式"，比 JS 的 => 限制更死

void main() {
  final list = [1, 2, 3].map((x) => x * 2).toList(); // 匿名函数，同 JS 的 (x) => x * 2
  print(list); // [2, 4, 6]

  // 函数是一等公民：可以赋值、传参，对应 JS 回调
  void request(void Function() onSuccess, OnError onError) {}
  request(() => print('成功'), (code, msg) => print('失败：$code $msg'));
}
```

---

## 4. 类与构造函数

### 4.1 从 JS class 迁移：先看"最简可用"形态

```dart
// bin/class_demo.dart
class Order {
  final String id;      // 声明处不赋值的 final 字段，必须在构造时确定
  double amount;        // 可变字段
  String? note;         // ? 表示可空，02 篇展开

  // 构造函数 + this 简写：等价于 TS 的 constructor(private id: string, public amount: number)
  // 字段声明 + 参数 this.id 自动完成赋值，不用写 this.id = id
  Order(this.id, this.amount, {this.note});

  // 命名构造函数：JS 没有的能力，一个类可以有多个"入口"
  // 相当于 static Order empty() 的具名版本，语义更清晰
  Order.zero(String id) : this(id, 0); // 重定向到主构造函数
}

void main() {
  final o = Order('o_1001', 99.9, note: '尽快发货');
  print('订单 ${o.id} 金额 ${o.amount}');
  print(Order.zero('o_1002').amount); // 0.0，命名构造生效
}
```

### 4.2 初始化列表：final 字段的计算逻辑放这里

构造函数体 `{}` 执行时，字段其实已经初始化完毕。**给 final 字段做计算**只能用初始化列表（initializer list），它在构造体之前、且不能访问 `this`：

```dart
// bin/class_init_list.dart
class Rect {
  final double area; // 只暴露计算结果，不存宽高

  Rect(double w, double h) : area = w * h; // 冒号后是初始化列表，不能访问 this

  Rect.square(double side) : area = side * side; // 典型企业场景：派生值在命名构造里算
}

void main() {
  print(Rect(3, 4).area);     // 12.0
  print(Rect.square(5).area); // 25.0
}
```

### 4.3 私有性：`_` 前缀是库级约定

TS 的 `private` 是类级关键字；Dart 没有这个关键字，用**下划线前缀**表示私有，作用域是**整个库（文件）**而非单个类：

```dart
// bin/class_private.dart
class Cart {
  final List<String> _items = []; // 私有字段：仅本文件内可访问

  // 私有命名构造函数：配合 factory 实现单例的标配
  Cart._();

  static final Cart _instance = Cart._();

  factory Cart.instance() => _instance; // 对外唯一入口

  void add(String item) => _items.add(item);

  int get length => _items.length; // 只读暴露，外部拿不到 _items 引用
}

void main() {
  Cart.instance().add('iPhone');
  print(Cart.instance().length); // 1
  // Cart.instance()._items; // ❌ 若在其他文件里这样写会编译错误
}
```

> **团队习惯**：状态默认 `_` 私有 + 明确的 getter/方法暴露。与 TS `private` 的心智差异是——同一文件里的其他类**能**访问 `_` 成员（类似 internal），跨文件才隔离；企业里这反而是优点：强关联的类放同一文件，彼此可见，外部隔离。

### 4.4 getter / setter：按需拦截字段读写

```dart
// bin/class_getter.dart
class Product {
  final String name;
  final int _priceInFen; // 内部以"分"存储，避免浮点精度问题（企业支付常识）

  Product(this.name, this._priceInFen);

  // getter：外部当字段用，无括号 —— 等价 TS 的 get price()
  double get price => _priceInFen / 100;
  String get displayPrice => '¥${price.toStringAsFixed(2)}';

  // setter：可校验，但 Dart 社区更倾向"不可变 + 换新实例"，setter 少写
  // set price(double yuan) { ... }
}

void main() {
  print(Product('机械键盘', 39900).displayPrice); // ¥399.00
}
```

### 4.5 factory 构造：实例由你决定

普通构造函数必须返回新实例；`factory` 可以返回缓存、子类、甚至 null——**JSON 解析的标配**：

```dart
// bin/class_factory.dart
class ApiResponse {
  final int code;
  final String? message;
  const ApiResponse(this.code, this.message);

  bool get isOk => code == 0;

  // factory：JSON 解析的标配入口，类型收口
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(json['code'] as int, json['message'] as String?);
  }

  // factory 和命名构造结合：不同的失败形态
  factory ApiResponse.error(String message) => ApiResponse(-1, message);
}

void main() {
  print(ApiResponse.fromJson({'code': 0}).isOk); // true
  print(ApiResponse.error('网络超时').message); // 网络超时
}
```

对照 JS：JS class 做单例得手写 `static getInstance`，Dart 的 `factory` + 私有命名构造是语言级支持；TS 里 `fromJson` 静态方法的角色，在 Dart 惯例上用 `factory` 构造表达。

### 4.6 新语法：主构造函数（Dart 3.13 起稳定）

Dart 3.13 把 **primary constructors** 转正了，样板代码可以压成一行：

```dart
// 以前：字段 + 构造函数 + 逐个赋值
class Point {
  const Point(this.x, this.y);
  final int x;
  final int y;
}

// Dart 3.13：参数直接写在类名后，字段声明和构造合一
class Point(final int x, final int y);
```

配套还有 `class Foo.new(...)` / `class Foo.factory(...)` 的简写形式，以及 6 条新 lint 和 IDE 重构（"Convert to primary constructor"）。

**实践建议**：新代码里"构造函数体为空、只是赋字段"的类（DTO、Entity、配置对象）适合用；带校验、`assert`、或需要 `factory` 逻辑的类，老老实实写传统构造——**别为了短而短**。存量代码不建议专门重构，收益小于 review 成本。语言版本需设到 `sdk: ^3.13.0` 才生效（详见[版本演进与迁移速查](16-版本演进与迁移速查.md)）。

---

## 5. 继承与接口

### 5.1 extends 与 abstract class

单继承，`abstract class` 可同时含抽象方法与具体方法，和 JS/TS 心智一致：

```dart
// bin/class_extends.dart
abstract class BaseRepo {
  Future<Map<String, dynamic>> fetchRaw(String path); // 抽象方法：子类必须实现

  void logRequest(String path) => print('请求 $path'); // 具体方法：子类直接继承，同 TS
}

class OrderRepo extends BaseRepo {
  @override // 注解可不写，但团队 lint 通常强制要求，明确表达"我在覆写"
  Future<Map<String, dynamic>> fetchRaw(String path) {
    return Future.value({'code': 0});
  }
}
```

### 5.2 重点：每个类都隐式是一个接口

**这是 Dart 与 TS 差异最大的一处**。TS 是结构化类型（structural typing）：长得像就兼容；Dart 是名义类型（nominal typing）：写了什么类型名才算什么。并且——**任何类都自动可以作为接口被 implements**，无需显式声明 interface：

```dart
// bin/class_interface.dart
class UserStore {
  final String token;
  UserStore(this.token);

  void save(String key, String value) => print('save $key=$value');
}

// implements UserStore：把 UserStore 当接口用
// 它已有的【实现全部作废】，只保留成员签名，全部要自己重新实现
class FakeUserStore implements UserStore {
  @override
  String get token => 'fake-token'; // 字段也要实现成 getter

  @override
  void save(String key, String value) => print('（测试桩）假存储：$key=$value');
}

void main() {
  FakeUserStore().save('theme', 'dark');
}
```

和 TS 的 `implements` 对照：

| | TS | Dart |
|---|----|------|
| 接口来源 | 只能 `interface` / 类型别名 | **任何类**隐式是接口 |
| 匹配规则 | 结构匹配（不声明也兼容） | 名义匹配（必须写 implements） |
| implements 后 | 只约束类型，不用管实现 | **必须重新实现全部成员**，哪怕原类已实现 |
| 一个实现多个接口 | ✅ | ✅ `implements A, B` |

**企业里这有什么用**——测试替身：`class MockUserRepo implements UserRepo`，编译器强制你补齐所有方法；原仓库加新抽象方法时，所有 mock 立刻报错，不会漏。比 JS 时代手写 fake 对象可靠得多。另外 Dart 3 起你还会见到 `abstract interface class`（明确"这个类就是给人 implements 的"）和 `sealed class`（限制只能被同文件子类实现，配合 switch 穷尽检查，第 9 节实战，09 架构篇展开）。

---

## 6. 枚举与 extension

### 6.1 增强枚举：带字段和方法的枚举

Dart 2.17 后枚举可以拥有字段、构造函数（必须是 const）、getter、方法。企业里它基本替代 TS 的 `union type + 映射表`模式：

```dart
// bin/enum_demo.dart
enum OrderStatus {
  pending('待支付'),
  paid('已支付'),
  shipped('已发货'),
  done('已完成');

  final String label;            // 枚举可以带字段
  const OrderStatus(this.label); // 构造函数必须是 const

  // 枚举可以有方法、getter
  bool get canCancel => this == OrderStatus.pending || this == OrderStatus.paid;
}

void main() {
  final s = OrderStatus.paid;
  print(s.label);     // 已支付
  print(s.canCancel); // true

  // switch 表达式（Dart 3）+ 穷尽检查：漏一个 case 编译器直接报错
  // 比 TS 里 switch + never 的 exhaustiveness 检查更简单直接
  final canPay = switch (s) {
    OrderStatus.pending => true,
    OrderStatus.paid => false,
    OrderStatus.shipped => false,
    OrderStatus.done => false,
  };
  print(canPay); // false
}
```

与 TS 对照：TS 的 `type Status = 'pending' | 'paid'` 是字符串字面量联合，Dart 枚举是**真正的类型实例**（能带行为、能比较、能 switch 穷尽），能不用字符串魔法值的场景就别用。命名用 lowerCamelCase（`OrderStatus.pending`），与某些语言常量的全大写风格区分。

### 6.2 extension：给现有类型"加方法"

不修改原类、不碰 prototype，就能给 `String`、第三方类等扩展方法：

```dart
// bin/extension_demo.dart
extension StringX on String {
  // Dart 标准库没有 repeat（对应 JS 的 'a'.repeat(3)），自己补一个
  String repeat(int n) => List.filled(n, this).join();
}

extension MoneyX on num {
  String get yuan => '¥${toStringAsFixed(2)}';
}

void main() {
  print('ab'.repeat(3)); // ababab
  print(99.9.yuan);      // ¥99.90
}
```

两个必须知道的边界：**extension 是纯静态解析的**——通过 `dynamic` 类型调用扩展方法不生效，直接运行时报错（比 TS 声明合并的坑更隐蔽）；**同名冲突**——两个扩展都定义 `repeat` 时，调用处需用前缀消歧：`StringX('ab').repeat(3)`，或 import 时 `show`/`hide` 控制。团队习惯：`fromJson`/`toJson`、日期与金额格式化这类工具逻辑优先写成 extension 而不是 util 工具类，`json.toOrder()` 比 `OrderUtils.toOrder(json)` 顺眼得多。

---

## 7. 集合与函数式操作

### 7.1 与 JS 数组方法逐一对照

| 用途 | JS | Dart | 差异要点 |
|------|----|------|---------|
| 映射 | `map` | `map` | **Dart 返回惰性 Iterable，不消费不执行**，落盘要 `.toList()` |
| 过滤 | `filter` | `where` | 返回也是惰性 Iterable |
| 累计 | `reduce` | `reduce` / `fold` | `fold` 能换累加值类型（reduce 不能），优先 fold |
| 找首个 | `find` | `firstWhere` | **没匹配且不传 orElse 直接抛异常**，高频坑 |
| 存在 / 全部 | `some` / `every` | `any` / `every` | 一致 |
| 包含 | `includes` | `contains` | 一致 |
| 排序 | `sort` / `toSorted` | `sort` | **Dart sort 就地排序且返回 void**，要新列表用 `[...list]..sort()` |
| 切片 | `slice` | `sublist` | 越界抛错，不宽容 |
| 拼接 | `concat` | `+` / `followedBy` | `+` 两边类型必须一致 |
| 拍平 | `flat` | `expand` | expand 直接给"展开函数" |
| 去重 | `new Set(...)` | `toSet()` | 转 Set 再回列表 |

```dart
// bin/collection_demo.dart
void main() {
  final orders = [
    {'id': 'a', 'amount': 99.9, 'paid': true},
    {'id': 'b', 'amount': 199.0, 'paid': false},
    {'id': 'c', 'amount': 9.9, 'paid': true},
  ];

  // 坑1：map 返回的是惰性 Iterable（相当于 JS 生成器），不 toList() 不真正"落地"
  final ids = orders.map((o) => o['id']).toList(); // ['a','b','c']

  // 坑2：firstWhere 找不到会抛 StateError，一定要给 orElse
  final matched = orders.firstWhere(
    (o) => o['id'] == 'zzz',
    orElse: () => const {'id': 'none', 'amount': 0, 'paid': false},
  );

  // fold 换类型累计：这里 List -> double，reduce 做不到
  final total = orders.fold<double>(0, (sum, o) => sum + (o['amount'] as double));

  // 坑3：sort 返回 void（不是新数组），且是就地排序 —— 原 orders 被改了！
  final byAmountDesc = [...orders]..sort(
    (a, b) => (b['amount'] as double).compareTo(a['amount'] as double),
  );

  print('$ids / $matched / $total / ${byAmountDesc.first['id']}');
}
```

### 7.2 Map 与 Set 的日常

```dart
// bin/map_set_demo.dart
void main() {
  // Map 字面量：推断为 {String, int}
  final stock = {'apple': 5, 'banana': 3};

  // 坑：键不存在返回 null（值的静态类型因此可空，02 篇展开）
  print(stock['cherry']); // null

  stock['apple'] = 10;                  // 增改
  stock.putIfAbsent('cherry', () => 1); // 不存在才插入
  for (final e in stock.entries) {      // 对应 Object.entries
    print('${e.key}: ${e.value}');
  }

  // Set：去重 + 集合运算
  print({1, 2}.union({2, 3}));        // 并集 {1, 2, 3}
  print({1, 2}.intersection({2, 3})); // 交集 {2}
}
```

### 7.3 collection-if / collection-for 与可变性

Flutter 构建列表的核心语法糖，JS 没有直接对应（React 里要 `{cond && <X/>}`）：

```dart
// bin/collection_demo.dart
void main() {
  final isVip = true;

  final widgets = [
    '标题',
    '内容',
    if (isVip) '会员专属卡片',      // 条件插入
    for (var i = 1; i <= 3; i++)   // 循环插入
      '第 $i 条评论',
  ];
  print([...widgets, '尾部'].length); // spread 展开与 JS 一致

  // 可变性三档：
  final growable = [1, 2, 3];
  growable.add(4); // ✅ [] 默认可增长，final 不拦截内容修改
  final locked = List<int>.unmodifiable([1, 2]);
  // locked[0] = 9; // ❌ 运行时报错，真正只读
  const compileTime = [1, 2]; // const 列表：编译期 + 深度不可变（性能最优）
}
```

> **团队习惯**：模型层返回的列表，暴露出去前考虑 `.unmodifiable()` 或 `List.of`；跨层传"可被随手 add 的引用"是脏数据之源。深拷贝惯用 `[...old]`。

---

## 8. 运算符与模式匹配初步

### 8.1 空相关运算符（空安全详细规则在 02 篇）

```dart
// bin/ops_null.dart
void main() {
  String? name; // ? 声明可空

  print(name ?? '匿名'); // ?? 兜底，同 JS
  print(name?.length);   // ?. 可选链，和 TS 的 ?. 完全一致

  String? cache;
  cache ??= '首次生成'; // ??= 有值不动，无值赋值（JS 没有，缓存惯用）
  print(cache);

  print(name!.length); // ! 非空断言（同 TS 的 x!）：能不用就不用，它是"运行时裸奔"
}
```

### 8.2 级联（cascade）：一次初始化多次操作

JS 链式调用依赖"每个方法都返回 this"；Dart 的级联让任何对象都能连续操作，UI 初始化代码的高频写法：

```dart
// bin/ops_cascade.dart
class PageConfig {
  String title = '';
  int pageSize = 20;
}

void main() {
  final config = PageConfig()
    ..title = '订单列表' // 注意：开头是 .. 不是 .
    ..pageSize = 50;
  print('${config.title} / ${config.pageSize}');
  // 换 JS 写法：const c = new PageConfig(); c.title = '...'; c.pageSize = 50; ...
}
```

### 8.3 模式匹配初步（Dart 3）

switch 从"语句"升级为"表达式"，支持守卫、解构。这是 TS 至今没有的能力（TC39 提案阶段，以官方文档为准）：

```dart
// bin/pattern_demo.dart
String describe(Object obj) =>
    switch (obj) {
      int n when n > 0 => '正整数 $n', // 模式 + 守卫（when）+ 自动类型收窄
      int() => '非正整数',
      String s => '长度 ${s.length} 的字符串',
      [var first, ...] => '非空列表，头元素 $first',
      {'code': var code, 'msg': var msg} => '接口返回 $code: $msg',
      _ => '其他', // 通配符，对应 JS switch 的 default
    };

void main() {
  print(describe(42));  // 正整数 42
  print(describe('hello')); // 长度 5 的字符串
  print(describe({'code': 0, 'msg': 'ok'})); // 接口返回 0: ok

  // if-case：map 解构（对象解构见第 9 节 Result.when）
  const resp = {'type': 'ok', 'value': 99};
  if (resp case {'type': 'ok', 'value': var v}) {
    print('成功值：$v'); // 成功值：99
  }

  final (x, y) = (10, 20); // record 解构声明
  print(x + y); // 30
}
```

配合 `sealed` 使用时，switch 表达式漏掉任何子类会**编译报错**——类型系统替你守住"新分支必须处理"的底线，企业级代码的标配姿势（第 9 节实战）。

---

## 9. 综合练习：统一的 Result / 分页模型

企业网络层几乎必有这两个模型：`Result`（把"成功/失败"变成类型，而不是到处 try/catch）和 `Page`（统一分页字段），用本篇全部知识手写一版：

```dart
// bin/demo.dart
// 运行：dart run bin/demo.dart

// ============ Result：sealed + 模式匹配，编译期保证你处理了所有分支 ============
sealed class Result<T> {
  const Result();

  // when：把 switch 封装起来，外部一行处理成败（企业惯用法）
  R when<R>({
    required R Function(T value) ok,
    required R Function(String message) err,
  }) {
    return switch (this) {
      Ok(:final value) => ok(value), // 对象解构：直接取字段
      Err(:final message) => err(message),
    };
  }
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}

// ============ Page：统一分页模型，fromJson 带泛型解析函数（泛型细节 02 篇展开） ============
class Page<T> {
  final List<T> list;
  final int page;
  final int pageSize;
  final int total;

  const Page({required this.list, required this.page, required this.pageSize, required this.total});

  bool get hasMore => page * pageSize < total; // 是否还有下一页

  // 泛型工厂：调用方传"单条记录怎么解析"
  static Page<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    return Page<T>(
      list: (json['list'] as List)
          .map((e) => parseItem(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      total: json['total'] as int,
    );
  }
}

// ============ 模拟网络层 + 页面层 ============
class User {
  final String name;
  final int age;
  const User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['name'] as String, json['age'] as int);
}

// 模拟后端：page=3 时触发业务错误
Result<Page<User>> fetchUsers(int page) {
  if (page > 2) {
    return const Err('没有更多数据了');
  }
  final json = {
    'list': [
      {'name': '韩梅梅', 'age': 28},
      {'name': '李雷', 'age': 30},
    ],
    'page': page,
    'pageSize': 20,
    'total': 30,
  };
  return Ok(Page.fromJson(json, User.fromJson));
}

void main() {
  for (final page in [1, 3]) {
    fetchUsers(page).when(
      ok: (p) {
        final names = p.list.map((u) => '${u.name}（${u.age}岁）').join(' ');
        print('第${p.page}页：$names');
      },
      err: print, // 简化演示；正式写法 err: (msg) => print('加载失败：$msg')
    );
  }
}
```

输出：`第1页：韩梅梅（28岁） 李雷（30岁）` 与 `没有更多数据了`。这个示例浓缩了本篇全部要点：sealed 继承体系、命名构造与 factory、命名参数、getter、泛型、集合操作、模式匹配解构、when 封装。02 篇会把它升级成异步 + 完整错误处理的版本，07 网络篇会接上真实的 dio。

---

## 自测清单

- [ ] 能说出 `const` 与 `final` 的至少 3 个区别，并解释"JS 的 `const arr = []` 还能 push，Dart 哪个声明才对应它"
- [ ] 能说出 `dynamic` / `Object?` 分别对应 TS 的 `any` / `unknown` 的哪一半差异，以及 Dart 没有 truthy/falsy 时 `if (list.length)` 怎么改
- [ ] 能解释 Dart 命名参数默认可选、`required` 的含义，以及团队"3 个以上参数用命名参数"的理由
- [ ] 能写出带初始化列表的构造函数，并说明为什么 `final` 计算字段要放初始化列表
- [ ] 能说出 `implements UserStore` 与 TS `implements` 的核心差异（名义类型、必须重写全部成员）
- [ ] 知道 `firstWhere` 不传 `orElse` 会怎样、`map()` 为什么可能"没执行"
- [ ] 能解释 `sealed` + switch 表达式如何做到"漏分支编译报错"

## 延伸阅读

- [Dart 语言概览（官方语言向导）](https://dart.dev/language)
- [变量与作用域（含 final/const 细节）](https://dart.dev/language/variables)
- [函数](https://dart.dev/language/functions)
- [类与构造函数（含隐式接口）](https://dart.dev/language/classes)
- [枚举（增强枚举）](https://dart.dev/language/enums)
- [扩展方法](https://dart.dev/language/extension-methods)
- [集合与函数式操作](https://dart.dev/language/collections)
- [模式匹配（Patterns）](https://dart.dev/language/patterns)
- [Effective Dart 风格指南与 Lint 规则](https://dart.dev/effective-dart)
