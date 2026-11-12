import '../../../../core/config/env_config.dart';
import '../../../../core/error/app_exception.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';
import 'auth_api.dart';

/// 认证接口的内存假实现。
///
/// 规则：
/// - 密码 ≥ 6 位即登录成功；
/// - 密码 < 6 位返回业务错误，用来验证错误回流链路。
class AuthApiMock implements AuthApi {
  const AuthApiMock();

  static const String _demoPasswordHint = '演示环境：任意账号 + 6 位以上密码';

  @override
  Future<LoginResponseDto> login(LoginRequestDto dto) async {
    await Future<void>.delayed(EnvConfig.mockLatency);

    if (dto.password.length < 6) {
      throw const BusinessException(
        code: 40001,
        message: '账号或密码错误（演示环境请输入 6 位以上密码）',
      );
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    return LoginResponseDto(
      accessToken: 'mock-access-$stamp',
      refreshToken: 'mock-refresh-$stamp',
      user: UserDto(
        id: 'U-1001',
        account: dto.account,
        name: dto.account == 'admin' ? '管理员' : dto.account,
        roles: const ['项目经理', '安全评价师'],
        orgName: '示例科技股份有限公司',
      ),
    );
  }

  @override
  Future<UserDto> fetchMe() async {
    await Future<void>.delayed(EnvConfig.mockLatency);
    return const UserDto(
      id: 'U-1001',
      account: 'admin',
      name: '管理员',
      roles: ['项目经理', '安全评价师'],
      orgName: '示例科技股份有限公司',
    );
  }

  @override
  Future<String?> refresh(String refreshToken) async {
    await Future<void>.delayed(EnvConfig.mockLatency);
    return 'mock-access-${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 登录页展示用。
  static String get hint => _demoPasswordHint;
}
