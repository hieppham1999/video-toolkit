// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../encode_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncodeSettings {

 bool get burnTimestamp;
/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<EncodeSettings> get copyWith => _$EncodeSettingsCopyWithImpl<EncodeSettings>(this as EncodeSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncodeSettings&&(identical(other.burnTimestamp, burnTimestamp) || other.burnTimestamp == burnTimestamp));
}


@override
int get hashCode => Object.hash(runtimeType,burnTimestamp);

@override
String toString() {
  return 'EncodeSettings(burnTimestamp: $burnTimestamp)';
}


}

/// @nodoc
abstract mixin class $EncodeSettingsCopyWith<$Res>  {
  factory $EncodeSettingsCopyWith(EncodeSettings value, $Res Function(EncodeSettings) _then) = _$EncodeSettingsCopyWithImpl;
@useResult
$Res call({
 bool burnTimestamp
});




}
/// @nodoc
class _$EncodeSettingsCopyWithImpl<$Res>
    implements $EncodeSettingsCopyWith<$Res> {
  _$EncodeSettingsCopyWithImpl(this._self, this._then);

  final EncodeSettings _self;
  final $Res Function(EncodeSettings) _then;

/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? burnTimestamp = null,}) {
  return _then(_self.copyWith(
burnTimestamp: null == burnTimestamp ? _self.burnTimestamp : burnTimestamp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EncodeSettings].
extension EncodeSettingsPatterns on EncodeSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncodeSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncodeSettings value)  $default,){
final _that = this;
switch (_that) {
case _EncodeSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncodeSettings value)?  $default,){
final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool burnTimestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
return $default(_that.burnTimestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool burnTimestamp)  $default,) {final _that = this;
switch (_that) {
case _EncodeSettings():
return $default(_that.burnTimestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool burnTimestamp)?  $default,) {final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
return $default(_that.burnTimestamp);case _:
  return null;

}
}

}

/// @nodoc


class _EncodeSettings implements EncodeSettings {
  const _EncodeSettings({this.burnTimestamp = false});
  

@override@JsonKey() final  bool burnTimestamp;

/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncodeSettingsCopyWith<_EncodeSettings> get copyWith => __$EncodeSettingsCopyWithImpl<_EncodeSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncodeSettings&&(identical(other.burnTimestamp, burnTimestamp) || other.burnTimestamp == burnTimestamp));
}


@override
int get hashCode => Object.hash(runtimeType,burnTimestamp);

@override
String toString() {
  return 'EncodeSettings(burnTimestamp: $burnTimestamp)';
}


}

/// @nodoc
abstract mixin class _$EncodeSettingsCopyWith<$Res> implements $EncodeSettingsCopyWith<$Res> {
  factory _$EncodeSettingsCopyWith(_EncodeSettings value, $Res Function(_EncodeSettings) _then) = __$EncodeSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool burnTimestamp
});




}
/// @nodoc
class __$EncodeSettingsCopyWithImpl<$Res>
    implements _$EncodeSettingsCopyWith<$Res> {
  __$EncodeSettingsCopyWithImpl(this._self, this._then);

  final _EncodeSettings _self;
  final $Res Function(_EncodeSettings) _then;

/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? burnTimestamp = null,}) {
  return _then(_EncodeSettings(
burnTimestamp: null == burnTimestamp ? _self.burnTimestamp : burnTimestamp // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
