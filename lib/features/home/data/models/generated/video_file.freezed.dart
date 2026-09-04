// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoFile {

 String get path; String get name; int get sizeInBytes; DateTime get importedAt; VideoMetadata? get metadata;/// Per-file encode settings override. Null = use global settings.
 EncodeSettings? get overrideSettings;/// Preset id last selected in the per-file settings dialog.
/// Null = file follows the globally selected preset.
 String? get appliedPresetId;/// Per-file output directory override. Null = use the global output
/// directory setting.
 OutputDirectorySettings? get outputDirectoryOverride;
/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoFileCopyWith<VideoFile> get copyWith => _$VideoFileCopyWithImpl<VideoFile>(this as VideoFile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoFile&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeInBytes, sizeInBytes) || other.sizeInBytes == sizeInBytes)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.overrideSettings, overrideSettings) || other.overrideSettings == overrideSettings)&&(identical(other.appliedPresetId, appliedPresetId) || other.appliedPresetId == appliedPresetId)&&(identical(other.outputDirectoryOverride, outputDirectoryOverride) || other.outputDirectoryOverride == outputDirectoryOverride));
}


@override
int get hashCode => Object.hash(runtimeType,path,name,sizeInBytes,importedAt,metadata,overrideSettings,appliedPresetId,outputDirectoryOverride);

@override
String toString() {
  return 'VideoFile(path: $path, name: $name, sizeInBytes: $sizeInBytes, importedAt: $importedAt, metadata: $metadata, overrideSettings: $overrideSettings, appliedPresetId: $appliedPresetId, outputDirectoryOverride: $outputDirectoryOverride)';
}


}

/// @nodoc
abstract mixin class $VideoFileCopyWith<$Res>  {
  factory $VideoFileCopyWith(VideoFile value, $Res Function(VideoFile) _then) = _$VideoFileCopyWithImpl;
@useResult
$Res call({
 String path, String name, int sizeInBytes, DateTime importedAt, VideoMetadata? metadata, EncodeSettings? overrideSettings, String? appliedPresetId, OutputDirectorySettings? outputDirectoryOverride
});


$VideoMetadataCopyWith<$Res>? get metadata;$EncodeSettingsCopyWith<$Res>? get overrideSettings;$OutputDirectorySettingsCopyWith<$Res>? get outputDirectoryOverride;

}
/// @nodoc
class _$VideoFileCopyWithImpl<$Res>
    implements $VideoFileCopyWith<$Res> {
  _$VideoFileCopyWithImpl(this._self, this._then);

  final VideoFile _self;
  final $Res Function(VideoFile) _then;

/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? name = null,Object? sizeInBytes = null,Object? importedAt = null,Object? metadata = freezed,Object? overrideSettings = freezed,Object? appliedPresetId = freezed,Object? outputDirectoryOverride = freezed,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeInBytes: null == sizeInBytes ? _self.sizeInBytes : sizeInBytes // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as VideoMetadata?,overrideSettings: freezed == overrideSettings ? _self.overrideSettings : overrideSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings?,appliedPresetId: freezed == appliedPresetId ? _self.appliedPresetId : appliedPresetId // ignore: cast_nullable_to_non_nullable
as String?,outputDirectoryOverride: freezed == outputDirectoryOverride ? _self.outputDirectoryOverride : outputDirectoryOverride // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings?,
  ));
}
/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $VideoMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res>? get overrideSettings {
    if (_self.overrideSettings == null) {
    return null;
  }

  return $EncodeSettingsCopyWith<$Res>(_self.overrideSettings!, (value) {
    return _then(_self.copyWith(overrideSettings: value));
  });
}/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<$Res>? get outputDirectoryOverride {
    if (_self.outputDirectoryOverride == null) {
    return null;
  }

  return $OutputDirectorySettingsCopyWith<$Res>(_self.outputDirectoryOverride!, (value) {
    return _then(_self.copyWith(outputDirectoryOverride: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoFile].
extension VideoFilePatterns on VideoFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoFile value)  $default,){
final _that = this;
switch (_that) {
case _VideoFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoFile value)?  $default,){
final _that = this;
switch (_that) {
case _VideoFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String name,  int sizeInBytes,  DateTime importedAt,  VideoMetadata? metadata,  EncodeSettings? overrideSettings,  String? appliedPresetId,  OutputDirectorySettings? outputDirectoryOverride)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoFile() when $default != null:
return $default(_that.path,_that.name,_that.sizeInBytes,_that.importedAt,_that.metadata,_that.overrideSettings,_that.appliedPresetId,_that.outputDirectoryOverride);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String name,  int sizeInBytes,  DateTime importedAt,  VideoMetadata? metadata,  EncodeSettings? overrideSettings,  String? appliedPresetId,  OutputDirectorySettings? outputDirectoryOverride)  $default,) {final _that = this;
switch (_that) {
case _VideoFile():
return $default(_that.path,_that.name,_that.sizeInBytes,_that.importedAt,_that.metadata,_that.overrideSettings,_that.appliedPresetId,_that.outputDirectoryOverride);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String name,  int sizeInBytes,  DateTime importedAt,  VideoMetadata? metadata,  EncodeSettings? overrideSettings,  String? appliedPresetId,  OutputDirectorySettings? outputDirectoryOverride)?  $default,) {final _that = this;
switch (_that) {
case _VideoFile() when $default != null:
return $default(_that.path,_that.name,_that.sizeInBytes,_that.importedAt,_that.metadata,_that.overrideSettings,_that.appliedPresetId,_that.outputDirectoryOverride);case _:
  return null;

}
}

}

