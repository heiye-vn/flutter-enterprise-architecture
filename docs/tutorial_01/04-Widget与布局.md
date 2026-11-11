# 04 Widget 与布局

> **本篇目标**：建立 Flutter UI 的完整心智模型——"一切皆 Widget"、生命周期、三棵树、约束传递，然后把常用布局、滚动、表单、主题、通用状态页按企业习惯落地成代码。读完你写的页面应该是"可维护的组件树"，而不是一坨 main.dart 里的嵌套地狱。
>
> **前置阅读**：[Flutter 工程入门](03-Flutter工程入门.md)——你需要已经能 `flutter run` 并使用热重载。
>
> **学完你能做什么**：
> - 把任意一张设计稿翻译成正确的 Widget 组合，而不是靠试错碰运气
> - 说清每个生命周期钩子与 React/Vue 的对应关系，理解三棵树，能解释"为什么列表要给 key"、"const 构造为什么白赚性能"
> - 独立封装企业级表单、分页列表、空态/错误态组件，并知道组件拆分边界在哪

---

## 1. 心智迁移：一切皆 Widget

前端的世界观是"一切皆组件（Component）"，Flutter 的世界观是**一切皆 Widget（Widget）**——听起来一样，边界差很多：

| | 前端组件 | Flutter Widget |
|---|---|---|
| 承载内容 | UI、交互、部分布局 | UI、交互、布局、缩放、裁剪、手势、动画、**连 `Padding` 都是 Widget** |
| 排版能力来源 | CSS（盒模型、流式布局、flex） | **没有 CSS**。间距、对齐全部显式嵌套表达 |
| 存在形式 | 函数/类，实例是运行时对象 | **不可变的配置对象（immutable configuration）** |

第三条是本质差异：`const Text('你好')` 不是"渲染出一个文本"，而是**一份描述"这里应该有个文本"的不可变配置清单**——概念上非常接近 `React.createElement()` 返回的 React Element：轻量、可丢弃、每次重建。每个 Widget 类都标注 `@immutable` 且所有字段 `final`——"改 UI"永远是**换一份新配置**，而不是改旧对象。这是三棵树与 key 机制的全部前提。

## 2. 生命周期：StatelessWidget 与 StatefulWidget

### 2.1 两类组件怎么选

- **StatelessWidget**：build 结果完全由入参决定，自身无状态。≈ 无 state 的 React 函数组件 / Vue 无 data 的 SFC。
- **StatefulWidget**：内部持有可变状态，需要 State 对象。≈ 有 state / 用了响应式数据的组件。

**企业口径：能用 Stateless 就不用 Stateful**。状态越少，重建越便宜、测试越好写。判断标准：这个组件自己会产生/持有数据吗（输入内容、加载态、动画进度）？不会就 Stateless。

### 2.2 完整生命周期演示

```dart
// lib/examples/lifecycle_demo.dart —— 每个钩子打出来看触发顺序
import 'package:flutter/material.dart';

class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key, required this.title});
  final String title; // 父组件传入的"配置"，相当于 React 的 props

  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  int _count = 0;

  @override
  void initState() {
    super.initState(); // 永远第一行调 super
    debugPrint('1. initState'); // 只执行一次：发首屏请求、创建 controller / 订阅，都放这
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // initState 后必调一次；此后环境值（Theme、MediaQuery）变化时再调
    debugPrint('2. didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant LifecycleDemo oldWidget) {
    super.didUpdateWidget(oldWidget); // 父组件传入新配置，"props 变没变"只能拿 oldWidget 手动 diff
    if (widget.title != oldWidget.title) debugPrint('didUpdateWidget: title 变了');
  }

  void _increment() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    debugPrint('3. build —— 会被反复调用，必须纯净快速');
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: Text('$_count')),
      floatingActionButton: FloatingActionButton(onPressed: _increment, child: const Icon(Icons.add)),
    );
  }

  @override
  void dispose() {
    debugPrint('4. dispose'); // 永久移除：释放 controller、取消订阅，防内存泄漏
    super.dispose();
  }
}
```

### 2.3 生命周期对照表（前端速查）

| Flutter（State） | 触发时机 | React 类比 | Vue 3 类比 |
|---|---|---|---|
| `createState` | State 对象创建（几乎不写逻辑） | 实例化组件 | `setup()` 开始 |
| `initState` | 挂载后、首帧前，**仅一次** | `componentDidMount` / `useEffect(fn, [])` | `onMounted` |
| `didChangeDependencies` | initState 后必调一次；依赖的环境值变化时再调 | 无直接对应（最接近 useEffect 对依赖变化的响应） | `watchEffect` 依赖重跑 |
| `build` | 每次需要渲染：setState、父级重建、主题/键盘/MediaQuery 变化都可能触发 | render / 函数组件本体 | template 渲染函数 |
| `didUpdateWidget` | 父组件给了新配置 | `componentDidUpdate` / useEffect 依赖变化 | `watch(() => props.x)` |
| `setState` | 主动标记"需要重建" | `setState`（React）/ 直接改响应式数据（Vue） | `ref.value = x` |
| `deactivate` | 从树上被**暂时**移除（重排位置） | 无 | 几乎不用 |
| `dispose` | 永久移除，释放资源 | `componentWillUnmount` / useEffect cleanup | `onUnmounted` |
| `mounted`（属性） | State 是否还在树上 | `isMounted`（React 已废弃；**Flutter 官方鼓励用**） | `getCurrentInstance()` 非空 |

