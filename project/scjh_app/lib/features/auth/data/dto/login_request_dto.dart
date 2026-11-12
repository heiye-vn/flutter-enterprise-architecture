import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_dto.freezed.dart';
part 'login_request_dto.g.dart';

/// 登录请求体。
///
/// DTO 只负责"接口长什么样"，加字段、改命名都止步于这一层。
@freezed
abstract class LoginRequestDto with _$LoginRequestDto {
  const factory LoginRequestDto({
    required String account,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestDtoFromJson(json);
}
