// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponseDto _$LoginResponseDtoFromJson(Map<String, dynamic> json) =>
    _LoginResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseDtoToJson(_LoginResponseDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  account: json['account'] as String,
  name: json['name'] as String,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  avatarUrl: json['avatarUrl'] as String?,
  orgName: json['orgName'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'account': instance.account,
  'name': instance.name,
  'roles': instance.roles,
  'avatarUrl': instance.avatarUrl,
  'orgName': instance.orgName,
};