三条企业级铁律：

1. **build 必须是纯函数**：框架可能因主题切换、键盘弹出、父级重建随时调它——不要在 build 里发请求、做重计算、写副作用，和 React render 一条规矩。
2. **异步回来先查 `mounted`**：`await` 之后 State 可能已被销毁，直接 `setState` 会抛错（React 里"unmount 后 setState 告警"的强制版）：

```dart
final data = await api.fetch();
if (!mounted) return; // 异步缺口后的标准动作，企业代码必写
setState(() => _items = data);
```

3. **`initState` 里取不到环境值**：`Theme.of(context)` 在 initState 中不能用（依赖关系还没建立），要用就挪到 `didChangeDependencies`——React 没有的坑，记住即可。

### 2.4 const 构造：免费的全自动 memo

const 构造的 Widget 实例在多次 build 之间是**同一个对象**。父级重建时，框架发现新旧 widget `identical`，**整棵子树直接跳过重建**——效果相当于免费的、全自动的 `React.memo`，还不需要比较函数；代价是所有字段必须 `final`（企业 lint `prefer_const_constructors` 会推着你写）。结论：**能加 const 就加——`Text('共 128 条记录')` 每次父级 rebuild 都创建新实例带动子树重建，`const Text('共 128 条记录')` 直接短路。这是 Flutter 里性价比最高的性能习惯**。

## 3. 三棵树：Widget → Element → RenderObject

### 3.1 为什么 Widget 不干活

Widget 只是配置。真正组成界面的是三棵并行的树：

```
Text('你好')                                  ← Widget 树：不可变配置（≈ React Element / vnode）
   ↓ 框架 inflate
Element（持有 State、对 RenderObject 的引用）  ← Element 树：真正存活的实例（≈ Fiber 节点 / 组件实例）
   ↓ create / update
RenderObject（如 RenderParagraph）             ← RenderObject 树：测量、布局、绘制（≈ 真实 DOM 节点 + 渲染层）
```

职责一句话版：**Widget** 说清"UI 是什么"（一次性配置，可全量重建，便宜）；**Element** 记住"谁是谁"（持久存在，做 diff/复用，持有 State）；**RenderObject** 决定"UI 怎么画"（布局、绘制、命中测试，重量级，尽量不动）。

### 3.2 Element：像虚拟 DOM，但策略不同

React 的 reconciliation 是"新 Element 树 diff 旧 Fiber 树，算出最小 DOM 操作"；Flutter 是**每次重建整棵 Widget 树，Element 树按规则逐节点复用**：

> **同一位置、runtimeType 相同、key 相等 → 复用 Element**（只替换 widget 引用），否则销毁 Element 及其 State，重新创建。

代码上就是 `Widget.canUpdate` 的判定：`oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key`。和 React"按类型 + 位置复用实例"的心智一致，但两点重要差异：① Element 树重建是**同步递归、一帧内必须算完**（React 有时间分片，Flutter 没有——build 慢就是掉帧，[性能优化](13-性能优化.md)会反复回到这一点）；② **State 挂在 Element 上**，Element 被销毁 State 就没了，下面的 key 就是控制"谁和谁算同一个 Element"的。

### 3.3 Key：什么时候必须给

经典翻车现场——两个有状态的色块，各自计数后交换顺序：

```dart
// lib/examples/key_demo.dart —— 复现"同类型同位置默认复用"的坑
import 'package:flutter/material.dart';

class KeyDemo extends StatefulWidget {
  const KeyDemo({super.key});
  @override
  State<KeyDemo> createState() => _KeyDemoState();
}

class _KeyDemoState extends State<KeyDemo> {
  var _tiles = const [_Tile(Colors.blue, 'A'), _Tile(Colors.amber, 'B')];

  void _swap() => setState(() => _tiles = List.from(_tiles.reversed)); // 交换顺序

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Key 演示')),
        floatingActionButton: FloatingActionButton(onPressed: _swap, child: const Icon(Icons.swap_horiz)),
        body: Row(children: _tiles), // ← 注意这里没给 key
      );
}

class _Tile extends StatefulWidget {
  const _Tile(this.color, this.label);
  final Color color;
  final String label;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  int _taps = 0; // 状态挂在 Element 上

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _taps++),
          child: Container(color: widget.color, alignment: Alignment.center, child: Text('${widget.label}: $_taps')),
        ),
      );
}
```

先给 A、B 各点几次，再点交换——**颜色换了，计数却留在原位置**。因为交换后 Row 的第一个位置仍然是"同类型 `_Tile`、位置 0、key 都是 null"，框架判定"是同一个 Element"，State（计数）原地不动，只是换了配置。

修复——列表项给 `ValueKey`（更规范的做法是让 `_Tile` 构造接收 `super.key` 后传入）：

```dart
Row(children: [for (final t in _tiles) KeyedSubtree.wrap(t, ValueKey(t.label))])
```

