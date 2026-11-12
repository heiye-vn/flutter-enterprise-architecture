import 'dart:convert';

import '../../../../core/storage/prefs_repository.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entity/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_api.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';

/// 认证仓库实现。
///
/// **token 永远不出这一层**：Controller 和 UI 自始至终不知道 token 存在，
/// 所以 401 刷新才能对全 App 透明完成。
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.api,
    required this.storage,
    required this.prefs,
  });

  final AuthApi api;
  final SecureStorage storage;
  final PrefsRepository prefs;

  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  void restoreSession() {
    if (!storage.hasSession) return;
    final raw = prefs.cachedUserJson;
    if (raw == null || raw.isEmpty) return;
    try {
      final dto = UserDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _currentUser = dto.toEntity();
    } on Object {
      // 缓存结构变了就当没登录，不要因为脏数据卡在启动页。
      _currentUser = null;
    }
  }

  @override
  Future<User> login({
    required String account,
    required String password,
  }) async {
    final response = await api.login(
      LoginRequestDto(account: account, password: password),
    );

    await storage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    await prefs.saveLastAccount(account);
    await prefs.saveCachedUser(jsonEncode(response.user.toJson()));

    final user = response.user.toEntity();
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await storage.clear();
    await prefs.clearCachedUser();
  }
}
