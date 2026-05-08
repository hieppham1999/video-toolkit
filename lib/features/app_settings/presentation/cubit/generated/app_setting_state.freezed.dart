// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../app_setting_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettingState {

 AppAccent get accent; AppLanguage get language; AppThemeMode get themeMode; String? get defaultFontPath; OutputDirectorySettings get outputDirectory;
/// Create a copy of AppSettingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingStateCopyWith<AppSettingState> get copyWith => _$AppSettingStateCopyWithImpl<AppSettingState>(this as AppSettingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettingState&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.language, language) || other.language == language)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.defaultFontPath, defaultFontPath) || other.defaultFontPath == defaultFontPath)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory));
}


@override
int get hashCode => Object.hash(runtimeType,accent,language,themeMode,defaultFontPath,outputDirectory);

@override
String toString() {
  return 'AppSettingState(accent: $accent, language: $language, themeMode: $themeMode, defaultFontPath: $defaultFontPath, outputDirectory: $outputDirectory)';
}


}

/// @nodoc
abstract mixin class $AppSettingStateCopyWith<$Res>  {
  factory $AppSettingStateCopyWith(AppSettingState value, $Res Function(AppSettingState) _then) = _$AppSettingStateCopyWithImpl;
@useResult
$Res call({
 AppAccent accent, AppLanguage language, AppThemeMode themeMode, String? defaultFontPath, OutputDirectorySettings outputDirectory
});


$OutputDirectorySettingsCopyWith<$Res> get outputDirectory;

}
/// @nodoc
class _$AppSettingStateCopyWithImpl<$Res>
    implements $AppSettingStateCopyWith<$Res> {
  _$AppSettingStateCopyWithImpl(this._self, this._then);

  final AppSettingState _self;
  final $Res Function(AppSettingState) _then;

/// Create a copy of AppSettingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accent = null,Object? language = null,Object? themeMode = null,Object? defaultFontPath = freezed,Object? outputDirectory = null,}) {
  return _then(_self.copyWith(
accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as AppAccent,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,defaultFontPath: freezed == defaultFontPath ? _self.defaultFontPath : defaultFontPath // ignore: cast_nullable_to_non_nullable
as String?,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings,
  ));
}
/// Create a copy of AppSettingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<$Res> get outputDirectory {
  
  return $OutputDirectorySettingsCopyWith<$Res>(_self.outputDirectory, (value) {
    return _then(_self.copyWith(outputDirectory: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSettingState].
extension AppSettingStatePatterns on AppSettingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettingState value)  $default,){
final _that = this;
switch (_that) {
case _AppSettingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettingState value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppAccent accent,  AppLanguage language,  AppThemeMode themeMode,  String? defaultFontPath,  OutputDirectorySettings outputDirectory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettingState() when $default != null:
return $default(_that.accent,_that.language,_that.themeMode,_that.defaultFontPath,_that.outputDirectory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppAccent accent,  AppLanguage language,  AppThemeMode themeMode,  String? defaultFontPath,  OutputDirectorySettings outputDirectory)  $default,) {final _that = this;
switch (_that) {
case _AppSettingState():
return $default(_that.accent,_that.language,_that.themeMode,_that.defaultFontPath,_that.outputDirectory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppAccent accent,  AppLanguage language,  AppThemeMode themeMode,  String? defaultFontPath,  OutputDirectorySettings outputDirectory)?  $default,) {final _that = this;
switch (_that) {
case _AppSettingState() when $default != null:
return $default(_that.accent,_that.language,_that.themeMode,_that.defaultFontPath,_that.outputDirectory);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettingState implements AppSettingState {
  const _AppSettingState({this.accent = AppAccent.blue, this.language = AppLanguage.system, this.themeMode = AppThemeMode.system, this.defaultFontPath, this.outputDirectory = const OutputDirectorySettings()});
  

@override@JsonKey() final  AppAccent accent;
@override@JsonKey() final  AppLanguage language;
@override@JsonKey() final  AppThemeMode themeMode;
@override final  String? defaultFontPath;
@override@JsonKey() final  OutputDirectorySettings outputDirectory;

/// Create a copy of AppSettingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingStateCopyWith<_AppSettingState> get copyWith => __$AppSettingStateCopyWithImpl<_AppSettingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettingState&&(identical(other.accent, accent) || other.accent == accent)&&(identical(other.language, language) || other.language == language)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.defaultFontPath, defaultFontPath) || other.defaultFontPath == defaultFontPath)&&(identical(other.outputDirectory, outputDirectory) || other.outputDirectory == outputDirectory));
}


@override
int get hashCode => Object.hash(runtimeType,accent,language,themeMode,defaultFontPath,outputDirectory);

@override
String toString() {
  return 'AppSettingState(accent: $accent, language: $language, themeMode: $themeMode, defaultFontPath: $defaultFontPath, outputDirectory: $outputDirectory)';
}


}

/// @nodoc
abstract mixin class _$AppSettingStateCopyWith<$Res> implements $AppSettingStateCopyWith<$Res> {
  factory _$AppSettingStateCopyWith(_AppSettingState value, $Res Function(_AppSettingState) _then) = __$AppSettingStateCopyWithImpl;
@override @useResult
$Res call({
 AppAccent accent, AppLanguage language, AppThemeMode themeMode, String? defaultFontPath, OutputDirectorySettings outputDirectory
});


@override $OutputDirectorySettingsCopyWith<$Res> get outputDirectory;

}
/// @nodoc
class __$AppSettingStateCopyWithImpl<$Res>
    implements _$AppSettingStateCopyWith<$Res> {
  __$AppSettingStateCopyWithImpl(this._self, this._then);

  final _AppSettingState _self;
  final $Res Function(_AppSettingState) _then;

/// Create a copy of AppSettingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accent = null,Object? language = null,Object? themeMode = null,Object? defaultFontPath = freezed,Object? outputDirectory = null,}) {
  return _then(_AppSettingState(
accent: null == accent ? _self.accent : accent // ignore: cast_nullable_to_non_nullable
as AppAccent,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as AppLanguage,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as AppThemeMode,defaultFontPath: freezed == defaultFontPath ? _self.defaultFontPath : defaultFontPath // ignore: cast_nullable_to_non_nullable
as String?,outputDirectory: null == outputDirectory ? _self.outputDirectory : outputDirectory // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings,
  ));
}

/// Create a copy of AppSettingState
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
