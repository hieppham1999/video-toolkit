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

 String? get selectedPresetId; EncodeSettings get encodeSettings;/// User-chosen default font path. Used when an overlay has no explicit
/// `fontFile`. When null or the file no longer exists, the bundled VCR
/// font is used as the final fallback. Configured from the app settings
/// page.
 String? get defaultFontPath; AppAccent get accentColor; AppLanguage get language; AppThemeMode get themeMode; OutputDirectorySettings get outputDirectory;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.selectedPresetId, selectedPresetId) || other.selectedPresetId == selectedPresetId)&&(identical(other.encodeSettings, encodeSettings) || other.encodeSettings == encodeSettings)&&(identical(other.defaultFontPath, defaultFontPath) || other.defaultFontPath == defaultFontPath)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.language, language) || other.language == language)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedPresetId,encodeSettings,defaultFontPath,accentColor,language,themeMode,outputDirectory);

@override
String toString() {
  return 'UserSettings(selectedPresetId: $selectedPresetId, encodeSettings: $encodeSettings, defaultFontPath: $defaultFontPath, accentColor: $accentColor, language: $language, themeMode: $themeMode, outputDirectory: $outputDirectory)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String? selectedPresetId, EncodeSettings encodeSettings, String? defaultFontPath, AppAccent accentColor, AppLanguage language, AppThemeMode themeMode, OutputDirectorySettings outputDirectory
});


$EncodeSettingsCopyWith<$Res> get encodeSettings;$OutputDirectorySettingsCopyWith<$Res> get outputDirectory;

}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedPresetId = freezed,Object? encodeSettings = null,Object? defaultFontPath = freezed,Object? accentColor = null,Object? language = null,Object? themeMode = null,Object? outputDirectory = null,}) {
  return _then(_self.copyWith(
selectedPresetId: freezed == selectedPresetId ? _self.selectedPresetId : selectedPresetId // ignore: cast_nullable_to_non_nullable
as String?,encodeSettings: null == encodeSettings ? _self.encodeSettings : encodeSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,defaultFontPath: freezed == defaultFontPath ? _self.defaultFontPath : defaultFontPath // ignore: cast_nullable_to_non_nullable
as String?,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as AppAccent,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings,
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
}/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<$Res> get outputDirectory {
  
  return $OutputDirectorySettingsCopyWith<$Res>(_self.outputDirectory, (value) {
    return _then(_self.copyWith(outputDirectory: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedPresetId,  EncodeSettings encodeSettings,  String? defaultFontPath,  AppAccent accentColor,  AppLanguage language,  AppThemeMode themeMode,  OutputDirectorySettings outputDirectory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.selectedPresetId,_that.encodeSettings,_that.defaultFontPath,_that.accentColor,_that.language,_that.themeMode,_that.outputDirectory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedPresetId,  EncodeSettings encodeSettings,  String? defaultFontPath,  AppAccent accentColor,  AppLanguage language,  AppThemeMode themeMode,  OutputDirectorySettings outputDirectory)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.selectedPresetId,_that.encodeSettings,_that.defaultFontPath,_that.accentColor,_that.language,_that.themeMode,_that.outputDirectory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedPresetId,  EncodeSettings encodeSettings,  String? defaultFontPath,  AppAccent accentColor,  AppLanguage language,  AppThemeMode themeMode,  OutputDirectorySettings outputDirectory)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.selectedPresetId,_that.encodeSettings,_that.defaultFontPath,_that.accentColor,_that.language,_that.themeMode,_that.outputDirectory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings implements UserSettings {
  const _UserSettings({this.selectedPresetId, required this.encodeSettings, this.defaultFontPath, this.accentColor = AppAccent.blue, this.language = AppLanguage.system, this.themeMode = AppThemeMode.system, this.outputDirectory = const OutputDirectorySettings()});
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

@override final  String? selectedPresetId;
@override final  EncodeSettings encodeSettings;
/// User-chosen default font path. Used when an overlay has no explicit
/// `fontFile`. When null or the file no longer exists, the bundled VCR
/// font is used as the final fallback. Configured from the app settings
/// page.
@override final  String? defaultFontPath;
@override@JsonKey() final  AppAccent accentColor;
@override@JsonKey() final  AppLanguage language;
@override@JsonKey() final  AppThemeMode themeMode;
@override@JsonKey() final  OutputDirectorySettings outputDirectory;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.selectedPresetId, selectedPresetId) || other.selectedPresetId == selectedPresetId)&&(identical(other.encodeSettings, encodeSettings) || other.encodeSettings == encodeSettings)&&(identical(other.defaultFontPath, defaultFontPath) || other.defaultFontPath == defaultFontPath)&&(identical(other.accentColor, accentColor) || other.accentColor == accentColor)&&(identical(other.language, language) || other.language == language)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,selectedPresetId,encodeSettings,defaultFontPath,accentColor,language,themeMode,outputDirectory);

@override
String toString() {
  return 'UserSettings(selectedPresetId: $selectedPresetId, encodeSettings: $encodeSettings, defaultFontPath: $defaultFontPath, accentColor: $accentColor, language: $language, themeMode: $themeMode, outputDirectory: $outputDirectory)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String? selectedPresetId, EncodeSettings encodeSettings, String? defaultFontPath, AppAccent accentColor, AppLanguage language, AppThemeMode themeMode, OutputDirectorySettings outputDirectory
});


@override $EncodeSettingsCopyWith<$Res> get encodeSettings;@override $OutputDirectorySettingsCopyWith<$Res> get outputDirectory;

}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedPresetId = freezed,Object? encodeSettings = null,Object? defaultFontPath = freezed,Object? accentColor = null,Object? language = null,Object? themeMode = null,Object? outputDirectory = null,}) {
  return _then(_UserSettings(
selectedPresetId: freezed == selectedPresetId ? _self.selectedPresetId : selectedPresetId // ignore: cast_nullable_to_non_nullable
as String?,encodeSettings: null == encodeSettings ? _self.encodeSettings : encodeSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings,defaultFontPath: freezed == defaultFontPath ? _self.defaultFontPath : defaultFontPath // ignore: cast_nullable_to_non_nullable
as String?,accentColor: null == accentColor ? _self.accentColor : accentColor // ignore: cast_nullable_to_non_nullable
as AppAccent,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings,
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
}/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<$Res> get outputDirectory {
  
  return $OutputDirectorySettingsCopyWith<$Res>(_self.outputDirectory, (value) {
    return _then(_self.copyWith(outputDirectory: value));
  });
}
}

// dart format on
