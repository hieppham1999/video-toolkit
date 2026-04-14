// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_import_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoImportState {

 List<VideoFile> get files; bool get isDragging;
/// Create a copy of VideoImportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoImportStateCopyWith<VideoImportState> get copyWith => _$VideoImportStateCopyWithImpl<VideoImportState>(this as VideoImportState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoImportState&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.isDragging, isDragging) || other.isDragging == isDragging));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(files),isDragging);

@override
String toString() {
  return 'VideoImportState(files: $files, isDragging: $isDragging)';
}


}

/// @nodoc
abstract mixin class $VideoImportStateCopyWith<$Res>  {
  factory $VideoImportStateCopyWith(VideoImportState value, $Res Function(VideoImportState) _then) = _$VideoImportStateCopyWithImpl;
@useResult
$Res call({
 List<VideoFile> files, bool isDragging
});




}
/// @nodoc
class _$VideoImportStateCopyWithImpl<$Res>
    implements $VideoImportStateCopyWith<$Res> {
  _$VideoImportStateCopyWithImpl(this._self, this._then);

  final VideoImportState _self;
  final $Res Function(VideoImportState) _then;

/// Create a copy of VideoImportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? files = null,Object? isDragging = null,}) {
  return _then(_self.copyWith(
files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<VideoFile>,isDragging: null == isDragging ? _self.isDragging : isDragging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoImportState].
extension VideoImportStatePatterns on VideoImportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoImportState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoImportState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoImportState value)  $default,){
final _that = this;
switch (_that) {
case _VideoImportState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoImportState value)?  $default,){
final _that = this;
switch (_that) {
case _VideoImportState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VideoFile> files,  bool isDragging)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoImportState() when $default != null:
return $default(_that.files,_that.isDragging);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VideoFile> files,  bool isDragging)  $default,) {final _that = this;
switch (_that) {
case _VideoImportState():
return $default(_that.files,_that.isDragging);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VideoFile> files,  bool isDragging)?  $default,) {final _that = this;
switch (_that) {
case _VideoImportState() when $default != null:
return $default(_that.files,_that.isDragging);case _:
  return null;

}
}

}

/// @nodoc


class _VideoImportState implements VideoImportState {
  const _VideoImportState({final  List<VideoFile> files = const [], this.isDragging = false}): _files = files;
  

 final  List<VideoFile> _files;
@override@JsonKey() List<VideoFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override@JsonKey() final  bool isDragging;

/// Create a copy of VideoImportState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoImportStateCopyWith<_VideoImportState> get copyWith => __$VideoImportStateCopyWithImpl<_VideoImportState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoImportState&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.isDragging, isDragging) || other.isDragging == isDragging));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_files),isDragging);

@override
String toString() {
  return 'VideoImportState(files: $files, isDragging: $isDragging)';
}


}

/// @nodoc
abstract mixin class _$VideoImportStateCopyWith<$Res> implements $VideoImportStateCopyWith<$Res> {
  factory _$VideoImportStateCopyWith(_VideoImportState value, $Res Function(_VideoImportState) _then) = __$VideoImportStateCopyWithImpl;
@override @useResult
$Res call({
 List<VideoFile> files, bool isDragging
});




}
/// @nodoc
class __$VideoImportStateCopyWithImpl<$Res>
    implements _$VideoImportStateCopyWith<$Res> {
  __$VideoImportStateCopyWithImpl(this._self, this._then);

  final _VideoImportState _self;
  final $Res Function(_VideoImportState) _then;

/// Create a copy of VideoImportState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? files = null,Object? isDragging = null,}) {
  return _then(_VideoImportState(
files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<VideoFile>,isDragging: null == isDragging ? _self.isDragging : isDragging // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