有了 key，Element 匹配从"同位置"升级为"**同 key 才算同一个**"，State 就跟着身份走了。

**何时需要 key（企业 checklist）**：

- ✅ 列表项**有状态**且**顺序/数量会变**（分页插入、拖拽排序）→ 用稳定业务 id：`ValueKey('feed_${item.id}')`
- ✅ 同一位置会在多个同类型组件间切换 → `ValueKey` 区分身份
- ❌ 纯展示、顺序不变的列表不需要 key；用数组 index 当 key 和 React 一样是坑

**GlobalKey 的风险**：它能跨树定位并复用 State（`key.currentState`），但全局注册有性能开销，且等于把组件实例放进全局注册表——变相的全局变量，耦合蔓延。**生产代码里 GlobalKey 基本只出现在 `FormState` 这种框架级用法上，业务组件不要靠它传状态**。

## 4. Scaffold 与 Material 组件体系

`flutter/material.dart` 提供一整套按 Material Design 规范实现的组件库——**相当于自带一套 antd/Element，且是平台级的**。页面骨架 `Scaffold` 提供移动端页面的标准槽位：`appBar`（顶栏，返回键自动处理）、`drawer`（抽屉）、`body`（内容区）、`floatingActionButton`（FAB）、`bottomNavigationBar`（底部导航）——**每页一个 Scaffold 是 Material 应用的惯例**。

高频对照：`FilledButton` / `ElevatedButton` / `TextButton` / `IconButton` ≈ antd Button 的 type 系列；`showDialog` ≈ Modal.confirm；`SnackBar` ≈ message 提示；`Chip` ≈ Tag；`NavigationBar` / `NavigationRail` ≈ 底部 Tabbar / 侧边菜单；`ListTile` ≈ 带图标/标题/尾箭头的列表行。

**Material vs Cupertino**：`cupertino.dart` 提供 iOS 风格组件（`CupertinoNavigationBar`、`CupertinoButton`…）。企业主流做法：**统一用 Material 3 保证双端一致**（B 端/企业应用的正确选择），少数需要平台质感的点用 `.adaptive` 变体（如 `Switch.adaptive` 在 iOS 上自动呈现 Cupertino 风格）；整页 Cupertino 只在面向 C 端且愿意维护两套 UI 时才考虑。

### 4.1 组件库的来源正在变：`material_ui` / `cupertino_ui` 独立包

这是 2026 年最需要留意的一次结构性变化，官方破坏性变更清单里标注为 "Not yet released to stable"（3.47 已可选择性启用）：

- **3.44 起**，框架内的 `package:flutter/material.dart`、`package:flutter/cupertino.dart` 进入**代码冻结**，只修 bug、不加新特性；
- **3.47 起**，Material / Cupertino 以独立包发布：`package:material_ui`、`package:cupertino_ui`（1.0.0），后续按周迭代，跟随自己的语义化版本；
- 框架内的旧库会在之后的稳定版**正式废弃**。

对你的实际影响，按项目阶段分三种情况：

```dart
// ① 新项目（推荐）：直接依赖独立包
// flutter pub add material_ui
import 'package:material_ui/material_ui.dart';   // 替代 import 'package:flutter/material.dart';
```

```bash
# ② 存量项目迁移：一条命令改完全部 import
dart fix --apply --code=migrate_design_widgets
# 如果 dart fix 没自动加依赖，手动补：
flutter pub add material_ui cupertino_ui
```

```dart
// ③ 过渡期：三方插件还在 import 老库时，用兼容桥补 Theme / Localizations 的向下注入
MaterialApp(
  builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
  // ...
)
```

兼容桥的**边界**必须清楚：它能解决"子组件从 context 读 Theme/Localizations"的问题，但解决不了**类型签名耦合**——某个包的公开 API 若接收/返回老库的 `ColorScheme`、`TextTheme`，那么新库的值传不进去（Dart 静态类型不认两个包里的同名类）。这类依赖只能等作者迁移。

本文示例为通用性统一写 `package:flutter/material.dart`（两套类名完全一致，不影响理解）；**实际开发以你所用 SDK 版本为准，新项目建议直接用 `material_ui`**。详见[版本演进与迁移速查](16-版本演进与迁移速查.md)。

## 5. 布局心智：约束（Constraints）自上而下

### 5.1 一条铁律

Flutter 布局只有一句话规则，官方原文：

> **Constraints go down. Sizes go up. Parent sets position.**
> （约束向下传递，尺寸向上汇报，位置由父级决定。）

每个父 Widget 给子 Widget 下发一个 **BoxConstraints**（`minWidth/maxWidth/minHeight/maxHeight` 四元组）：子 Widget 在约束内**自己决定**尺寸向上返回；父 Widget 决定**子放在哪**（子没有"把自己摆到中间"的能力，`Center` 是父级行为）；约束不可协商——**tight**（min == max，尺寸锁死，如 `Expanded` 给的约束）或 **loose**（min == 0，子随意，如 `Center` 放宽父约束后下发）。

与 CSS 的核心差异：

