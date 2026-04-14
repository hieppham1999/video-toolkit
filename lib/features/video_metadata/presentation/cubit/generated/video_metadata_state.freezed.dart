// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../video_metadata_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VideoMetadataState {

 Map<String, VideoMetadata> get metadataByPath; Set<String> get loadingPaths; bool get isExiftoolAvailable; bool get isFfprobeAvailable;
/// Create a copy of VideoMetadataState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoMetadataStateCopyWith<VideoMetadataState> get copyWith => _$VideoMetadataStateCopyWithImpl<VideoMetadataState>(this as VideoMetadataState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoMetadataState&&const DeepCollectionEquality().equals(other.metadataByPath, metadataByPath)&&const DeepCollectionEquality().equals(other.loadingPaths, loadingPaths)&&(identical(other.isExiftoolAvailable, isExiftoolAvailable) || other.isExiftoolAvailable == isExiftoolAvailable)&&(identical(other.isFfprobeAvailable, isFfprobeAvailable) || other.isFfprobeAvailable == isFfprobeAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(metadataByPath),const DeepCollectionEquality().hash(loadingPaths),isExiftoolAvailable,isFfprobeAvailable);

@override
String toString() {
  return 'VideoMetadataState(metadataByPath: $metadataByPath, loadingPaths: $loadingPaths, isExiftoolAvailable: $isExiftoolAvailable, isFfprobeAvailable: $isFfprobeAvailable)';
}


}

/// @nodoc
abstract mixin class $VideoMetadataStateCopyWith<$Res>  {
  factory $VideoMetadataStateCopyWith(VideoMetadataState value, $Res Function(VideoMetadataState) _then) = _$VideoMetadataStateCopyWithImpl;
@useResult
$Res call({
 Map<String, VideoMetadata> metadataByPath, Set<String> loadingPaths, bool isExiftoolAvailable, bool isFfprobeAvailable
});




}
/// @nodoc
class _$VideoMetadataStateCopyWithImpl<$Res>
    implements $VideoMetadataStateCopyWith<$Res> {
  _$VideoMetadataStateCopyWithImpl(this._self, this._then);

  final VideoMetadataState _self;
  final $Res Function(VideoMetadataState) _then;

/// Create a copy of VideoMetadataState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metadataByPath = null,Object? loadingPaths = null,Object? isExiftoolAvailable = null,Object? isFfprobeAvailable = null,}) {
  return _then(_self.copyWith(
metadataByPath: null == metadataByPath ? _self.metadataByPath : metadataByPath // ignore: cast_nullable_to_non_nullable
as Map<String, VideoMetadata>,loadingPaths: null == loadingPaths ? _self.loadingPaths : loadingPaths // ignore: cast_nullable_to_non_nullable
as Set<String>,isExiftoolAvailable: null == isExiftoolAvailable ? _self.isExiftoolAvailable : isExiftoolAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFfprobeAvailable: null == isFfprobeAvailable ? _self.isFfprobeAvailable : isFfprobeAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoMetadataState].
extension VideoMetadataStatePatterns on VideoMetadataState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoMetadataState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoMetadataState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoMetadataState value)  $default,){
final _that = this;
switch (_that) {
case _VideoMetadataState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoMetadataState value)?  $default,){
final _that = this;
switch (_that) {
case _VideoMetadataState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, VideoMetadata> metadataByPath,  Set<String> loadingPaths,  bool isExiftoolAvailable,  bool isFfprobeAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoMetadataState() when $default != null:
return $default(_that.metadataByPath,_that.loadingPaths,_that.isExiftoolAvailable,_that.isFfprobeAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, VideoMetadata> metadataByPath,  Set<String> loadingPaths,  bool isExiftoolAvailable,  bool isFfprobeAvailable)  $default,) {final _that = this;
switch (_that) {
case _VideoMetadataState():
return $default(_that.metadataByPath,_that.loadingPaths,_that.isExiftoolAvailable,_that.isFfprobeAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, VideoMetadata> metadataByPath,  Set<String> loadingPaths,  bool isExiftoolAvailable,  bool isFfprobeAvailable)?  $default,) {final _that = this;
switch (_that) {
case _VideoMetadataState() when $default != null:
return $default(_that.metadataByPath,_that.loadingPaths,_that.isExiftoolAvailable,_that.isFfprobeAvailable);case _:
  return null;

}
}

}

/// @nodoc


class _VideoMetadataState implements VideoMetadataState {
  const _VideoMetadataState({final  Map<String, VideoMetadata> metadataByPath = const {}, final  Set<String> loadingPaths = const {}, this.isExiftoolAvailable = true, this.isFfprobeAvailable = true}): _metadataByPath = metadataByPath,_loadingPaths = loadingPaths;
  

 final  Map<String, VideoMetadata> _metadataByPath;
@override@JsonKey() Map<String, VideoMetadata> get metadataByPath {
  if (_metadataByPath is EqualUnmodifiableMapView) return _metadataByPath;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadataByPath);
}

 final  Set<String> _loadingPaths;
@override@JsonKey() Set<String> get loadingPaths {
  if (_loadingPaths is EqualUnmodifiableSetView) return _loadingPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_loadingPaths);
}

