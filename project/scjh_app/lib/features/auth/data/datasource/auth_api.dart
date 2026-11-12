import '../../../../core/network/api_client.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';

/// 认证接口的数据源契约。
///
/// 抽象出接口是为了让 Mock 和真实实现可以互换 ——
/// DI 里换一行注册，整个 App 就从假数据切到真后端。
abstract interface class AuthApi {
  Future<LoginResponseDto> login(LoginRequestDto dto);

  Future<UserDto> fetchMe();

  /// 返回新的 accessToken，失败返回 null。
  Future<String?> refresh(String refreshToken);
}

/// 真实实现：只说"接口语言"，不做任何业务判断。
class AuthApiRemote implements AuthApi {
  AuthApiRemote(this._client);

  final ApiClient _client;

  @override
  Future<LoginResponseDto> login(LoginRequestDto dto) async {
    final json = await _client.postJson<Map<String, dynamic>>(
      '/auth/login',
      data: dto.toJson(),
    );
    return LoginResponseDto.fromJson(json);
  }

  @override
  Future<UserDto> fetchMe() async {
    final json = await _client.getJson<Map<String, dynamic>>('/auth/me');
    return UserDto.fromJson(json);
  }

  @override
  Future<String?> refresh(String refreshToken) async {
    final json = await _client.postJson<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return json['accessToken'] as String?;
  }
}
