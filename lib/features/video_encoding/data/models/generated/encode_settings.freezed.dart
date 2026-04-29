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
mixin _$TextOverlay {

/// The text content. Ignored when [type] is [TextOverlayType.timestamp].
 String get text; TextOverlayType get type; int get fontSize; String get fontColor; TextOverlayPosition get position; int get offsetX; int get offsetY; String? get fontFile; bool get showBackground; String get backgroundColor;/// Border (stroke) width in pixels around each character. 0 disables.
 int get borderWidth; String get borderColor;/// When [type] is [TextOverlayType.timestamp], appends the timezone offset
/// (e.g. " +07:00") after the time line. Ignored for custom overlays.
 bool get showTimezone;
/// Create a copy of TextOverlay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextOverlayCopyWith<TextOverlay> get copyWith => _$TextOverlayCopyWithImpl<TextOverlay>(this as TextOverlay, _$identity);

  /// Serializes this TextOverlay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextOverlay&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.fontColor, fontColor) || other.fontColor == fontColor)&&(identical(other.position, position) || other.position == position)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY)&&(identical(other.fontFile, fontFile) || other.fontFile == fontFile)&&(identical(other.showBackground, showBackground) || other.showBackground == showBackground)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor)&&(identical(other.showTimezone, showTimezone) || other.showTimezone == showTimezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type,fontSize,fontColor,position,offsetX,offsetY,fontFile,showBackground,backgroundColor,borderWidth,borderColor,showTimezone);

@override
String toString() {
  return 'TextOverlay(text: $text, type: $type, fontSize: $fontSize, fontColor: $fontColor, position: $position, offsetX: $offsetX, offsetY: $offsetY, fontFile: $fontFile, showBackground: $showBackground, backgroundColor: $backgroundColor, borderWidth: $borderWidth, borderColor: $borderColor, showTimezone: $showTimezone)';
}


}