| CSS | Flutter |
|---|---|
| 盒模型 + 文档流隐式排版 | 无文档流，一切显式组合（Padding、Align 都是 Widget） |
| 子元素可 `overflow: visible` 溢出 | 子超约束直接**报错**（黄黑条纹警告条），逼你修 |
| `margin` 合并、相对视口的百分比 | 不存在；相对尺寸用 `Expanded` / `FractionallySizedBox` |

需要知道"父到底给了多少约束"时用 `LayoutBuilder`（≈ 容器查询 container query）直接拿 `constraints`：`constraints.maxWidth > 600 ? const WideLayout() : const NarrowLayout()`——响应式断点就用它。

新手第一报错必撞——Row 内放 ListView：

```dart
Row(children: [ListView(...)]),                    // ❌ ListView 想要无限宽，Row 给不了 → unbounded width
Row(children: [Expanded(child: ListView(...))]),  // ✅ Expanded 给 ListView "剩余宽度的 tight 约束"
```

把"约束"当成和"盒模型"同级的心智模型，布局问题就变成读题。

### 5.2 Container 的组合本质

`Container` 不是"div"，它是**语法糖组合器**：根据传入参数，在 child 外面套上对应的 Widget：

```dart
Container(
  width: 120, height: 80,            // → ConstrainedBox（tight 约束）
  padding: const EdgeInsets.all(12), // → Padding
  margin: const EdgeInsets.all(8),  // → Padding（对外）
  decoration: BoxDecoration(        // → DecoratedBox（背景/圆角/阴影/边框）
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
  ),
  child: const Text('卡片'),
)
// 等价于 Padding > DecoratedBox > ConstrainedBox > child 的嵌套
// 不传任何参数时 Container 原样返回 child —— 它自己不创造任何渲染行为
```

CSS 是"一个 div 上叠 20 条声明"，Flutter 是"20 条声明拆成 20 层 Widget 显式嵌套"。啰嗦，但**每一层都能被 DevTools 的 Layout Explorer 看见、解释、单独调试**——拿可读性换确定性，值。

## 6. 高频布局组件与完整示例

先给对照表：