@override@JsonKey() final  bool isExiftoolAvailable;
@override@JsonKey() final  bool isFfprobeAvailable;

/// Create a copy of VideoMetadataState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoMetadataStateCopyWith<_VideoMetadataState> get copyWith => __$VideoMetadataStateCopyWithImpl<_VideoMetadataState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoMetadataState&&const DeepCollectionEquality().equals(other._metadataByPath, _metadataByPath)&&const DeepCollectionEquality().equals(other._loadingPaths, _loadingPaths)&&(identical(other.isExiftoolAvailable, isExiftoolAvailable) || other.isExiftoolAvailable == isExiftoolAvailable)&&(identical(other.isFfprobeAvailable, isFfprobeAvailable) || other.isFfprobeAvailable == isFfprobeAvailable));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_metadataByPath),const DeepCollectionEquality().hash(_loadingPaths),isExiftoolAvailable,isFfprobeAvailable);

@override
String toString() {
  return 'VideoMetadataState(metadataByPath: $metadataByPath, loadingPaths: $loadingPaths, isExiftoolAvailable: $isExiftoolAvailable, isFfprobeAvailable: $isFfprobeAvailable)';
}


}

/// @nodoc
abstract mixin class _$VideoMetadataStateCopyWith<$Res> implements $VideoMetadataStateCopyWith<$Res> {
  factory _$VideoMetadataStateCopyWith(_VideoMetadataState value, $Res Function(_VideoMetadataState) _then) = __$VideoMetadataStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, VideoMetadata> metadataByPath, Set<String> loadingPaths, bool isExiftoolAvailable, bool isFfprobeAvailable
});




}
/// @nodoc
class __$VideoMetadataStateCopyWithImpl<$Res>
    implements _$VideoMetadataStateCopyWith<$Res> {
  __$VideoMetadataStateCopyWithImpl(this._self, this._then);

  final _VideoMetadataState _self;
  final $Res Function(_VideoMetadataState) _then;

/// Create a copy of VideoMetadataState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metadataByPath = null,Object? loadingPaths = null,Object? isExiftoolAvailable = null,Object? isFfprobeAvailable = null,}) {
  return _then(_VideoMetadataState(
metadataByPath: null == metadataByPath ? _self._metadataByPath : metadataByPath // ignore: cast_nullable_to_non_nullable
as Map<String, VideoMetadata>,loadingPaths: null == loadingPaths ? _self._loadingPaths : loadingPaths // ignore: cast_nullable_to_non_nullable
as Set<String>,isExiftoolAvailable: null == isExiftoolAvailable ? _self.isExiftoolAvailable : isExiftoolAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFfprobeAvailable: null == isFfprobeAvailable ? _self.isFfprobeAvailable : isFfprobeAvailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
