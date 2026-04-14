// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_metadata.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoMetadata {

 Duration? get duration; int? get width; int? get height; String? get videoCodec; String? get audioCodec; int? get bitrate; double? get frameRate; DateTime? get creationDate; double? get gpsLatitude; double? get gpsLongitude; String? get cameraModel; Map<String, String> get rawExif;
/// Create a copy of VideoMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoMetadataCopyWith<VideoMetadata> get copyWith => _$VideoMetadataCopyWithImpl<VideoMetadata>(this as VideoMetadata, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoMetadata&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.frameRate, frameRate) || other.frameRate == frameRate)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.gpsLatitude, gpsLatitude) || other.gpsLatitude == gpsLatitude)&&(identical(other.gpsLongitude, gpsLongitude) || other.gpsLongitude == gpsLongitude)&&(identical(other.cameraModel, cameraModel) || other.cameraModel == cameraModel)&&const DeepCollectionEquality().equals(other.rawExif, rawExif));
}


@override
int get hashCode => Object.hash(runtimeType,duration,width,height,videoCodec,audioCodec,bitrate,frameRate,creationDate,gpsLatitude,gpsLongitude,cameraModel,const DeepCollectionEquality().hash(rawExif));

@override
String toString() {
  return 'VideoMetadata(duration: $duration, width: $width, height: $height, videoCodec: $videoCodec, audioCodec: $audioCodec, bitrate: $bitrate, frameRate: $frameRate, creationDate: $creationDate, gpsLatitude: $gpsLatitude, gpsLongitude: $gpsLongitude, cameraModel: $cameraModel, rawExif: $rawExif)';
}


}

/// @nodoc
abstract mixin class $VideoMetadataCopyWith<$Res>  {
  factory $VideoMetadataCopyWith(VideoMetadata value, $Res Function(VideoMetadata) _then) = _$VideoMetadataCopyWithImpl;
@useResult
$Res call({
 Duration? duration, int? width, int? height, String? videoCodec, String? audioCodec, int? bitrate, double? frameRate, DateTime? creationDate, double? gpsLatitude, double? gpsLongitude, String? cameraModel, Map<String, String> rawExif
});




}
/// @nodoc
class _$VideoMetadataCopyWithImpl<$Res>
    implements $VideoMetadataCopyWith<$Res> {
  _$VideoMetadataCopyWithImpl(this._self, this._then);

  final VideoMetadata _self;
  final $Res Function(VideoMetadata) _then;

/// Create a copy of VideoMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? duration = freezed,Object? width = freezed,Object? height = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? bitrate = freezed,Object? frameRate = freezed,Object? creationDate = freezed,Object? gpsLatitude = freezed,Object? gpsLongitude = freezed,Object? cameraModel = freezed,Object? rawExif = null,}) {
  return _then(_self.copyWith(
duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,frameRate: freezed == frameRate ? _self.frameRate : frameRate // ignore: cast_nullable_to_non_nullable
as double?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,gpsLatitude: freezed == gpsLatitude ? _self.gpsLatitude : gpsLatitude // ignore: cast_nullable_to_non_nullable
as double?,gpsLongitude: freezed == gpsLongitude ? _self.gpsLongitude : gpsLongitude // ignore: cast_nullable_to_non_nullable
as double?,cameraModel: freezed == cameraModel ? _self.cameraModel : cameraModel // ignore: cast_nullable_to_non_nullable
as String?,rawExif: null == rawExif ? _self.rawExif : rawExif // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoMetadata].
extension VideoMetadataPatterns on VideoMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoMetadata value)  $default,){
final _that = this;
switch (_that) {
case _VideoMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _VideoMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Duration? duration,  int? width,  int? height,  String? videoCodec,  String? audioCodec,  int? bitrate,  double? frameRate,  DateTime? creationDate,  double? gpsLatitude,  double? gpsLongitude,  String? cameraModel,  Map<String, String> rawExif)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoMetadata() when $default != null:
return $default(_that.duration,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitrate,_that.frameRate,_that.creationDate,_that.gpsLatitude,_that.gpsLongitude,_that.cameraModel,_that.rawExif);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Duration? duration,  int? width,  int? height,  String? videoCodec,  String? audioCodec,  int? bitrate,  double? frameRate,  DateTime? creationDate,  double? gpsLatitude,  double? gpsLongitude,  String? cameraModel,  Map<String, String> rawExif)  $default,) {final _that = this;
switch (_that) {
case _VideoMetadata():
return $default(_that.duration,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitrate,_that.frameRate,_that.creationDate,_that.gpsLatitude,_that.gpsLongitude,_that.cameraModel,_that.rawExif);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Duration? duration,  int? width,  int? height,  String? videoCodec,  String? audioCodec,  int? bitrate,  double? frameRate,  DateTime? creationDate,  double? gpsLatitude,  double? gpsLongitude,  String? cameraModel,  Map<String, String> rawExif)?  $default,) {final _that = this;
switch (_that) {
case _VideoMetadata() when $default != null:
return $default(_that.duration,_that.width,_that.height,_that.videoCodec,_that.audioCodec,_that.bitrate,_that.frameRate,_that.creationDate,_that.gpsLatitude,_that.gpsLongitude,_that.cameraModel,_that.rawExif);case _:
  return null;

}
}

}

