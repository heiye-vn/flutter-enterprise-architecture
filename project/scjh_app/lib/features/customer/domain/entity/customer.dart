import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';

/// 客户实体。
@freezed
abstract class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    required String code,
    required String level,
    required String industry,
    required String contactName,
    required String contactPhone,
    required String regionName,
    required String ownerName,
    DateTime? lastFollowUpAt,
    @Default('') String remark,
  }) = _Customer;

  const Customer._();

  /// 客户等级文案。把"码值 → 文案"的映射放在实体上，
  /// 这样列表、详情、导出用的都是同一套口径。
  String get levelLabel => switch (level) {
    'A' => '战略客户',
    'B' => '重点客户',
    'C' => '普通客户',
    _ => level,
  };

  String get avatarInitial => name.isEmpty ? '?' : name.substring(0, 1);
}
