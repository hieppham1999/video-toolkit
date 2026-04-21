// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettings {

 String? get selectedPresetId; EncodeSettings get encodeSettings;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.selectedPresetId, selectedPresetId) || other.selectedPresetId == selectedPresetId)&&(identical(other.encodeSettings, encodeSettings) || other.encodeSettings == encodeSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedPresetId,encodeSettings);

@override
String toString() {
  return 'UserSettings(selectedPresetId: $selectedPresetId, encodeSettings: $encodeSettings)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String? selectedPresetId, EncodeSettings encodeSettings
});


$EncodeSettingsCopyWith<$Res> get encodeSettings;

}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedPresetId = freezed,Object? encodeSettings = null,}) {
  return _then(_self.copyWith(
selectedPresetId: freezed == selectedPresetId ? _self.selectedPresetId : selectedPresetId // ignore: cast_nullable_to_non_nullable
as String?,encodeSettings: null == encodeSettings ? _self.encodeSettings : encodeSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,
  ));
}
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res> get encodeSettings {
  
  return $EncodeSettingsCopyWith<$Res>(_self.encodeSettings, (value) {
    return _then(_self.copyWith(encodeSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedPresetId,  EncodeSettings encodeSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.selectedPresetId,_that.encodeSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedPresetId,  EncodeSettings encodeSettings)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.selectedPresetId,_that.encodeSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedPresetId,  EncodeSettings encodeSettings)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.selectedPresetId,_that.encodeSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({this.selectedPresetId, required this.encodeSettings});
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String? selectedPresetId;
@override final  EncodeSettings encodeSettings;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.selectedPresetId, selectedPresetId) || other.selectedPresetId == selectedPresetId)&&(identical(other.encodeSettings, encodeSettings) || other.encodeSettings == encodeSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedPresetId,encodeSettings);

@override
String toString() {
  return 'UserSettings(selectedPresetId: $selectedPresetId, encodeSettings: $encodeSettings)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? selectedPresetId, EncodeSettings encodeSettings
});


@override $EncodeSettingsCopyWith<$Res> get encodeSettings;

}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedPresetId = freezed,Object? encodeSettings = null,}) {
  return _then(_UserSettings(
selectedPresetId: freezed == selectedPresetId ? _self.selectedPresetId : selectedPresetId // ignore: cast_nullable_to_non_nullable
as String?,encodeSettings: null == encodeSettings ? _self.encodeSettings : encodeSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,
  ));
}

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res> get encodeSettings {
  
  return $EncodeSettingsCopyWith<$Res>(_self.encodeSettings, (value) {
    return _then(_self.copyWith(encodeSettings: value));
  });
}
}

// dart format on
