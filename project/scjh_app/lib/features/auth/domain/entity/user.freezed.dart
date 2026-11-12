// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$User {

 String get id; String get account; String get name; List<String> get roles; String? get avatarUrl; String? get orgName;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.orgName, _this.orgName) || other.orgName == _this.orgName));
}


@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.account,_this.name,const DeepCollectionEquality().hash(_this.roles),_this.avatarUrl,_this.orgName);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, account: ${_this.account}, name: ${_this.name}, roles: ${_this.roles}, avatarUrl: ${_this.avatarUrl}, orgName: ${_this.orgName})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String account, String name, List<String> roles, String? avatarUrl, String? orgName
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? account = null,Object? name = null,Object? roles = null,Object? avatarUrl = freezed,Object? orgName = freezed,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String account,  String name,  List<String> roles,  String? avatarUrl,  String? orgName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.account,_that.name,_that.roles,_that.avatarUrl,_that.orgName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String account,  String name,  List<String> roles,  String? avatarUrl,  String? orgName)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.account,_that.name,_that.roles,_that.avatarUrl,_that.orgName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String account,  String name,  List<String> roles,  String? avatarUrl,  String? orgName)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.account,_that.name,_that.roles,_that.avatarUrl,_that.orgName);case _:
  return null;

}
}

}

/// @nodoc


class _User extends User {
  const _User({required this.id, required this.account, required this.name,  List<String> roles = const <String>[], this.avatarUrl, this.orgName}): _roles = roles,super._();
  

@override final  String id;
@override final  String account;
@override final  String name;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  String? avatarUrl;
@override final  String? orgName;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.account, account) || other.account == account)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.roles, _roles)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.orgName, orgName) || other.orgName == orgName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,account,name,const DeepCollectionEquality().hash(_roles),avatarUrl,orgName);
}

@override
String toString() {
    return 'User(id: $id, account: $account, name: $name, roles: $roles, avatarUrl: $avatarUrl, orgName: $orgName)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String account, String name, List<String> roles, String? avatarUrl, String? orgName
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? account = null,Object? name = null,Object? roles = null,Object? avatarUrl = freezed,Object? orgName = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,orgName: freezed == orgName ? _self.orgName : orgName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
