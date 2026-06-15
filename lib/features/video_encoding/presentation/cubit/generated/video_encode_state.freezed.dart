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

 EncodeStatus get status; EncodeProgress get progress; String? get errorMessage; String? get currentFilePath; String? get outputPath; int get currentIndex; int get totalFiles; int get completedCount; List<EncodeFailure> get failures;
/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoEncodeStateCopyWith<VideoEncodeState> get copyWith => _$VideoEncodeStateCopyWithImpl<VideoEncodeState>(this as VideoEncodeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoEncodeState&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.currentFilePath, currentFilePath) || other.currentFilePath == currentFilePath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&const DeepCollectionEquality().equals(other.failures, failures));
}


@override
int get hashCode => Object.hash(runtimeType,status,progress,errorMessage,currentFilePath,outputPath,currentIndex,totalFiles,completedCount,const DeepCollectionEquality().hash(failures));

@override
String toString() {
  return 'VideoEncodeState(status: $status, progress: $progress, errorMessage: $errorMessage, currentFilePath: $currentFilePath, outputPath: $outputPath, currentIndex: $currentIndex, totalFiles: $totalFiles, completedCount: $completedCount, failures: $failures)';
}


}

/// @nodoc
abstract mixin class $VideoEncodeStateCopyWith<$Res>  {
  factory $VideoEncodeStateCopyWith(VideoEncodeState value, $Res Function(VideoEncodeState) _then) = _$VideoEncodeStateCopyWithImpl;
@useResult
$Res call({
 EncodeStatus status, EncodeProgress progress, String? errorMessage, String? currentFilePath, String? outputPath, int currentIndex, int totalFiles, int completedCount, List<EncodeFailure> failures
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
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? progress = null,Object? errorMessage = freezed,Object? currentFilePath = freezed,Object? outputPath = freezed,Object? currentIndex = null,Object? totalFiles = null,Object? completedCount = null,Object? failures = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EncodeStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EncodeProgress,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,currentFilePath: freezed == currentFilePath ? _self.currentFilePath : currentFilePath // ignore: cast_nullable_to_non_nullable
as String?,outputPath: freezed == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self.failures : failures // ignore: cast_nullable_to_non_nullable
as List<EncodeFailure>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EncodeStatus status,  EncodeProgress progress,  String? errorMessage,  String? currentFilePath,  String? outputPath,  int currentIndex,  int totalFiles,  int completedCount,  List<EncodeFailure> failures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
return $default(_that.status,_that.progress,_that.errorMessage,_that.currentFilePath,_that.outputPath,_that.currentIndex,_that.totalFiles,_that.completedCount,_that.failures);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EncodeStatus status,  EncodeProgress progress,  String? errorMessage,  String? currentFilePath,  String? outputPath,  int currentIndex,  int totalFiles,  int completedCount,  List<EncodeFailure> failures)  $default,) {final _that = this;
switch (_that) {
case _VideoEncodeState():
return $default(_that.status,_that.progress,_that.errorMessage,_that.currentFilePath,_that.outputPath,_that.currentIndex,_that.totalFiles,_that.completedCount,_that.failures);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EncodeStatus status,  EncodeProgress progress,  String? errorMessage,  String? currentFilePath,  String? outputPath,  int currentIndex,  int totalFiles,  int completedCount,  List<EncodeFailure> failures)?  $default,) {final _that = this;
switch (_that) {
case _VideoEncodeState() when $default != null:
return $default(_that.status,_that.progress,_that.errorMessage,_that.currentFilePath,_that.outputPath,_that.currentIndex,_that.totalFiles,_that.completedCount,_that.failures);case _:
  return null;

}
}

}

/// @nodoc


class _VideoEncodeState extends VideoEncodeState {
  const _VideoEncodeState({this.status = EncodeStatus.idle, this.progress = const EncodeProgress(), this.errorMessage, this.currentFilePath, this.outputPath, this.currentIndex = 0, this.totalFiles = 0, this.completedCount = 0, final  List<EncodeFailure> failures = const []}): _failures = failures,super._();
  

@override@JsonKey() final  EncodeStatus status;
@override@JsonKey() final  EncodeProgress progress;
@override final  String? errorMessage;
@override final  String? currentFilePath;
@override final  String? outputPath;
@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  int totalFiles;
@override@JsonKey() final  int completedCount;
 final  List<EncodeFailure> _failures;
@override@JsonKey() List<EncodeFailure> get failures {
  if (_failures is EqualUnmodifiableListView) return _failures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failures);
}


/// Create a copy of VideoEncodeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoEncodeStateCopyWith<_VideoEncodeState> get copyWith => __$VideoEncodeStateCopyWithImpl<_VideoEncodeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoEncodeState&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.currentFilePath, currentFilePath) || other.currentFilePath == currentFilePath)&&(identical(other.outputPath, outputPath) || other.outputPath == outputPath)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.totalFiles, totalFiles) || other.totalFiles == totalFiles)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&const DeepCollectionEquality().equals(other._failures, _failures));
}


@override
int get hashCode => Object.hash(runtimeType,status,progress,errorMessage,currentFilePath,outputPath,currentIndex,totalFiles,completedCount,const DeepCollectionEquality().hash(_failures));

@override
String toString() {
  return 'VideoEncodeState(status: $status, progress: $progress, errorMessage: $errorMessage, currentFilePath: $currentFilePath, outputPath: $outputPath, currentIndex: $currentIndex, totalFiles: $totalFiles, completedCount: $completedCount, failures: $failures)';
}


}

/// @nodoc
abstract mixin class _$VideoEncodeStateCopyWith<$Res> implements $VideoEncodeStateCopyWith<$Res> {
  factory _$VideoEncodeStateCopyWith(_VideoEncodeState value, $Res Function(_VideoEncodeState) _then) = __$VideoEncodeStateCopyWithImpl;
@override @useResult
$Res call({
 EncodeStatus status, EncodeProgress progress, String? errorMessage, String? currentFilePath, String? outputPath, int currentIndex, int totalFiles, int completedCount, List<EncodeFailure> failures
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
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? progress = null,Object? errorMessage = freezed,Object? currentFilePath = freezed,Object? outputPath = freezed,Object? currentIndex = null,Object? totalFiles = null,Object? completedCount = null,Object? failures = null,}) {
  return _then(_VideoEncodeState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EncodeStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as EncodeProgress,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,currentFilePath: freezed == currentFilePath ? _self.currentFilePath : currentFilePath // ignore: cast_nullable_to_non_nullable
as String?,outputPath: freezed == outputPath ? _self.outputPath : outputPath // ignore: cast_nullable_to_non_nullable
as String?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,totalFiles: null == totalFiles ? _self.totalFiles : totalFiles // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,failures: null == failures ? _self._failures : failures // ignore: cast_nullable_to_non_nullable
as List<EncodeFailure>,
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