| Flutter | CSS 类比 | 说明 |
|---|---|---|
| `Row` / `Column` | `display: flex`（横向/纵向） | MainAxisAlignment=justifyContent，CrossAxisAlignment=alignItems |
| `Expanded(flex: n)` | `flex: n`（强制填满） | tight 约束：不问 child 意见，塞满剩余空间 |
| `Flexible` | `flex-grow + max-width`（允许更小） | loose 约束：child 可以小于剩余空间 |
| `Stack` + `Positioned` | `position: relative` 容器 + `position: absolute` 子项 | 定位上下文是 Stack 尺寸 |
| `Wrap` | `flex-wrap: wrap` | `spacing`=横向 gap、`runSpacing`=行间 gap |
| `AspectRatio` | `aspect-ratio: 16/9` | 宽度定了高度跟比例走（FittedBox 同理见下文示例） |
| `SizedBox` | `width/height` 定值 | 也当间距用；推荐 [gap](https://pub.dev/packages/gap) 包语义更好 |

`Expanded` 强制撑满哪怕内容很短，`Flexible` 允许用得比剩余空间少——面试题也是实战题。完整可运行示例：

```dart
// lib/examples/layout_demo_page.dart —— 高频布局组件全景演示
import 'package:flutter/material.dart';

class LayoutDemoPage extends StatelessWidget {
  const LayoutDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('布局组件演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // ① Row：spaceBetween ↔ justify-content: space-between；center ↔ align-items: center
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text('A'), Text('B'), Text('C')],
            ),
            // ② Expanded（强制填满） vs Flexible（可以更小）
            Row(children: [
              Expanded(child: ColoredBox(color: Colors.amber, child: Text('占满剩余空间'))),
              Flexible(child: ColoredBox(color: Colors.teal, child: Text('可以更小'))),
              ColoredBox(color: Colors.grey, child: Text('固定')),
            ]),
            // ③ Stack + Positioned：头像角标（position:relative + absolute），Stack 尺寸取最大的非定位 child
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(radius: 44, child: Icon(Icons.person, size: 48)),
                Positioned(
                  right: 18, top: 2, // ↔ position:absolute; right:18px; top:2px
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: Text('99+', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            // ④ Wrap：换行 chips（flex-wrap），spacing/runSpacing ↔ 两向 gap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('企业级')),
                Chip(label: Text('长标签也一样自动换行')),
              ],
            ),
            // ⑤ AspectRatio + FittedBox：宽高比 + 内容自适应缩放
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Colors.indigo.shade100,
                child: FittedBox(
                  fit: BoxFit.scaleDown, // 文本太长只缩小、不够长不放大
                  child: Text('一段可能很长的标题文字' * 3),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
```

## 7. 滚动：从 SingleChildScrollView 到 Slivers

### 7.1 滚动组件的层级选型

| 组件 | 场景 | 前端对照 |
|---|---|---|
| `SingleChildScrollView` | 少量内容防溢出（表单页） | `overflow: auto` 容器 |
| `Column`（不滚动） | 一屏放得下的固定内容 | 普通 flex 容器 |
| `ListView(children:)` | **少量、已知**条目（< 20 个） | 写死的列表 |
| `ListView.builder` | **大量/未知**条目 | 虚拟列表（vue-virtual-scroller） |
| `CustomScrollView` + Slivers | 混合内容长页面（头图+网格+列表） | 无直接对照，企业长页面标配 |

`ListView(children:)` 与 `.builder` 的区别必须讲透：`children:` 会**一次性构造全部条目的 Widget 实例**，列表重建时全部重建；`.builder` 是**懒构建**——只为可视区域附近的条目调用 `itemBuilder`，滚动到才创建。10 条无所谓，1000 条就是两个世界。企业规范一刀切：**条目数量不确定/可能增长，一律 `.builder`**，定高条目顺手声明 `itemExtent` 跳过逐项测量。坑：`shrinkWrap: true`（列表自己算高度）对长列表性能很差，`CustomScrollView` 才是正解；`ListView` 套 `ListView` 会报 unbounded 约束错——同治。

### 7.2 CustomScrollView + Slivers：企业长页面标配

Sliver（滚动视口的可滚动子块）让"头图吸顶 + 统计卡 + 网格 + 长列表"出现在**同一个滚动上下文**里——商详页、个人中心的标准结构：

```dart
// lib/features/profile/pages/profile_page.dart —— 企业长页面的典型结构
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ① 头图区：滚动收起，收起后标题吸顶 —— 普通 Scaffold AppBar 做不到
          const SliverAppBar(
            pinned: true, // 收起后固定为普通 AppBar
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('张三'),
              background: DecoratedBox(
                decoration: BoxDecoration(color: Colors.indigo),
                child: Icon(Icons.person, size: 96, color: Colors.white),
              ),
            ),
          ),
          // ② 固定内容：普通 Widget 用 SliverToBoxAdapter 包一层塞进来
          const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(16), child: Text('黄金会员 · 2026-11-11 到期', textAlign: TextAlign.center))),
          // ③ 长列表区：Sliver 版的 .builder（网格用 SliverGrid，思路相同）
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text('动态 $index'),
              ),
              childCount: 100,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 7.3 下拉刷新 + 懒加载分页：完整企业骨架

`RefreshIndicator`（下拉刷新）的 `onRefresh` 返回 `Future`，圈圈自动结束；分页接入点在 `ScrollController` 的滚动监听。这是后端列表页的完整范式：

```dart
// lib/features/feed/models/feed_item.dart
class FeedItem {
  const FeedItem({required this.id, required this.title});
  final String id;
  final String title;
}

// lib/features/feed/repositories/feed_repository.dart
// 页面不直接碰 HTTP，统一走 Repository（≈ 前端 service 层）；接真实 API 只改这里（07 篇换 dio）
import 'dart:math';
import '../models/feed_item.dart';

class FeedRepository {
  Future<List<FeedItem>> fetch({required int page, required int size}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络
    return List.generate(size, (i) => FeedItem(id: 'p${page}_$i', title: '第 $page 页 · 第 ${i + 1} 条'));
  }
}
```

```dart
// lib/features/feed/pages/feed_page.dart —— 分页 + 下拉刷新的企业级骨架
import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import '../repositories/feed_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _repo = FeedRepository();
  final _scrollCtrl = ScrollController(); // 挂到 ListView 上监听滚动
  static const _pageSize = 20;

  final List<FeedItem> _items = [];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll); // 订阅在 initState、释放在 dispose —— 对应 useEffect cleanup
    _refresh();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose(); // 不释放就是内存泄漏
    super.dispose();
  }

  void _onScroll() {
    // 距底部不足 200px 且空闲 → 拉下一页
    if (_scrollCtrl.position.extentAfter < 200 && !_loading && _hasMore) _loadMore();
  }

  Future<void> _refresh() async {
    setState(() { _loading = true; _hasMore = true; });
    try {
      final list = await _repo.fetch(page: 1, size: _pageSize);
      if (!mounted) return; // 异步缺口后先查 mounted（2.3 铁律）
      setState(() {
        _items..clear()..addAll(list);
        _page = 1;
        _hasMore = list.length == _pageSize;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loading) return; // 防抖：滚动监听一帧能触发多次
    setState(() => _loading = true);
    try {
      final list = await _repo.fetch(page: _page + 1, size: _pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(list);
        _page += 1;
        _hasMore = list.length == _pageSize;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(), // 内容不满一屏也能下拉
          itemCount: _items.length + (_hasMore ? 1 : 0), // 尾部多一个"加载中"占位
          itemBuilder: (context, index) {
            if (index >= _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final item = _items[index];
            // 有状态/可变列表必须给 key；条目应抽成 FeedTile 组件（见第 11 节拆分原则）
            return ListTile(
              key: ValueKey('feed_${item.id}'),
              leading: const Icon(Icons.article_outlined),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
            );
          },
        ),
      ),
    );
  }
}
```

骨架里的企业细节：`mounted` 守卫、加载防抖、`itemCount` +1 的尾占位、`ValueKey` 用业务 id、内容不满屏也可下拉（`AlwaysScrollableScrollPhysics`）。

## 8. 表单：TextField、Form 与企业级封装

### 8.1 受控与非受控：Flutter 版

`TextField` 不传 controller 时内部自管状态——非受控（≈ `<input defaultValue>`）。企业表单一律**受控**：`TextEditingController` 持有值，`controller.text` 读写、`addListener` 监听（用完必须 `dispose()`）。校验与提交走 `Form` 体系：`Form`（≈ `<form>` + 校验上下文）+ `TextFormField`（Form 感知版 TextField，带 `validator`）+ `GlobalKey<FormState>`（框架级 GlobalKey 的合法用法）。

```dart
// lib/core/widgets/app_text_field.dart —— 企业级输入框基类
import 'package:flutter/material.dart';

/// 风格统一走主题（见第 9 节），这里零样式代码；参数设计：必填 required + 可选给默认值 + 回调命名 onXxx（对齐前端习惯）
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next, // 键盘"下一项"，移动端表单体验关键
  });

  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(labelText: label),
      );
}
```

```dart
// lib/features/login/repositories/auth_repository.dart —— mock 登录
class AuthRepository {
  Future<bool> login(String account, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return account == 'admin' && password == '123456';
  }
}
```

```dart
// lib/features/login/pages/login_page.dart —— 企业表单范式：校验 + 提交态 + 服务端错误
import 'package:flutter/material.dart';
import '../../../core/widgets/app_text_field.dart';
import '../repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // FormState：GlobalKey 的框架级合法用法
  final _accountCtrl = TextEditingController(); // 受控输入：值在 controller 里
  final _passwordCtrl = TextEditingController();
  final _repo = AuthRepository();

  bool _submitting = false;
  String? _serverError; // 服务端错误放表单级（≈ 字段校验 vs 提交错误两条线）

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus(); // 收起键盘
    if (!_formKey.currentState!.validate()) return; // 逐项触发 validator，失败自动标红
    setState(() { _submitting = true; _serverError = null; });
    try {
      final ok = await _repo.login(_accountCtrl.text, _passwordCtrl.text);
      if (!mounted) return; // 异步缺口后先查 mounted（2.3 铁律）
      if (!ok) setState(() => _serverError = '账号或密码错误');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Form(
        key: _formKey,
        child: ListView( // 表单页用 ListView：键盘弹出时内容可滚动避开
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: '账号',
              controller: _accountCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? '请输入账号' : null, // 行内校验规则
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: '密码',
              controller: _passwordCtrl,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (v) => (v == null || v.isEmpty) ? '请输入密码' : null,
              onSubmitted: (_) => _submit(), // 键盘"完成"直接提交
            ),
            if (_serverError != null) ...[
              const SizedBox(height: 12),
              Text(_serverError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 24),
            FilledButton( // 提交按钮三件套：loading、禁用、防重复提交 —— 企业表单标配
              onPressed: _submitting ? null : _submit, // null = 禁用态，样式自动置灰
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}
```

配套要点：① **校验时机**——默认提交时才校验，想"填错即时提示"给 `TextFormField` 加 `autovalidateMode: AutovalidateMode.onUserInteraction`；② **焦点管理**——`FocusNode` 控制焦点（≈ `ref.focus()`），用完同样要 `dispose()`；③ **第三方方案**——字段多、校验复杂时看 [flutter_form_builder](https://pub.dev/packages/flutter_form_builder)（声明式字段 + 内建校验器，≈ 把 antd Form 的 schema 化搬进 Flutter）或 [reactive_forms](https://pub.dev/packages/reactive_forms)，**先用官方 Form 体系写一遍再决定要不要引**，多数团队自封装就够。

## 9. 主题与文字：ThemeData 与 AppTextStyles

主题解决"全局视觉一致性"——所有 Material 组件默认从 `Theme.of(context)` 取样式，**业务代码里不该出现裸的 `Colors.blue`**（相当于前端在组件里写死 `#1890ff` 而不用 token）。

```dart
// lib/core/theme/app_text_styles.dart —— 全局文字样式 token（≈ design token 文件）
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(fontSize: 20, height: 1.4, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 14, height: 1.6);
  static const TextStyle caption = TextStyle(fontSize: 12, height: 1.4, color: Colors.grey);
}
```

```dart
// lib/core/theme/app_theme.dart —— 主题装配
import 'package:flutter/material.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)); // M3：种子色生成整套配色
    return ThemeData(
      colorScheme: scheme,
      textTheme: const TextTheme(
        titleLarge: AppTextStyles.pageTitle, // M3 文字阶梯：display/headline/title/body/label × Large/Medium/Small
        bodyMedium: AppTextStyles.body,
      ),
      inputDecorationTheme: const InputDecorationTheme( // 第 8 节 AppTextField 的风格在这统一生效
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData dark() =>
      ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), brightness: Brightness.dark));
}
```

```dart
// lib/app.dart —— 主题与暗色模式入口
MaterialApp(theme: AppTheme.light(), darkTheme: AppTheme.dark(), themeMode: ThemeMode.system) // 跟随系统；用户手动切换走持久化，见 08 篇
```

两套主题 + `themeMode` 就是暗色模式的全部入口；业务组件用 `Theme.of(context).colorScheme.primary` 取色，亮暗切换自动跟随。**禁止硬编码颜色**是 code review 的可执行标准。国际化、权限、埋点等通用能力（含暗色完整方案）见[企业级通用能力](11-企业级通用能力.md)。

### 9.1 配色 API 的四个版本事实（老教程最容易教错的地方）

1. **`useMaterial3` 自 3.16 起默认 `true`**，不需要再显式写。写了不报错，但别误以为是你开启的；网上大量 2023 年的文章还在教 `useMaterial3: true`，属于历史遗留。
2. **3.22 调整了 `ColorScheme` 角色**：`background` / `onBackground` / `surfaceVariant` 已废弃，替换关系是——

   | 废弃 | 替代 |
   |---|---|
   | `background` | `surface` |
   | `onBackground` | `onSurface` |
   | `surfaceVariant` | `surfaceContainerHighest` |

   同时新增一组**按色调分层的表面色**：`surfaceContainerLowest/Low/(默认)/High/Highest`、`surfaceDim`、`surfaceBright`。企业做"卡片 / 浮层 / 选中态"的视觉分层，用这组角色，不要再靠 `Colors.black.withOpacity(0.05)` 叠透明度。

   ```dart
   final cs = Theme.of(context).colorScheme;
   Container(color: cs.surfaceContainerLow);       // 卡片底
   Container(color: cs.surfaceContainerHighest);   // 次级面板 / 选中态
   Text('说明', style: TextStyle(color: cs.onSurfaceVariant));
   ```

3. **3.27 起 `Color.withOpacity()` 废弃**，改 `color.withValues(alpha: 0.5)`；读透明度 `color.opacity` 改 `color.a`。原因：颜色分量改为浮点存储以支持 Display P3 广色域，`withOpacity` 会把 alpha 量化到 0–255，`.a` 才能拿到真实浮点值（`withOpacity(0.5).a` 是 `0.5019...`，`withValues(alpha: 0.5).a` 才是 `0.5`）。
4. **3.41 又更新了一轮 Material 3 token 与取色算法**：升级后原有配色观感可能有细微变化，属预期行为。若希望高饱和种子色不被算法压暗，用 `ColorScheme.fromSeed(seedColor: ..., dynamicSchemeVariant: DynamicSchemeVariant.fidelity)`。

## 10. 通用 UI 模式：加载态 / 空态 / 错误态

企业应用的每个列表页、详情页都逃不开四种状态。写在每个页面里是重复劳动，标准做法是抽成 core 组件（对应前端项目的 `EmptyState.vue` / `ErrorPage.tsx`）：

```dart
// lib/core/widgets/state_views.dart —— 企业标配三件套
import 'package:flutter/material.dart';

/// 空态视图：后端返回空列表时的整页提示
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.title, this.subtitle, this.actionText, this.onAction});

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(title, style: tt.titleMedium),
          if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: tt.bodySmall)],
          if (actionText != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onAction, child: Text(actionText!)),
          ],
        ],
      ),
    );
  }
}

/// 错误视图：必须带重试，否则用户只能杀进程
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
}

/// 加载视图：整页 loading
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(), SizedBox(height: 12), Text('加载中…')],
        ),
      );
}
```

配一个状态容器把四态收敛到一处：

```dart
// lib/core/widgets/load_state_container.dart —— 四态统一分发
import 'package:flutter/material.dart';
import 'state_views.dart';

enum LoadState { loading, empty, error, success }

class LoadStateContainer extends StatelessWidget {
  const LoadStateContainer({
    super.key,
    required this.state,
    required this.child,
    this.error = '加载失败，请稍后重试',
    this.onRetry,
  });

  final LoadState state;
  final Widget child;
  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
        // Dart 3 switch 表达式：四态分发一目了然（01 篇讲过的模式匹配）
        LoadState.loading => const LoadingView(),
        LoadState.empty => EmptyView(title: '暂无数据', actionText: onRetry != null ? '刷新' : null, onAction: onRetry),
        LoadState.error => ErrorView(message: error, onRetry: onRetry),
        LoadState.success => child,
      };
}
```

页面里只声明状态、不写状态 UI：`LoadStateContainer(state: _state, onRetry: _refresh, child: const OrderListView())`——第 7 节的 `FeedPage` 用它包住 ListView，加载/空/错误态的处理就全部收敛到一处，这就是组件抽象的回报。

## 11. 自定义组件拆分原则

什么时候抽组件、怎么设计参数，企业 code review 的日常判断题。四条原则：

1. **单一职责**：一个组件文件只回答一件事。`LoginPanel` 只管表单布局，请求逻辑在页面/Repository，样式在主题——**UI、状态、副作用三层分离**（[应用架构设计](09-应用架构设计.md)展开成完整架构）。
2. **复用第二次就抽**：第一次复制粘贴是容忍，第二次是技术债。`FeedTile` → 通用 `ListRow` 的时机由"第三次想复制"触发。
3. **嵌套过深就拆**：build 里嵌套超过 5、6 层就该按"区域"拆成私有 Widget（`_QuickEntry` 式的 `_Xxx` 类）。**拆展示结构，不拆构建逻辑**。
4. **参数设计三规矩**：必填参数 `required` + 构造首位，可选参数给默认值；回调一律 `onXxx` 命名，类型用 `VoidCallback` / `ValueChanged<T>`（对齐前端 props/emit 心智）；**少给开关、多给组合**——`isVip` / `showBadge` / `isCompact` 布尔参数堆 5 个，说明该拆成两个组件。

另两条通用习惯：**状态下沉、事件上浮**——状态放在需要它的最低层组件（React"状态提升"的场景要想清楚谁消费）；**能 const 全 const**（见 2.4）。

## 12. 组件速查表：Flutter → 前端心智对照

| Flutter Widget | 前端对照 | 备注 |
|---|---|---|
| `Text` / `Text.rich`（TextSpan） | `<span>` / 富文本 | 样式走 textTheme，别 inline 写死 |
| `Image.network` / `Image.asset` / `Icon` | `<img>` / iconfont | 远程图配 [cached_network_image](https://pub.dev/packages/cached_network_image)；Material Icons 内置 |
| `Container` | `<div>` | 组合器，见 5.2 |
| `SizedBox` / `Padding` / `Center` / `Align` | 定值盒子 / `padding` / flex 居中 | 全部显式化为 Widget；间距也可用 gap 包的 `Gap(8)` |
| `Row` / `Column` + `Expanded` / `Flexible` / `Spacer` | `display:flex` + `flex` / `flex-grow` | 主轴=justifyContent、交叉轴=alignItems，见第 6 节 |
| `Stack` / `Positioned` | `position:relative` + `absolute` | 角标、蒙层、英雄区 |
| `Wrap` / `AspectRatio` / `FittedBox` | `flex-wrap` / `aspect-ratio` / `transform: scale` | 见第 6 节演示 |
| `Opacity` / `Visibility` / `Offstage` | `opacity` / `v-if` / `v-show` | Offstage 保留树只隐藏；大面积 Opacity 性能差 |
| `SingleChildScrollView` / `ListView` / `GridView` / `CustomScrollView` | `overflow:auto` / 列表 / 网格 / 无直接对照 | 滚动全家桶，见第 7 节 |
| `TextField` / `TextFormField` + `Form` | `<input>` / `<form>` | 受控用 controller，校验上下文见 8.1 |
| `ElevatedButton` / `FilledButton` / `TextButton` / `IconButton` | Button type 系列 | |
| `Switch` / `Checkbox` / `Radio` | 同名控件 | `Switch.adaptive` 随平台样式 |
| `ListTile` / `AlertDialog` / `SnackBar` | 列表行 / Modal.confirm / message 提示 | showDialog 函数式打开 |
| `GestureDetector` / `InkWell` | 原生事件绑定 | InkWell 带水波纹反馈，首选 |
| `Scaffold` / `AppBar` / `NavigationBar` | 页面壳 | 见第 4 节 |
| `Theme` / `MediaQuery` / `LayoutBuilder` | design token / viewport / 容器查询 | 见第 9 节、5.1 |
| `FutureBuilder` / `StreamBuilder` | 请求 loading→data 渲染模式 | 小场景好用，复杂状态走 06 篇 |
| `SafeArea` | 安全区处理（刘海屏） | 页面顶层常备 |

---

## 自测清单

- [ ] 能说出 Widget / Element / RenderObject 三棵树各自的职责，以及"Widget 是不可变配置"意味着什么
- [ ] 能解释为什么 build 必须是纯函数、哪些情况会导致 build 被多次调用
- [ ] 能背出 `initState` / `didChangeDependencies` / `didUpdateWidget` / `dispose` 分别对应 React/Vue 的什么
- [ ] 能解释 const 构造为什么能跳过子树重建（和 React.memo 的异同）
- [ ] 能复现"列表交换后状态错位"的 key 演示，并说出企业里列表 key 的正确取值
- [ ] 能用"Constraints go down, sizes go up"解释 Row 内 ListView 报 unbounded 错误的原因与修复方式
- [ ] 能说清 `Expanded` 与 `Flexible`、`ListView(children:)` 与 `.builder` 的区别
- [ ] 能默写企业表单提交按钮的三件套（loading、禁用、防重复）和异步后的 `mounted` 守卫

## 延伸阅读

- [Widget 简介（官方）](https://docs.flutter.dev/ui/widgets-intro) / [构建布局（官方教程）](https://docs.flutter.dev/ui/layout) / [Widget 目录（组件速查官方版）](https://docs.flutter.dev/ui/widgets)
- [理解约束（Understanding constraints）](https://docs.flutter.dev/ui/layout/constraints)——官方出品的必读经典
- [架构总览（三棵树与渲染管线）](https://docs.flutter.dev/resources/architectural-overview) / [Key 类文档](https://api.flutter.dev/flutter/widgets/Key-class.html) / [State 生命周期 API](https://api.flutter.dev/flutter/widgets/State-class.html)
- [表单校验 Cookbook](https://docs.flutter.dev/cookbook/forms/validation) / [长列表 Cookbook](https://docs.flutter.dev/cookbook/lists/long-lists)
- 中文镜像：[docs.flutter.cn](https://docs.flutter.cn)（路径与 docs.flutter.dev 一致）