/// @nodoc


class _VideoFile implements VideoFile {
  const _VideoFile({required this.path, required this.name, required this.sizeInBytes, required this.importedAt, this.metadata, this.overrideSettings, this.appliedPresetId, this.outputDirectoryOverride});
  

@override final  String path;
@override final  String name;
@override final  int sizeInBytes;
@override final  DateTime importedAt;
@override final  VideoMetadata? metadata;
/// Per-file encode settings override. Null = use global settings.
@override final  EncodeSettings? overrideSettings;
/// Preset id last selected in the per-file settings dialog.
/// Null = file follows the globally selected preset.
@override final  String? appliedPresetId;
/// Per-file output directory override. Null = use the global output
/// directory setting.
@override final  OutputDirectorySettings? outputDirectoryOverride;

/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoFileCopyWith<_VideoFile> get copyWith => __$VideoFileCopyWithImpl<_VideoFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoFile&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.sizeInBytes, sizeInBytes) || other.sizeInBytes == sizeInBytes)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.overrideSettings, overrideSettings) || other.overrideSettings == overrideSettings)&&(identical(other.appliedPresetId, appliedPresetId) || other.appliedPresetId == appliedPresetId)&&(identical(other.outputDirectoryOverride, outputDirectoryOverride) || other.outputDirectoryOverride == outputDirectoryOverride));
}


@override
int get hashCode => Object.hash(runtimeType,path,name,sizeInBytes,importedAt,metadata,overrideSettings,appliedPresetId,outputDirectoryOverride);

@override
String toString() {
  return 'VideoFile(path: $path, name: $name, sizeInBytes: $sizeInBytes, importedAt: $importedAt, metadata: $metadata, overrideSettings: $overrideSettings, appliedPresetId: $appliedPresetId, outputDirectoryOverride: $outputDirectoryOverride)';
}


}

/// @nodoc
abstract mixin class _$VideoFileCopyWith<$Res> implements $VideoFileCopyWith<$Res> {
  factory _$VideoFileCopyWith(_VideoFile value, $Res Function(_VideoFile) _then) = __$VideoFileCopyWithImpl;
@override @useResult
$Res call({
 String path, String name, int sizeInBytes, DateTime importedAt, VideoMetadata? metadata, EncodeSettings? overrideSettings, String? appliedPresetId, OutputDirectorySettings? outputDirectoryOverride
});


@override $VideoMetadataCopyWith<$Res>? get metadata;@override $EncodeSettingsCopyWith<$Res>? get overrideSettings;@override $OutputDirectorySettingsCopyWith<$Res>? get outputDirectoryOverride;

}
/// @nodoc
class __$VideoFileCopyWithImpl<$Res>
    implements _$VideoFileCopyWith<$Res> {
  __$VideoFileCopyWithImpl(this._self, this._then);

  final _VideoFile _self;
  final $Res Function(_VideoFile) _then;

/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,Object? sizeInBytes = null,Object? importedAt = null,Object? metadata = freezed,Object? overrideSettings = freezed,Object? appliedPresetId = freezed,Object? outputDirectoryOverride = freezed,}) {
  return _then(_VideoFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sizeInBytes: null == sizeInBytes ? _self.sizeInBytes : sizeInBytes // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as VideoMetadata?,overrideSettings: freezed == overrideSettings ? _self.overrideSettings : overrideSettings // ignore: cast_nullable_to_non_nullable
as EncodeSettings?,appliedPresetId: freezed == appliedPresetId ? _self.appliedPresetId : appliedPresetId // ignore: cast_nullable_to_non_nullable
as String?,outputDirectoryOverride: freezed == outputDirectoryOverride ? _self.outputDirectoryOverride : outputDirectoryOverride // ignore: cast_nullable_to_non_nullable
as OutputDirectorySettings?,
  ));
}

/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $VideoMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<$Res>? get overrideSettings {
    if (_self.overrideSettings == null) {
    return null;
  }

  return $EncodeSettingsCopyWith<$Res>(_self.overrideSettings!, (value) {
    return _then(_self.copyWith(overrideSettings: value));
  });
}/// Create a copy of VideoFile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OutputDirectorySettingsCopyWith<$Res>? get outputDirectoryOverride {
    if (_self.outputDirectoryOverride == null) {
    return null;
  }

  return $OutputDirectorySettingsCopyWith<$Res>(_self.outputDirectoryOverride!, (value) {
    return _then(_self.copyWith(outputDirectoryOverride: value));
  });
}
}

// dart format on
