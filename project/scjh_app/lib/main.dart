import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/injection.dart';

/// 启动入口。
///
/// 顺序很重要：
/// 1. 绑定 Flutter 引擎；
/// 2. 注册依赖（含读取 token、恢复会话）；
/// 3. 再 runApp —— 保证首帧就能拿到登录态，
///    否则会先闪一下登录页再跳回首页。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ProviderScope(child: ScjhApp()));
}
