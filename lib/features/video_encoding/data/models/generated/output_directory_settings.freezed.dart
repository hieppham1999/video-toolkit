// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../output_directory_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OutputDirectorySettings {

 OutputDirectoryMode get mode; bool get subfolderEnabled; String get subfolderName; String? get customPath;
/// Create a copy of OutputDirectorySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<OutputDirectorySettings> get copyWith => _$OutputDirectorySettingsCopyWithImpl<OutputDirectorySettings>(this as OutputDirectorySettings, _$identity);

  /// Serializes this OutputDirectorySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutputDirectorySettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.subfolderEnabled, subfolderEnabled) || other.subfolderEnabled == subfolderEnabled)&&(identical(other.subfolderName, subfolderName) || other.subfolderName == subfolderName)&&(identical(other.customPath, customPath) || other.customPath == customPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,subfolderEnabled,subfolderName,customPath);

@override
String toString() {
  return 'OutputDirectorySettings(mode: $mode, subfolderEnabled: $subfolderEnabled, subfolderName: $subfolderName, customPath: $customPath)';
}


}

/// @nodoc
abstract mixin class $OutputDirectorySettingsCopyWith<$Res>  {
  factory $OutputDirectorySettingsCopyWith(OutputDirectorySettings value, $Res Function(OutputDirectorySettings) _then) = _$OutputDirectorySettingsCopyWithImpl;
@useResult
$Res call({
 OutputDirectoryMode mode, bool subfolderEnabled, String subfolderName, String? customPath
});




}
/// @nodoc
class _$OutputDirectorySettingsCopyWithImpl<$Res>
    implements $OutputDirectorySettingsCopyWith<$Res> {
  _$OutputDirectorySettingsCopyWithImpl(this._self, this._then);

  final OutputDirectorySettings _self;
  final $Res Function(OutputDirectorySettings) _then;

/// Create a copy of OutputDirectorySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? subfolderEnabled = null,Object? subfolderName = null,Object? customPath = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OutputDirectoryMode,subfolderEnabled: null == subfolderEnabled ? _self.subfolderEnabled : subfolderEnabled // ignore: cast_nullable_to_non_nullable
as bool,subfolderName: null == subfolderName ? _self.subfolderName : subfolderName // ignore: cast_nullable_to_non_nullable
as String,customPath: freezed == customPath ? _self.customPath : customPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OutputDirectorySettings].
extension OutputDirectorySettingsPatterns on OutputDirectorySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutputDirectorySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutputDirectorySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutputDirectorySettings value)  $default,){
final _that = this;
switch (_that) {
case _OutputDirectorySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutputDirectorySettings value)?  $default,){
final _that = this;
switch (_that) {
case _OutputDirectorySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OutputDirectoryMode mode,  bool subfolderEnabled,  String subfolderName,  String? customPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutputDirectorySettings() when $default != null:
return $default(_that.mode,_that.subfolderEnabled,_that.subfolderName,_that.customPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OutputDirectoryMode mode,  bool subfolderEnabled,  String subfolderName,  String? customPath)  $default,) {final _that = this;
switch (_that) {
case _OutputDirectorySettings():
return $default(_that.mode,_that.subfolderEnabled,_that.subfolderName,_that.customPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OutputDirectoryMode mode,  bool subfolderEnabled,  String subfolderName,  String? customPath)?  $default,) {final _that = this;
switch (_that) {
case _OutputDirectorySettings() when $default != null:
return $default(_that.mode,_that.subfolderEnabled,_that.subfolderName,_that.customPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutputDirectorySettings implements OutputDirectorySettings {
  const _OutputDirectorySettings({this.mode = OutputDirectoryMode.sameAsSource, this.subfolderEnabled = false, this.subfolderName = '', this.customPath});
  factory _OutputDirectorySettings.fromJson(Map<String, dynamic> json) => _$OutputDirectorySettingsFromJson(json);

@override@JsonKey() final  OutputDirectoryMode mode;
@override@JsonKey() final  bool subfolderEnabled;
@override@JsonKey() final  String subfolderName;
@override final  String? customPath;

/// Create a copy of OutputDirectorySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutputDirectorySettingsCopyWith<_OutputDirectorySettings> get copyWith => __$OutputDirectorySettingsCopyWithImpl<_OutputDirectorySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutputDirectorySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutputDirectorySettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.subfolderEnabled, subfolderEnabled) || other.subfolderEnabled == subfolderEnabled)&&(identical(other.subfolderName, subfolderName) || other.subfolderName == subfolderName)&&(identical(other.customPath, customPath) || other.customPath == customPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,subfolderEnabled,subfolderName,customPath);

@override
String toString() {
  return 'OutputDirectorySettings(mode: $mode, subfolderEnabled: $subfolderEnabled, subfolderName: $subfolderName, customPath: $customPath)';
}


}

/// @nodoc
abstract mixin class _$OutputDirectorySettingsCopyWith<$Res> implements $OutputDirectorySettingsCopyWith<$Res> {
  factory _$OutputDirectorySettingsCopyWith(_OutputDirectorySettings value, $Res Function(_OutputDirectorySettings) _then) = __$OutputDirectorySettingsCopyWithImpl;
@override @useResult
$Res call({
 OutputDirectoryMode mode, bool subfolderEnabled, String subfolderName, String? customPath
});




}
/// @nodoc
class __$OutputDirectorySettingsCopyWithImpl<$Res>
    implements _$OutputDirectorySettingsCopyWith<$Res> {
  __$OutputDirectorySettingsCopyWithImpl(this._self, this._then);

  final _OutputDirectorySettings _self;
  final $Res Function(_OutputDirectorySettings) _then;

/// Create a copy of OutputDirectorySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? subfolderEnabled = null,Object? subfolderName = null,Object? customPath = freezed,}) {
  return _then(_OutputDirectorySettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as OutputDirectoryMode,subfolderEnabled: null == subfolderEnabled ? _self.subfolderEnabled : subfolderEnabled // ignore: cast_nullable_to_non_nullable
as bool,subfolderName: null == subfolderName ? _self.subfolderName : subfolderName // ignore: cast_nullable_to_non_nullable
as String,customPath: freezed == customPath ? _self.customPath : customPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
