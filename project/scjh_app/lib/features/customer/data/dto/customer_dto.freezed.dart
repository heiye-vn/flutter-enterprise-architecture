// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerDto {

 String get id; String get name; String get code; String get level; String get industry; String get contactName; String get contactPhone; String get regionName; String get ownerName; String? get lastFollowUpAt; String get remark;
/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDtoCopyWith<CustomerDto> get copyWith => _$CustomerDtoCopyWithImpl<CustomerDto>(this as CustomerDto, _$identity);

  /// Serializes this CustomerDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CustomerDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.industry, _this.industry) || other.industry == _this.industry)&&(identical(other.contactName, _this.contactName) || other.contactName == _this.contactName)&&(identical(other.contactPhone, _this.contactPhone) || other.contactPhone == _this.contactPhone)&&(identical(other.regionName, _this.regionName) || other.regionName == _this.regionName)&&(identical(other.ownerName, _this.ownerName) || other.ownerName == _this.ownerName)&&(identical(other.lastFollowUpAt, _this.lastFollowUpAt) || other.lastFollowUpAt == _this.lastFollowUpAt)&&(identical(other.remark, _this.remark) || other.remark == _this.remark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CustomerDto;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.level,_this.industry,_this.contactName,_this.contactPhone,_this.regionName,_this.ownerName,_this.lastFollowUpAt,_this.remark);
}

@override
String toString() {
  final _this = this as CustomerDto;
  return 'CustomerDto(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, level: ${_this.level}, industry: ${_this.industry}, contactName: ${_this.contactName}, contactPhone: ${_this.contactPhone}, regionName: ${_this.regionName}, ownerName: ${_this.ownerName}, lastFollowUpAt: ${_this.lastFollowUpAt}, remark: ${_this.remark})';
}


}

/// @nodoc
abstract mixin class $CustomerDtoCopyWith<$Res>  {
  factory $CustomerDtoCopyWith(CustomerDto value, $Res Function(CustomerDto) _then) = _$CustomerDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code, String level, String industry, String contactName, String contactPhone, String regionName, String ownerName, String? lastFollowUpAt, String remark
});




}
/// @nodoc
class _$CustomerDtoCopyWithImpl<$Res>
    implements $CustomerDtoCopyWith<$Res> {
  _$CustomerDtoCopyWithImpl(this._self, this._then);

  final CustomerDto _self;
  final $Res Function(CustomerDto) _then;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? level = null,Object? industry = null,Object? contactName = null,Object? contactPhone = null,Object? regionName = null,Object? ownerName = null,Object? lastFollowUpAt = freezed,Object? remark = null,}) {
  return _then(CustomerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as String,contactName: null == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,lastFollowUpAt: freezed == lastFollowUpAt ? _self.lastFollowUpAt : lastFollowUpAt // ignore: cast_nullable_to_non_nullable
as String?,remark: null == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerDto].
extension CustomerDtoPatterns on CustomerDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDto value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDto value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String level,  String industry,  String contactName,  String contactPhone,  String regionName,  String ownerName,  String? lastFollowUpAt,  String remark)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.level,_that.industry,_that.contactName,_that.contactPhone,_that.regionName,_that.ownerName,_that.lastFollowUpAt,_that.remark);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String level,  String industry,  String contactName,  String contactPhone,  String regionName,  String ownerName,  String? lastFollowUpAt,  String remark)  $default,) {final _that = this;
switch (_that) {
case _CustomerDto():
return $default(_that.id,_that.name,_that.code,_that.level,_that.industry,_that.contactName,_that.contactPhone,_that.regionName,_that.ownerName,_that.lastFollowUpAt,_that.remark);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code,  String level,  String industry,  String contactName,  String contactPhone,  String regionName,  String ownerName,  String? lastFollowUpAt,  String remark)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDto() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.level,_that.industry,_that.contactName,_that.contactPhone,_that.regionName,_that.ownerName,_that.lastFollowUpAt,_that.remark);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerDto implements CustomerDto {
  const _CustomerDto({required this.id, required this.name, required this.code, this.level = 'C', this.industry = '', this.contactName = '', this.contactPhone = '', this.regionName = '', this.ownerName = '', this.lastFollowUpAt, this.remark = ''});
  factory _CustomerDto.fromJson(Map<String, dynamic> json) => _$CustomerDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String code;
@override@JsonKey() final  String level;
@override@JsonKey() final  String industry;
@override@JsonKey() final  String contactName;
@override@JsonKey() final  String contactPhone;
@override@JsonKey() final  String regionName;
@override@JsonKey() final  String ownerName;
@override final  String? lastFollowUpAt;
@override@JsonKey() final  String remark;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDtoCopyWith<_CustomerDto> get copyWith => __$CustomerDtoCopyWithImpl<_CustomerDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.level, level) || other.level == level)&&(identical(other.industry, industry) || other.industry == industry)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.regionName, regionName) || other.regionName == regionName)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.lastFollowUpAt, lastFollowUpAt) || other.lastFollowUpAt == lastFollowUpAt)&&(identical(other.remark, remark) || other.remark == remark));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,level,industry,contactName,contactPhone,regionName,ownerName,lastFollowUpAt,remark);
}

@override
String toString() {
    return 'CustomerDto(id: $id, name: $name, code: $code, level: $level, industry: $industry, contactName: $contactName, contactPhone: $contactPhone, regionName: $regionName, ownerName: $ownerName, lastFollowUpAt: $lastFollowUpAt, remark: $remark)';
}


}

/// @nodoc
abstract mixin class _$CustomerDtoCopyWith<$Res> implements $CustomerDtoCopyWith<$Res> {
  factory _$CustomerDtoCopyWith(_CustomerDto value, $Res Function(_CustomerDto) _then) = __$CustomerDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code, String level, String industry, String contactName, String contactPhone, String regionName, String ownerName, String? lastFollowUpAt, String remark
});




}
/// @nodoc
class __$CustomerDtoCopyWithImpl<$Res>
    implements _$CustomerDtoCopyWith<$Res> {
  __$CustomerDtoCopyWithImpl(this._self, this._then);

  final _CustomerDto _self;
  final $Res Function(_CustomerDto) _then;

/// Create a copy of CustomerDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? level = null,Object? industry = null,Object? contactName = null,Object? contactPhone = null,Object? regionName = null,Object? ownerName = null,Object? lastFollowUpAt = freezed,Object? remark = null,}) {
  return _then(_CustomerDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,industry: null == industry ? _self.industry : industry // ignore: cast_nullable_to_non_nullable
as String,contactName: null == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String,contactPhone: null == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String,regionName: null == regionName ? _self.regionName : regionName // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,lastFollowUpAt: freezed == lastFollowUpAt ? _self.lastFollowUpAt : lastFollowUpAt // ignore: cast_nullable_to_non_nullable
as String?,remark: null == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
