import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// 当前登录用户（领域实体）。
///
/// 实体只描述业务概念，**不带 fromJson**：
/// JSON 是外部世界的形状，属于 Data 层的 DTO。
/// 这条边界守住了，后端改字段时 Domain 和 UI 都不用动。
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String account,
    required String name,
    @Default(<String>[]) List<String> roles,
    String? avatarUrl,
    String? orgName,
  }) = _User;

  const User._();

  String get roleLabel => roles.isEmpty ? '普通用户' : roles.join(' / ');

  String get avatarInitial => name.isEmpty ? '?' : name.substring(0, 1);
}