/// @nodoc
abstract mixin class $TextOverlayCopyWith<$Res>  {
  factory $TextOverlayCopyWith(TextOverlay value, $Res Function(TextOverlay) _then) = _$TextOverlayCopyWithImpl;
@useResult
$Res call({
 String text, TextOverlayType type, int fontSize, String fontColor, TextOverlayPosition position, int offsetX, int offsetY, String? fontFile, bool showBackground, String backgroundColor, int borderWidth, String borderColor, bool showTimezone
});




}
/// @nodoc
class _$TextOverlayCopyWithImpl<$Res>
    implements $TextOverlayCopyWith<$Res> {
  _$TextOverlayCopyWithImpl(this._self, this._then);

  final TextOverlay _self;
  final $Res Function(TextOverlay) _then;

/// Create a copy of TextOverlay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? type = null,Object? fontSize = null,Object? fontColor = null,Object? position = null,Object? offsetX = null,Object? offsetY = null,Object? fontFile = freezed,Object? showBackground = null,Object? backgroundColor = null,Object? borderWidth = null,Object? borderColor = null,Object? showTimezone = null,}) {
  return _then(_self.copyWith(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TextOverlayType,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int,fontColor: null == fontColor ? _self.fontColor : fontColor // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as TextOverlayPosition,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as int,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as int,fontFile: freezed == fontFile ? _self.fontFile : fontFile // ignore: cast_nullable_to_non_nullable
as String?,showBackground: null == showBackground ? _self.showBackground : showBackground // ignore: cast_nullable_to_non_nullable
as bool,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String,borderWidth: null == borderWidth ? _self.borderWidth : borderWidth // ignore: cast_nullable_to_non_nullable
as int,borderColor: null == borderColor ? _self.borderColor : borderColor // ignore: cast_nullable_to_non_nullable
as String,showTimezone: null == showTimezone ? _self.showTimezone : showTimezone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TextOverlay].
extension TextOverlayPatterns on TextOverlay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextOverlay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextOverlay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextOverlay value)  $default,){
final _that = this;
switch (_that) {
case _TextOverlay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextOverlay value)?  $default,){
final _that = this;
switch (_that) {
case _TextOverlay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  TextOverlayType type,  int fontSize,  String fontColor,  TextOverlayPosition position,  int offsetX,  int offsetY,  String? fontFile,  bool showBackground,  String backgroundColor,  int borderWidth,  String borderColor,  bool showTimezone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextOverlay() when $default != null:
return $default(_that.text,_that.type,_that.fontSize,_that.fontColor,_that.position,_that.offsetX,_that.offsetY,_that.fontFile,_that.showBackground,_that.backgroundColor,_that.borderWidth,_that.borderColor,_that.showTimezone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  TextOverlayType type,  int fontSize,  String fontColor,  TextOverlayPosition position,  int offsetX,  int offsetY,  String? fontFile,  bool showBackground,  String backgroundColor,  int borderWidth,  String borderColor,  bool showTimezone)  $default,) {final _that = this;
switch (_that) {
case _TextOverlay():
return $default(_that.text,_that.type,_that.fontSize,_that.fontColor,_that.position,_that.offsetX,_that.offsetY,_that.fontFile,_that.showBackground,_that.backgroundColor,_that.borderWidth,_that.borderColor,_that.showTimezone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  TextOverlayType type,  int fontSize,  String fontColor,  TextOverlayPosition position,  int offsetX,  int offsetY,  String? fontFile,  bool showBackground,  String backgroundColor,  int borderWidth,  String borderColor,  bool showTimezone)?  $default,) {final _that = this;
switch (_that) {
case _TextOverlay() when $default != null:
return $default(_that.text,_that.type,_that.fontSize,_that.fontColor,_that.position,_that.offsetX,_that.offsetY,_that.fontFile,_that.showBackground,_that.backgroundColor,_that.borderWidth,_that.borderColor,_that.showTimezone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextOverlay implements TextOverlay {
  const _TextOverlay({required this.text, this.type = TextOverlayType.custom, this.fontSize = 24, this.fontColor = 'white', this.position = TextOverlayPosition.bottomRight, this.offsetX = 16, this.offsetY = 16, this.fontFile, this.showBackground = true, this.backgroundColor = 'black@0.5', this.borderWidth = 0, this.borderColor = 'black', this.showTimezone = false});
  factory _TextOverlay.fromJson(Map<String, dynamic> json) => _$TextOverlayFromJson(json);

/// The text content. Ignored when [type] is [TextOverlayType.timestamp].
@override final  String text;
@override@JsonKey() final  TextOverlayType type;
@override@JsonKey() final  int fontSize;
@override@JsonKey() final  String fontColor;
@override@JsonKey() final  TextOverlayPosition position;
@override@JsonKey() final  int offsetX;
@override@JsonKey() final  int offsetY;
@override final  String? fontFile;
@override@JsonKey() final  bool showBackground;
@override@JsonKey() final  String backgroundColor;
/// Border (stroke) width in pixels around each character. 0 disables.
@override@JsonKey() final  int borderWidth;
@override@JsonKey() final  String borderColor;
/// When [type] is [TextOverlayType.timestamp], appends the timezone offset
/// (e.g. " +07:00") after the time line. Ignored for custom overlays.
@override@JsonKey() final  bool showTimezone;

/// Create a copy of TextOverlay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextOverlayCopyWith<_TextOverlay> get copyWith => __$TextOverlayCopyWithImpl<_TextOverlay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextOverlayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextOverlay&&(identical(other.text, text) || other.text == text)&&(identical(other.type, type) || other.type == type)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.fontColor, fontColor) || other.fontColor == fontColor)&&(identical(other.position, position) || other.position == position)&&(identical(other.offsetX, offsetX) || other.offsetX == offsetX)&&(identical(other.offsetY, offsetY) || other.offsetY == offsetY)&&(identical(other.fontFile, fontFile) || other.fontFile == fontFile)&&(identical(other.showBackground, showBackground) || other.showBackground == showBackground)&&(identical(other.backgroundColor, backgroundColor) || other.backgroundColor == backgroundColor)&&(identical(other.borderWidth, borderWidth) || other.borderWidth == borderWidth)&&(identical(other.borderColor, borderColor) || other.borderColor == borderColor)&&(identical(other.showTimezone, showTimezone) || other.showTimezone == showTimezone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,type,fontSize,fontColor,position,offsetX,offsetY,fontFile,showBackground,backgroundColor,borderWidth,borderColor,showTimezone);

@override
String toString() {
  return 'TextOverlay(text: $text, type: $type, fontSize: $fontSize, fontColor: $fontColor, position: $position, offsetX: $offsetX, offsetY: $offsetY, fontFile: $fontFile, showBackground: $showBackground, backgroundColor: $backgroundColor, borderWidth: $borderWidth, borderColor: $borderColor, showTimezone: $showTimezone)';
}


}

/// @nodoc
abstract mixin class _$TextOverlayCopyWith<$Res> implements $TextOverlayCopyWith<$Res> {
  factory _$TextOverlayCopyWith(_TextOverlay value, $Res Function(_TextOverlay) _then) = __$TextOverlayCopyWithImpl;
@override @useResult
$Res call({
 String text, TextOverlayType type, int fontSize, String fontColor, TextOverlayPosition position, int offsetX, int offsetY, String? fontFile, bool showBackground, String backgroundColor, int borderWidth, String borderColor, bool showTimezone
});




}
/// @nodoc
class __$TextOverlayCopyWithImpl<$Res>
    implements _$TextOverlayCopyWith<$Res> {
  __$TextOverlayCopyWithImpl(this._self, this._then);

  final _TextOverlay _self;
  final $Res Function(_TextOverlay) _then;

/// Create a copy of TextOverlay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? type = null,Object? fontSize = null,Object? fontColor = null,Object? position = null,Object? offsetX = null,Object? offsetY = null,Object? fontFile = freezed,Object? showBackground = null,Object? backgroundColor = null,Object? borderWidth = null,Object? borderColor = null,Object? showTimezone = null,}) {
  return _then(_TextOverlay(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TextOverlayType,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as int,fontColor: null == fontColor ? _self.fontColor : fontColor // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as TextOverlayPosition,offsetX: null == offsetX ? _self.offsetX : offsetX // ignore: cast_nullable_to_non_nullable
as int,offsetY: null == offsetY ? _self.offsetY : offsetY // ignore: cast_nullable_to_non_nullable
as int,fontFile: freezed == fontFile ? _self.fontFile : fontFile // ignore: cast_nullable_to_non_nullable
as String?,showBackground: null == showBackground ? _self.showBackground : showBackground // ignore: cast_nullable_to_non_nullable
as bool,backgroundColor: null == backgroundColor ? _self.backgroundColor : backgroundColor // ignore: cast_nullable_to_non_nullable
as String,borderWidth: null == borderWidth ? _self.borderWidth : borderWidth // ignore: cast_nullable_to_non_nullable
as int,borderColor: null == borderColor ? _self.borderColor : borderColor // ignore: cast_nullable_to_non_nullable
as String,showTimezone: null == showTimezone ? _self.showTimezone : showTimezone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$EncodeSettings {

 VideoEncoder get codec; EncodePreset get preset; int get crf; OutputExtension get outputExtension;/// Null = keep original resolution. Format: "1920:1080".
 String? get resolution; AudioCodec get audioCodec; AudioBitrate get audioBitrate; List<TextOverlay> get textOverlays;/// Template for output file name (without extension). Empty = default
/// `<name>_encoded`. See [FilenameTemplate] for supported tags.
 String get outputNameTemplate;/// Target aspect ratio `num:den` (e.g. "16:9", "9:16", "1:1"). Null or
/// empty = keep original, no crop.
 String? get cropAspectRatio;/// Deinterlacing filter applied before text overlays.
 Deinterlace get deinterlace; QualityMode get qualityMode; int get avgBitrateKbps; bool get twoPass; bool get turboFirstPass;/// Raw extra params forwarded via codec-specific flag (e.g. `-x265-params`).
 String get extraParams; bool get copySourceMetadata;/// Override for the source video's timezone offset (e.g. "+07:00"). Used
/// when the source MP4 doesn't carry an offset itself — typical for non-
/// Apple cameras. Null = fall back to the encoding machine's local TZ.
 String? get sourceTimezoneOffset; bool get webOptimized;
/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncodeSettingsCopyWith<EncodeSettings> get copyWith => _$EncodeSettingsCopyWithImpl<EncodeSettings>(this as EncodeSettings, _$identity);

  /// Serializes this EncodeSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncodeSettings&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.crf, crf) || other.crf == crf)&&(identical(other.outputExtension, outputExtension) || other.outputExtension == outputExtension)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.audioBitrate, audioBitrate) || other.audioBitrate == audioBitrate)&&const DeepCollectionEquality().equals(other.textOverlays, textOverlays)&&(identical(other.outputNameTemplate, outputNameTemplate) || other.outputNameTemplate == outputNameTemplate)&&(identical(other.cropAspectRatio, cropAspectRatio) || other.cropAspectRatio == cropAspectRatio)&&(identical(other.deinterlace, deinterlace) || other.deinterlace == deinterlace)&&(identical(other.qualityMode, qualityMode) || other.qualityMode == qualityMode)&&(identical(other.avgBitrateKbps, avgBitrateKbps) || other.avgBitrateKbps == avgBitrateKbps)&&(identical(other.twoPass, twoPass) || other.twoPass == twoPass)&&(identical(other.turboFirstPass, turboFirstPass) || other.turboFirstPass == turboFirstPass)&&(identical(other.extraParams, extraParams) || other.extraParams == extraParams)&&(identical(other.copySourceMetadata, copySourceMetadata) || other.copySourceMetadata == copySourceMetadata)&&(identical(other.sourceTimezoneOffset, sourceTimezoneOffset) || other.sourceTimezoneOffset == sourceTimezoneOffset)&&(identical(other.webOptimized, webOptimized) || other.webOptimized == webOptimized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,codec,preset,crf,outputExtension,resolution,audioCodec,audioBitrate,const DeepCollectionEquality().hash(textOverlays),outputNameTemplate,cropAspectRatio,deinterlace,qualityMode,avgBitrateKbps,twoPass,turboFirstPass,extraParams,copySourceMetadata,sourceTimezoneOffset,webOptimized]);

@override
String toString() {
  return 'EncodeSettings(codec: $codec, preset: $preset, crf: $crf, outputExtension: $outputExtension, resolution: $resolution, audioCodec: $audioCodec, audioBitrate: $audioBitrate, textOverlays: $textOverlays, outputNameTemplate: $outputNameTemplate, cropAspectRatio: $cropAspectRatio, deinterlace: $deinterlace, qualityMode: $qualityMode, avgBitrateKbps: $avgBitrateKbps, twoPass: $twoPass, turboFirstPass: $turboFirstPass, extraParams: $extraParams, copySourceMetadata: $copySourceMetadata, sourceTimezoneOffset: $sourceTimezoneOffset, webOptimized: $webOptimized)';
}


}

/// @nodoc
abstract mixin class $EncodeSettingsCopyWith<$Res>  {
  factory $EncodeSettingsCopyWith(EncodeSettings value, $Res Function(EncodeSettings) _then) = _$EncodeSettingsCopyWithImpl;
@useResult
$Res call({
 VideoEncoder codec, EncodePreset preset, int crf, OutputExtension outputExtension, String? resolution, AudioCodec audioCodec, AudioBitrate audioBitrate, List<TextOverlay> textOverlays, String outputNameTemplate, String? cropAspectRatio, Deinterlace deinterlace, QualityMode qualityMode, int avgBitrateKbps, bool twoPass, bool turboFirstPass, String extraParams, bool copySourceMetadata, String? sourceTimezoneOffset, bool webOptimized
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
@pragma('vm:prefer-inline') @override $Res call({Object? codec = null,Object? preset = null,Object? crf = null,Object? outputExtension = null,Object? resolution = freezed,Object? audioCodec = null,Object? audioBitrate = null,Object? textOverlays = null,Object? outputNameTemplate = null,Object? cropAspectRatio = freezed,Object? deinterlace = null,Object? qualityMode = null,Object? avgBitrateKbps = null,Object? twoPass = null,Object? turboFirstPass = null,Object? extraParams = null,Object? copySourceMetadata = null,Object? sourceTimezoneOffset = freezed,Object? webOptimized = null,}) {
  return _then(_self.copyWith(
codec: null == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as VideoEncoder,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as EncodePreset,crf: null == crf ? _self.crf : crf // ignore: cast_nullable_to_non_nullable
as int,outputExtension: null == outputExtension ? _self.outputExtension : outputExtension // ignore: cast_nullable_to_non_nullable
as OutputExtension,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: null == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as AudioCodec,audioBitrate: null == audioBitrate ? _self.audioBitrate : audioBitrate // ignore: cast_nullable_to_non_nullable
as AudioBitrate,textOverlays: null == textOverlays ? _self.textOverlays : textOverlays // ignore: cast_nullable_to_non_nullable
as List<TextOverlay>,outputNameTemplate: null == outputNameTemplate ? _self.outputNameTemplate : outputNameTemplate // ignore: cast_nullable_to_non_nullable
as String,cropAspectRatio: freezed == cropAspectRatio ? _self.cropAspectRatio : cropAspectRatio // ignore: cast_nullable_to_non_nullable
as String?,deinterlace: null == deinterlace ? _self.deinterlace : deinterlace // ignore: cast_nullable_to_non_nullable
as Deinterlace,qualityMode: null == qualityMode ? _self.qualityMode : qualityMode // ignore: cast_nullable_to_non_nullable
as QualityMode,avgBitrateKbps: null == avgBitrateKbps ? _self.avgBitrateKbps : avgBitrateKbps // ignore: cast_nullable_to_non_nullable
as int,twoPass: null == twoPass ? _self.twoPass : twoPass // ignore: cast_nullable_to_non_nullable
as bool,turboFirstPass: null == turboFirstPass ? _self.turboFirstPass : turboFirstPass // ignore: cast_nullable_to_non_nullable
as bool,extraParams: null == extraParams ? _self.extraParams : extraParams // ignore: cast_nullable_to_non_nullable
as String,copySourceMetadata: null == copySourceMetadata ? _self.copySourceMetadata : copySourceMetadata // ignore: cast_nullable_to_non_nullable
as bool,sourceTimezoneOffset: freezed == sourceTimezoneOffset ? _self.sourceTimezoneOffset : sourceTimezoneOffset // ignore: cast_nullable_to_non_nullable
as String?,webOptimized: null == webOptimized ? _self.webOptimized : webOptimized // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VideoEncoder codec,  EncodePreset preset,  int crf,  OutputExtension outputExtension,  String? resolution,  AudioCodec audioCodec,  AudioBitrate audioBitrate,  List<TextOverlay> textOverlays,  String outputNameTemplate,  String? cropAspectRatio,  Deinterlace deinterlace,  QualityMode qualityMode,  int avgBitrateKbps,  bool twoPass,  bool turboFirstPass,  String extraParams,  bool copySourceMetadata,  String? sourceTimezoneOffset,  bool webOptimized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
return $default(_that.codec,_that.preset,_that.crf,_that.outputExtension,_that.resolution,_that.audioCodec,_that.audioBitrate,_that.textOverlays,_that.outputNameTemplate,_that.cropAspectRatio,_that.deinterlace,_that.qualityMode,_that.avgBitrateKbps,_that.twoPass,_that.turboFirstPass,_that.extraParams,_that.copySourceMetadata,_that.sourceTimezoneOffset,_that.webOptimized);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VideoEncoder codec,  EncodePreset preset,  int crf,  OutputExtension outputExtension,  String? resolution,  AudioCodec audioCodec,  AudioBitrate audioBitrate,  List<TextOverlay> textOverlays,  String outputNameTemplate,  String? cropAspectRatio,  Deinterlace deinterlace,  QualityMode qualityMode,  int avgBitrateKbps,  bool twoPass,  bool turboFirstPass,  String extraParams,  bool copySourceMetadata,  String? sourceTimezoneOffset,  bool webOptimized)  $default,) {final _that = this;
switch (_that) {
case _EncodeSettings():
return $default(_that.codec,_that.preset,_that.crf,_that.outputExtension,_that.resolution,_that.audioCodec,_that.audioBitrate,_that.textOverlays,_that.outputNameTemplate,_that.cropAspectRatio,_that.deinterlace,_that.qualityMode,_that.avgBitrateKbps,_that.twoPass,_that.turboFirstPass,_that.extraParams,_that.copySourceMetadata,_that.sourceTimezoneOffset,_that.webOptimized);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VideoEncoder codec,  EncodePreset preset,  int crf,  OutputExtension outputExtension,  String? resolution,  AudioCodec audioCodec,  AudioBitrate audioBitrate,  List<TextOverlay> textOverlays,  String outputNameTemplate,  String? cropAspectRatio,  Deinterlace deinterlace,  QualityMode qualityMode,  int avgBitrateKbps,  bool twoPass,  bool turboFirstPass,  String extraParams,  bool copySourceMetadata,  String? sourceTimezoneOffset,  bool webOptimized)?  $default,) {final _that = this;
switch (_that) {
case _EncodeSettings() when $default != null:
return $default(_that.codec,_that.preset,_that.crf,_that.outputExtension,_that.resolution,_that.audioCodec,_that.audioBitrate,_that.textOverlays,_that.outputNameTemplate,_that.cropAspectRatio,_that.deinterlace,_that.qualityMode,_that.avgBitrateKbps,_that.twoPass,_that.turboFirstPass,_that.extraParams,_that.copySourceMetadata,_that.sourceTimezoneOffset,_that.webOptimized);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EncodeSettings extends EncodeSettings {
  const _EncodeSettings({this.codec = VideoEncoder.h264, this.preset = EncodePreset.veryfast, this.crf = 23, this.outputExtension = OutputExtension.mp4, this.resolution, this.audioCodec = AudioCodec.passthrough, this.audioBitrate = AudioBitrate.k128, final  List<TextOverlay> textOverlays = const [], this.outputNameTemplate = '', this.cropAspectRatio, this.deinterlace = Deinterlace.off, this.qualityMode = QualityMode.crf, this.avgBitrateKbps = 4000, this.twoPass = false, this.turboFirstPass = false, this.extraParams = '', this.copySourceMetadata = true, this.sourceTimezoneOffset, this.webOptimized = true}): _textOverlays = textOverlays,super._();
  factory _EncodeSettings.fromJson(Map<String, dynamic> json) => _$EncodeSettingsFromJson(json);

@override@JsonKey() final  VideoEncoder codec;
@override@JsonKey() final  EncodePreset preset;
@override@JsonKey() final  int crf;
@override@JsonKey() final  OutputExtension outputExtension;
/// Null = keep original resolution. Format: "1920:1080".
@override final  String? resolution;
@override@JsonKey() final  AudioCodec audioCodec;
@override@JsonKey() final  AudioBitrate audioBitrate;
 final  List<TextOverlay> _textOverlays;
@override@JsonKey() List<TextOverlay> get textOverlays {
  if (_textOverlays is EqualUnmodifiableListView) return _textOverlays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_textOverlays);
}

/// Template for output file name (without extension). Empty = default
/// `<name>_encoded`. See [FilenameTemplate] for supported tags.
@override@JsonKey() final  String outputNameTemplate;
/// Target aspect ratio `num:den` (e.g. "16:9", "9:16", "1:1"). Null or
/// empty = keep original, no crop.
@override final  String? cropAspectRatio;
/// Deinterlacing filter applied before text overlays.
@override@JsonKey() final  Deinterlace deinterlace;
@override@JsonKey() final  QualityMode qualityMode;
@override@JsonKey() final  int avgBitrateKbps;
@override@JsonKey() final  bool twoPass;
@override@JsonKey() final  bool turboFirstPass;
/// Raw extra params forwarded via codec-specific flag (e.g. `-x265-params`).
@override@JsonKey() final  String extraParams;
@override@JsonKey() final  bool copySourceMetadata;
/// Override for the source video's timezone offset (e.g. "+07:00"). Used
/// when the source MP4 doesn't carry an offset itself — typical for non-
/// Apple cameras. Null = fall back to the encoding machine's local TZ.
@override final  String? sourceTimezoneOffset;
@override@JsonKey() final  bool webOptimized;

/// Create a copy of EncodeSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncodeSettingsCopyWith<_EncodeSettings> get copyWith => __$EncodeSettingsCopyWithImpl<_EncodeSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EncodeSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncodeSettings&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.crf, crf) || other.crf == crf)&&(identical(other.outputExtension, outputExtension) || other.outputExtension == outputExtension)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.audioBitrate, audioBitrate) || other.audioBitrate == audioBitrate)&&const DeepCollectionEquality().equals(other._textOverlays, _textOverlays)&&(identical(other.outputNameTemplate, outputNameTemplate) || other.outputNameTemplate == outputNameTemplate)&&(identical(other.cropAspectRatio, cropAspectRatio) || other.cropAspectRatio == cropAspectRatio)&&(identical(other.deinterlace, deinterlace) || other.deinterlace == deinterlace)&&(identical(other.qualityMode, qualityMode) || other.qualityMode == qualityMode)&&(identical(other.avgBitrateKbps, avgBitrateKbps) || other.avgBitrateKbps == avgBitrateKbps)&&(identical(other.twoPass, twoPass) || other.twoPass == twoPass)&&(identical(other.turboFirstPass, turboFirstPass) || other.turboFirstPass == turboFirstPass)&&(identical(other.extraParams, extraParams) || other.extraParams == extraParams)&&(identical(other.copySourceMetadata, copySourceMetadata) || other.copySourceMetadata == copySourceMetadata)&&(identical(other.sourceTimezoneOffset, sourceTimezoneOffset) || other.sourceTimezoneOffset == sourceTimezoneOffset)&&(identical(other.webOptimized, webOptimized) || other.webOptimized == webOptimized));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,codec,preset,crf,outputExtension,resolution,audioCodec,audioBitrate,const DeepCollectionEquality().hash(_textOverlays),outputNameTemplate,cropAspectRatio,deinterlace,qualityMode,avgBitrateKbps,twoPass,turboFirstPass,extraParams,copySourceMetadata,sourceTimezoneOffset,webOptimized]);

@override
String toString() {
  return 'EncodeSettings(codec: $codec, preset: $preset, crf: $crf, outputExtension: $outputExtension, resolution: $resolution, audioCodec: $audioCodec, audioBitrate: $audioBitrate, textOverlays: $textOverlays, outputNameTemplate: $outputNameTemplate, cropAspectRatio: $cropAspectRatio, deinterlace: $deinterlace, qualityMode: $qualityMode, avgBitrateKbps: $avgBitrateKbps, twoPass: $twoPass, turboFirstPass: $turboFirstPass, extraParams: $extraParams, copySourceMetadata: $copySourceMetadata, sourceTimezoneOffset: $sourceTimezoneOffset, webOptimized: $webOptimized)';
}


}

/// @nodoc
abstract mixin class _$EncodeSettingsCopyWith<$Res> implements $EncodeSettingsCopyWith<$Res> {
  factory _$EncodeSettingsCopyWith(_EncodeSettings value, $Res Function(_EncodeSettings) _then) = __$EncodeSettingsCopyWithImpl;
@override @useResult
$Res call({
 VideoEncoder codec, EncodePreset preset, int crf, OutputExtension outputExtension, String? resolution, AudioCodec audioCodec, AudioBitrate audioBitrate, List<TextOverlay> textOverlays, String outputNameTemplate, String? cropAspectRatio, Deinterlace deinterlace, QualityMode qualityMode, int avgBitrateKbps, bool twoPass, bool turboFirstPass, String extraParams, bool copySourceMetadata, String? sourceTimezoneOffset, bool webOptimized
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
@override @pragma('vm:prefer-inline') $Res call({Object? codec = null,Object? preset = null,Object? crf = null,Object? outputExtension = null,Object? resolution = freezed,Object? audioCodec = null,Object? audioBitrate = null,Object? textOverlays = null,Object? outputNameTemplate = null,Object? cropAspectRatio = freezed,Object? deinterlace = null,Object? qualityMode = null,Object? avgBitrateKbps = null,Object? twoPass = null,Object? turboFirstPass = null,Object? extraParams = null,Object? copySourceMetadata = null,Object? sourceTimezoneOffset = freezed,Object? webOptimized = null,}) {
  return _then(_EncodeSettings(
codec: null == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as VideoEncoder,preset: null == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as EncodePreset,crf: null == crf ? _self.crf : crf // ignore: cast_nullable_to_non_nullable
as int,outputExtension: null == outputExtension ? _self.outputExtension : outputExtension // ignore: cast_nullable_to_non_nullable
as OutputExtension,resolution: freezed == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: null == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as AudioCodec,audioBitrate: null == audioBitrate ? _self.audioBitrate : audioBitrate // ignore: cast_nullable_to_non_nullable
as AudioBitrate,textOverlays: null == textOverlays ? _self._textOverlays : textOverlays // ignore: cast_nullable_to_non_nullable
as List<TextOverlay>,outputNameTemplate: null == outputNameTemplate ? _self.outputNameTemplate : outputNameTemplate // ignore: cast_nullable_to_non_nullable
as String,cropAspectRatio: freezed == cropAspectRatio ? _self.cropAspectRatio : cropAspectRatio // ignore: cast_nullable_to_non_nullable
as String?,deinterlace: null == deinterlace ? _self.deinterlace : deinterlace // ignore: cast_nullable_to_non_nullable
as Deinterlace,qualityMode: null == qualityMode ? _self.qualityMode : qualityMode // ignore: cast_nullable_to_non_nullable
as QualityMode,avgBitrateKbps: null == avgBitrateKbps ? _self.avgBitrateKbps : avgBitrateKbps // ignore: cast_nullable_to_non_nullable
as int,twoPass: null == twoPass ? _self.twoPass : twoPass // ignore: cast_nullable_to_non_nullable
as bool,turboFirstPass: null == turboFirstPass ? _self.turboFirstPass : turboFirstPass // ignore: cast_nullable_to_non_nullable
as bool,extraParams: null == extraParams ? _self.extraParams : extraParams // ignore: cast_nullable_to_non_nullable
as String,copySourceMetadata: null == copySourceMetadata ? _self.copySourceMetadata : copySourceMetadata // ignore: cast_nullable_to_non_nullable
as bool,sourceTimezoneOffset: freezed == sourceTimezoneOffset ? _self.sourceTimezoneOffset : sourceTimezoneOffset // ignore: cast_nullable_to_non_nullable
as String?,webOptimized: null == webOptimized ? _self.webOptimized : webOptimized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
