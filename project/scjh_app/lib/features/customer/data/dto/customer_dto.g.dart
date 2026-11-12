// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerDto _$CustomerDtoFromJson(Map<String, dynamic> json) => _CustomerDto(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  level: json['level'] as String? ?? 'C',
  industry: json['industry'] as String? ?? '',
  contactName: json['contactName'] as String? ?? '',
  contactPhone: json['contactPhone'] as String? ?? '',
  regionName: json['regionName'] as String? ?? '',
  ownerName: json['ownerName'] as String? ?? '',
  lastFollowUpAt: json['lastFollowUpAt'] as String?,
  remark: json['remark'] as String? ?? '',
);

Map<String, dynamic> _$CustomerDtoToJson(_CustomerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'level': instance.level,
      'industry': instance.industry,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'regionName': instance.regionName,
      'ownerName': instance.ownerName,
      'lastFollowUpAt': instance.lastFollowUpAt,
      'remark': instance.remark,
    };
