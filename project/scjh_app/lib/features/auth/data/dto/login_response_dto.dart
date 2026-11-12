import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/user.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

/// 登录响应。
@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String accessToken,
    String? refreshToken,
    required UserDto user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);
}

/// 用户信息 DTO。
///
/// 与实体分开的意义：接口里的 `user_name`、`org` 这类历史命名
/// 全部收敛在这里，Domain 层保持干净。
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String account,
    required String name,
    @Default(<String>[]) List<String> roles,
    String? avatarUrl,
    String? orgName,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

/// Data → Domain 的转换收口在这一处。
extension UserDtoMapper on UserDto {
  User toEntity() => User(
    id: id,
    account: account,
    name: name,
    roles: roles,
    avatarUrl: avatarUrl,
    orgName: orgName,
  );
}
