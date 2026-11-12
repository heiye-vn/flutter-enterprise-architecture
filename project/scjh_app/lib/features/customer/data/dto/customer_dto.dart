import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/customer.dart';

part 'customer_dto.freezed.dart';
part 'customer_dto.g.dart';

/// 客户接口模型。
///
/// 字段全部可空/有默认值：后端少返一个字段不应该让整个列表崩掉。
@freezed
abstract class CustomerDto with _$CustomerDto {
  const factory CustomerDto({
    required String id,
    required String name,
    required String code,
    @Default('C') String level,
    @Default('') String industry,
    @Default('') String contactName,
    @Default('') String contactPhone,
    @Default('') String regionName,
    @Default('') String ownerName,
    String? lastFollowUpAt,
    @Default('') String remark,
  }) = _CustomerDto;

  factory CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerDtoFromJson(json);
}

extension CustomerDtoMapper on CustomerDto {
  Customer toEntity() => Customer(
    id: id,
    name: name,
    code: code,
    level: level,
    industry: industry,
    contactName: contactName,
    contactPhone: contactPhone,
    regionName: regionName,
    ownerName: ownerName,
    lastFollowUpAt: lastFollowUpAt == null
        ? null
        : DateTime.tryParse(lastFollowUpAt!),
    remark: remark,
  );
}
