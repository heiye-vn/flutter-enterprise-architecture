import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// 轻量偏好仓储。
///
/// shared_preferences 在 `getInstance()` 之后是同步读、异步写，
/// 正好满足"启动时读主题、切换时写"的场景。
class PrefsRepository {
  PrefsRepository(this._prefs);

  final SharedPreferences _prefs;

  ThemeMode readThemeMode() => switch (_prefs.getString(StorageKeys.themeMode)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(StorageKeys.themeMode, mode.name);

  String? get lastAccount => _prefs.getString(StorageKeys.lastAccount);

  Future<void> saveLastAccount(String account) =>
      _prefs.setString(StorageKeys.lastAccount, account);

  String? get cachedUserJson => _prefs.getString(StorageKeys.cachedUser);

  Future<void> saveCachedUser(String json) =>
      _prefs.setString(StorageKeys.cachedUser, json);

  Future<void> clearCachedUser() => _prefs.remove(StorageKeys.cachedUser);
}
