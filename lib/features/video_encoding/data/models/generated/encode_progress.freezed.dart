// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../encode_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncodeProgress {

 double get percent; Duration get elapsed; Duration? get estimatedRemaining; double get fps; double get speed;
/// Create a copy of EncodeProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncodeProgressCopyWith<EncodeProgress> get copyWith => _$EncodeProgressCopyWithImpl<EncodeProgress>(this as EncodeProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncodeProgress&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&(identical(other.estimatedRemaining, estimatedRemaining) || other.estimatedRemaining == estimatedRemaining)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.speed, speed) || other.speed == speed));
}


@override
int get hashCode => Object.hash(runtimeType,percent,elapsed,estimatedRemaining,fps,speed);

@override
String toString() {
  return 'EncodeProgress(percent: $percent, elapsed: $elapsed, estimatedRemaining: $estimatedRemaining, fps: $fps, speed: $speed)';
}


}

/// @nodoc
abstract mixin class $EncodeProgressCopyWith<$Res>  {
  factory $EncodeProgressCopyWith(EncodeProgress value, $Res Function(EncodeProgress) _then) = _$EncodeProgressCopyWithImpl;
@useResult
$Res call({
 double percent, Duration elapsed, Duration? estimatedRemaining, double fps, double speed
});




}
/// @nodoc
class _$EncodeProgressCopyWithImpl<$Res>
    implements $EncodeProgressCopyWith<$Res> {
  _$EncodeProgressCopyWithImpl(this._self, this._then);

  final EncodeProgress _self;
  final $Res Function(EncodeProgress) _then;

/// Create a copy of EncodeProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? percent = null,Object? elapsed = null,Object? estimatedRemaining = freezed,Object? fps = null,Object? speed = null,}) {
  return _then(_self.copyWith(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,estimatedRemaining: freezed == estimatedRemaining ? _self.estimatedRemaining : estimatedRemaining // ignore: cast_nullable_to_non_nullable
as Duration?,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EncodeProgress].
extension EncodeProgressPatterns on EncodeProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncodeProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncodeProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncodeProgress value)  $default,){
final _that = this;
switch (_that) {
case _EncodeProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncodeProgress value)?  $default,){
final _that = this;
switch (_that) {
case _EncodeProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double percent,  Duration elapsed,  Duration? estimatedRemaining,  double fps,  double speed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncodeProgress() when $default != null:
return $default(_that.percent,_that.elapsed,_that.estimatedRemaining,_that.fps,_that.speed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double percent,  Duration elapsed,  Duration? estimatedRemaining,  double fps,  double speed)  $default,) {final _that = this;
switch (_that) {
case _EncodeProgress():
return $default(_that.percent,_that.elapsed,_that.estimatedRemaining,_that.fps,_that.speed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double percent,  Duration elapsed,  Duration? estimatedRemaining,  double fps,  double speed)?  $default,) {final _that = this;
switch (_that) {
case _EncodeProgress() when $default != null:
return $default(_that.percent,_that.elapsed,_that.estimatedRemaining,_that.fps,_that.speed);case _:
  return null;

}
}

}

/// @nodoc


class _EncodeProgress implements EncodeProgress {
  const _EncodeProgress({this.percent = 0, this.elapsed = Duration.zero, this.estimatedRemaining, this.fps = 0, this.speed = 0});
  

@override@JsonKey() final  double percent;
@override@JsonKey() final  Duration elapsed;
@override final  Duration? estimatedRemaining;
@override@JsonKey() final  double fps;
@override@JsonKey() final  double speed;

/// Create a copy of EncodeProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncodeProgressCopyWith<_EncodeProgress> get copyWith => __$EncodeProgressCopyWithImpl<_EncodeProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncodeProgress&&(identical(other.percent, percent) || other.percent == percent)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&(identical(other.estimatedRemaining, estimatedRemaining) || other.estimatedRemaining == estimatedRemaining)&&(identical(other.fps, fps) || other.fps == fps)&&(identical(other.speed, speed) || other.speed == speed));
}


@override
int get hashCode => Object.hash(runtimeType,percent,elapsed,estimatedRemaining,fps,speed);

@override
String toString() {
  return 'EncodeProgress(percent: $percent, elapsed: $elapsed, estimatedRemaining: $estimatedRemaining, fps: $fps, speed: $speed)';
}


}

/// @nodoc
abstract mixin class _$EncodeProgressCopyWith<$Res> implements $EncodeProgressCopyWith<$Res> {
  factory _$EncodeProgressCopyWith(_EncodeProgress value, $Res Function(_EncodeProgress) _then) = __$EncodeProgressCopyWithImpl;
@override @useResult
$Res call({
 double percent, Duration elapsed, Duration? estimatedRemaining, double fps, double speed
});




}
/// @nodoc
class __$EncodeProgressCopyWithImpl<$Res>
    implements _$EncodeProgressCopyWith<$Res> {
  __$EncodeProgressCopyWithImpl(this._self, this._then);

  final _EncodeProgress _self;
  final $Res Function(_EncodeProgress) _then;

/// Create a copy of EncodeProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? percent = null,Object? elapsed = null,Object? estimatedRemaining = freezed,Object? fps = null,Object? speed = null,}) {
  return _then(_EncodeProgress(
percent: null == percent ? _self.percent : percent // ignore: cast_nullable_to_non_nullable
as double,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,estimatedRemaining: freezed == estimatedRemaining ? _self.estimatedRemaining : estimatedRemaining // ignore: cast_nullable_to_non_nullable
as Duration?,fps: null == fps ? _self.fps : fps // ignore: cast_nullable_to_non_nullable
as double,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
