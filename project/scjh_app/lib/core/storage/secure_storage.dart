import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Token 存储。
///
/// 两个设计点：
/// 1. token 属于敏感数据，必须走 Keychain / Keystore，不能放 shared_preferences；
/// 2. 启动时 `init()` 一次读进内存，之后同步读取 ——
///    这样路由守卫、拦截器都不需要 await，避免"首帧闪一下登录页"。
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  bool get hasSession => (_accessToken ?? '').isNotEmpty;

  Future<void> init() async {
    _accessToken = await _storage.read(key: StorageKeys.accessToken);
    _refreshToken = await _storage.read(key: StorageKeys.refreshToken);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    if (refreshToken != null) {
      _refreshToken = refreshToken;
      await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    }
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }
}