/// @nodoc


class _VideoMetadata implements VideoMetadata {
  const _VideoMetadata({this.duration, this.width, this.height, this.videoCodec, this.audioCodec, this.bitrate, this.frameRate, this.creationDate, this.gpsLatitude, this.gpsLongitude, this.cameraModel, final  Map<String, String> rawExif = const {}}): _rawExif = rawExif;
  

@override final  Duration? duration;
@override final  int? width;
@override final  int? height;
@override final  String? videoCodec;
@override final  String? audioCodec;
@override final  int? bitrate;
@override final  double? frameRate;
@override final  DateTime? creationDate;
@override final  double? gpsLatitude;
@override final  double? gpsLongitude;
@override final  String? cameraModel;
 final  Map<String, String> _rawExif;
@override@JsonKey() Map<String, String> get rawExif {
  if (_rawExif is EqualUnmodifiableMapView) return _rawExif;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawExif);
}


/// Create a copy of VideoMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoMetadataCopyWith<_VideoMetadata> get copyWith => __$VideoMetadataCopyWithImpl<_VideoMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoMetadata&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.bitrate, bitrate) || other.bitrate == bitrate)&&(identical(other.frameRate, frameRate) || other.frameRate == frameRate)&&(identical(other.creationDate, creationDate) || other.creationDate == creationDate)&&(identical(other.gpsLatitude, gpsLatitude) || other.gpsLatitude == gpsLatitude)&&(identical(other.gpsLongitude, gpsLongitude) || other.gpsLongitude == gpsLongitude)&&(identical(other.cameraModel, cameraModel) || other.cameraModel == cameraModel)&&const DeepCollectionEquality().equals(other._rawExif, _rawExif));
}


@override
int get hashCode => Object.hash(runtimeType,duration,width,height,videoCodec,audioCodec,bitrate,frameRate,creationDate,gpsLatitude,gpsLongitude,cameraModel,const DeepCollectionEquality().hash(_rawExif));

@override
String toString() {
  return 'VideoMetadata(duration: $duration, width: $width, height: $height, videoCodec: $videoCodec, audioCodec: $audioCodec, bitrate: $bitrate, frameRate: $frameRate, creationDate: $creationDate, gpsLatitude: $gpsLatitude, gpsLongitude: $gpsLongitude, cameraModel: $cameraModel, rawExif: $rawExif)';
}


}

/// @nodoc
abstract mixin class _$VideoMetadataCopyWith<$Res> implements $VideoMetadataCopyWith<$Res> {
  factory _$VideoMetadataCopyWith(_VideoMetadata value, $Res Function(_VideoMetadata) _then) = __$VideoMetadataCopyWithImpl;
@override @useResult
$Res call({
 Duration? duration, int? width, int? height, String? videoCodec, String? audioCodec, int? bitrate, double? frameRate, DateTime? creationDate, double? gpsLatitude, double? gpsLongitude, String? cameraModel, Map<String, String> rawExif
});




}
/// @nodoc
class __$VideoMetadataCopyWithImpl<$Res>
    implements _$VideoMetadataCopyWith<$Res> {
  __$VideoMetadataCopyWithImpl(this._self, this._then);

  final _VideoMetadata _self;
  final $Res Function(_VideoMetadata) _then;

/// Create a copy of VideoMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? duration = freezed,Object? width = freezed,Object? height = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? bitrate = freezed,Object? frameRate = freezed,Object? creationDate = freezed,Object? gpsLatitude = freezed,Object? gpsLongitude = freezed,Object? cameraModel = freezed,Object? rawExif = null,}) {
  return _then(_VideoMetadata(
duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,bitrate: freezed == bitrate ? _self.bitrate : bitrate // ignore: cast_nullable_to_non_nullable
as int?,frameRate: freezed == frameRate ? _self.frameRate : frameRate // ignore: cast_nullable_to_non_nullable
as double?,creationDate: freezed == creationDate ? _self.creationDate : creationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,gpsLatitude: freezed == gpsLatitude ? _self.gpsLatitude : gpsLatitude // ignore: cast_nullable_to_non_nullable
as double?,gpsLongitude: freezed == gpsLongitude ? _self.gpsLongitude : gpsLongitude // ignore: cast_nullable_to_non_nullable
as double?,cameraModel: freezed == cameraModel ? _self.cameraModel : cameraModel // ignore: cast_nullable_to_non_nullable
as String?,rawExif: null == rawExif ? _self._rawExif : rawExif // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
