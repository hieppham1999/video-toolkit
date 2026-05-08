// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../settings_preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsPreset {

 String get id; String get name; bool get isBuiltIn; EncodeSettings get settings;
/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsPresetCopyWith<SettingsPreset> get copyWith => _$SettingsPresetCopyWithImpl<SettingsPreset>(this as SettingsPreset, _$identity);

  /// Serializes this SettingsPreset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isBuiltIn, isBuiltIn) || other.isBuiltIn == isBuiltIn)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isBuiltIn,settings);

@override
String toString() {
  return 'SettingsPreset(id: $id, name: $name, isBuiltIn: $isBuiltIn, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $SettingsPresetCopyWith<$Res>  {
  factory $SettingsPresetCopyWith(SettingsPreset value, $Res Function(SettingsPreset) _then) = _$SettingsPresetCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool isBuiltIn, EncodeSettings settings
});


$EncodeSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$SettingsPresetCopyWithImpl<$Res>
    implements $SettingsPresetCopyWith<$Res> {
  _$SettingsPresetCopyWithImpl(this._self, this._then);

  final SettingsPreset _self;
  final $Res Function(SettingsPreset) _then;

/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? isBuiltIn = null,Object? settings = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isBuiltIn: null == isBuiltIn ? _self.isBuiltIn : isBuiltIn // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,
  ));
}
/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res> get settings {
  
  return $EncodeSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsPreset].
extension SettingsPresetPatterns on SettingsPreset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsPreset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsPreset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsPreset value)  $default,){
final _that = this;
switch (_that) {
case _SettingsPreset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsPreset value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsPreset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool isBuiltIn,  EncodeSettings settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsPreset() when $default != null:
return $default(_that.id,_that.name,_that.isBuiltIn,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool isBuiltIn,  EncodeSettings settings)  $default,) {final _that = this;
switch (_that) {
case _SettingsPreset():
return $default(_that.id,_that.name,_that.isBuiltIn,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool isBuiltIn,  EncodeSettings settings)?  $default,) {final _that = this;
switch (_that) {
case _SettingsPreset() when $default != null:
return $default(_that.id,_that.name,_that.isBuiltIn,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SettingsPreset implements SettingsPreset {
  const _SettingsPreset({required this.id, required this.name, this.isBuiltIn = false, required this.settings});
  factory _SettingsPreset.fromJson(Map<String, dynamic> json) => _$SettingsPresetFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  bool isBuiltIn;
@override final  EncodeSettings settings;

/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsPresetCopyWith<_SettingsPreset> get copyWith => __$SettingsPresetCopyWithImpl<_SettingsPreset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsPresetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsPreset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isBuiltIn, isBuiltIn) || other.isBuiltIn == isBuiltIn)&&(identical(other.settings, settings) || other.settings == settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isBuiltIn,settings);

@override
String toString() {
  return 'SettingsPreset(id: $id, name: $name, isBuiltIn: $isBuiltIn, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$SettingsPresetCopyWith<$Res> implements $SettingsPresetCopyWith<$Res> {
  factory _$SettingsPresetCopyWith(_SettingsPreset value, $Res Function(_SettingsPreset) _then) = __$SettingsPresetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool isBuiltIn, EncodeSettings settings
});


@override $EncodeSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$SettingsPresetCopyWithImpl<$Res>
    implements _$SettingsPresetCopyWith<$Res> {
  __$SettingsPresetCopyWithImpl(this._self, this._then);

  final _SettingsPreset _self;
  final $Res Function(_SettingsPreset) _then;

/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? isBuiltIn = null,Object? settings = null,}) {
  return _then(_SettingsPreset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isBuiltIn: null == isBuiltIn ? _self.isBuiltIn : isBuiltIn // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,
  ));
}

/// Create a copy of SettingsPreset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res> get settings {
  
  return $EncodeSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
