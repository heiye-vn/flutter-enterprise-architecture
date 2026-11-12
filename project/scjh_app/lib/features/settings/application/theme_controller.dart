import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/storage/prefs_repository.dart';

/// 主题模式控制器。
///
/// 初始化时从本地同步读取，切换时先改内存状态再落盘 ——
/// 用户点完立刻看到变化，不用等 IO。
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => getIt<PrefsRepository>().readThemeMode();

  Future<void> setMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await getIt<PrefsRepository>().writeThemeMode(mode);
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);
