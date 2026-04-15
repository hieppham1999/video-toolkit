// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_encode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoEncodeState {

 EncodeStatus get status; EncodePreset get selectedPreset; EncodeProgress get progress; String? get errorMessage; String? get inputPath; String? get outputPath;
/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoEncodeStateCopyWith<VideoEncodeState> get copyWith => _$VideoEncodeStateCopyWithImpl<VideoEncodeState>(this as VideoEncodeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoEncodeState&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedPreset, selectedPreset) || other.selectedPreset == selectedPreset)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.inputPath, inputPath) || other.inputPath == inputPath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath));
}


@override
int get hashCode => Object.hash(runtimeType,status,selectedPreset,progress,errorMessage,inputPath,outputPath);

@override
String toString() {
  return 'VideoEncodeState(status: $status, selectedPreset: $selectedPreset, progress: $progress, errorMessage: $errorMessage, inputPath: $inputPath, outputPath: $outputPath)';
}


}

/// @nodoc
abstract mixin class $VideoEncodeStateCopyWith<$Res>  {
  factory $VideoEncodeStateCopyWith(VideoEncodeState value, $Res Function(VideoEncodeState) _then) = _$VideoEncodeStateCopyWithImpl;
@useResult
$Res call({
 EncodeStatus status, EncodePreset selectedPreset, EncodeProgress progress, String? errorMessage, String? inputPath, String? outputPath
});


$EncodeProgressCopyWith<$Res> get progress;

}
/// @nodoc
class _$VideoEncodeStateCopyWithImpl<$Res>
    implements $VideoEncodeStateCopyWith<$Res> {
  _$VideoEncodeStateCopyWithImpl(this._self, this._then);

  final VideoEncodeState _self;
  final $Res Function(VideoEncodeState) _then;

/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? selectedPreset = null,Object? progress = null,Object? errorMessage = freezed,Object? inputPath = freezed,Object? outputPath = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EncodeStatus,selectedPreset: null == selectedPreset ? _self.selectedPreset : selectedPreset // ignore: cast_nullable_to_non_nullable
as EncodePreset,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EncodeProgress,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,inputPath: freezed == inputPath ? _self.inputPath : inputPath // ignore: cast_nullable_to_non_nullable
as String?,outputPath: freezed == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeProgressCopyWith<$Res> get progress {
  
  return $EncodeProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoEncodeState].
extension VideoEncodeStatePatterns on VideoEncodeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoEncodeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoEncodeState value)  $default,){
final _that = this;
switch (_that) {
case _VideoEncodeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoEncodeState value)?  $default,){
final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EncodeStatus status,  EncodePreset selectedPreset,  EncodeProgress progress,  String? errorMessage,  String? inputPath,  String? outputPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
return $default(_that.status,_that.selectedPreset,_that.progress,_that.errorMessage,_that.inputPath,_that.outputPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EncodeStatus status,  EncodePreset selectedPreset,  EncodeProgress progress,  String? errorMessage,  String? inputPath,  String? outputPath)  $default,) {final _that = this;
switch (_that) {
case _VideoEncodeState():
return $default(_that.status,_that.selectedPreset,_that.progress,_that.errorMessage,_that.inputPath,_that.outputPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EncodeStatus status,  EncodePreset selectedPreset,  EncodeProgress progress,  String? errorMessage,  String? inputPath,  String? outputPath)?  $default,) {final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
return $default(_that.status,_that.selectedPreset,_that.progress,_that.errorMessage,_that.inputPath,_that.outputPath);case _:
  return null;

}
}

}

/// @nodoc


class _VideoEncodeState implements VideoEncodeState {
  const _VideoEncodeState({this.status = EncodeStatus.idle, this.selectedPreset = EncodePreset.h264Fast, this.progress = const EncodeProgress(), this.errorMessage, this.inputPath, this.outputPath});
  

@override@JsonKey() final  EncodeStatus status;
@override@JsonKey() final  EncodePreset selectedPreset;
@override@JsonKey() final  EncodeProgress progress;
@override final  String? errorMessage;
@override final  String? inputPath;
@override final  String? outputPath;

/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoEncodeStateCopyWith<_VideoEncodeState> get copyWith => __$VideoEncodeStateCopyWithImpl<_VideoEncodeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoEncodeState&&(identical(other.status, status) || other.status == status)&&(identical(other.selectedPreset, selectedPreset) || other.selectedPreset == selectedPreset)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.inputPath, inputPath) || other.inputPath == inputPath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath));
}


@override
int get hashCode => Object.hash(runtimeType,status,selectedPreset,progress,errorMessage,inputPath,outputPath);

@override
String toString() {
  return 'VideoEncodeState(status: $status, selectedPreset: $selectedPreset, progress: $progress, errorMessage: $errorMessage, inputPath: $inputPath, outputPath: $outputPath)';
}


}

/// @nodoc
abstract mixin class _$VideoEncodeStateCopyWith<$Res> implements $VideoEncodeStateCopyWith<$Res> {
  factory _$VideoEncodeStateCopyWith(_VideoEncodeState value, $Res Function(_VideoEncodeState) _then) = __$VideoEncodeStateCopyWithImpl;
@override @useResult
$Res call({
 EncodeStatus status, EncodePreset selectedPreset, EncodeProgress progress, String? errorMessage, String? inputPath, String? outputPath
});


@override $EncodeProgressCopyWith<$Res> get progress;

}
/// @nodoc
class __$VideoEncodeStateCopyWithImpl<$Res>
    implements _$VideoEncodeStateCopyWith<$Res> {
  __$VideoEncodeStateCopyWithImpl(this._self, this._then);

  final _VideoEncodeState _self;
  final $Res Function(_VideoEncodeState) _then;

/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? selectedPreset = null,Object? progress = null,Object? errorMessage = freezed,Object? inputPath = freezed,Object? outputPath = freezed,}) {
  return _then(_VideoEncodeState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EncodeStatus,selectedPreset: null == selectedPreset ? _self.selectedPreset : selectedPreset // ignore: cast_nullable_to_non_nullable
as EncodePreset,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EncodeProgress,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,inputPath: freezed == inputPath ? _self.inputPath : inputPath // ignore: cast_nullable_to_non_nullable
as String?,outputPath: freezed == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EncodeProgressCopyWith<$Res> get progress {
  
  return $EncodeProgressCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
