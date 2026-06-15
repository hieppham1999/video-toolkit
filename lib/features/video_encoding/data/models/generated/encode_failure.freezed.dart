// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../encode_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EncodeFailure {

 String get filePath; String get message;
/// Create a copy of EncodeFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncodeFailureCopyWith<EncodeFailure> get copyWith => _$EncodeFailureCopyWithImpl<EncodeFailure>(this as EncodeFailure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncodeFailure&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,message);

@override
String toString() {
  return 'EncodeFailure(filePath: $filePath, message: $message)';
}


}

/// @nodoc
abstract mixin class $EncodeFailureCopyWith<$Res>  {
  factory $EncodeFailureCopyWith(EncodeFailure value, $Res Function(EncodeFailure) _then) = _$EncodeFailureCopyWithImpl;
@useResult
$Res call({
 String filePath, String message
});




}
/// @nodoc
class _$EncodeFailureCopyWithImpl<$Res>
    implements $EncodeFailureCopyWith<$Res> {
  _$EncodeFailureCopyWithImpl(this._self, this._then);

  final EncodeFailure _self;
  final $Res Function(EncodeFailure) _then;

/// Create a copy of EncodeFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? message = null,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EncodeFailure].
extension EncodeFailurePatterns on EncodeFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncodeFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncodeFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncodeFailure value)  $default,){
final _that = this;
switch (_that) {
case _EncodeFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncodeFailure value)?  $default,){
final _that = this;
switch (_that) {
case _EncodeFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncodeFailure() when $default != null:
return $default(_that.filePath,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath,  String message)  $default,) {final _that = this;
switch (_that) {
case _EncodeFailure():
return $default(_that.filePath,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath,  String message)?  $default,) {final _that = this;
switch (_that) {
case _EncodeFailure() when $default != null:
return $default(_that.filePath,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _EncodeFailure implements EncodeFailure {
  const _EncodeFailure({required this.filePath, required this.message});
  

@override final  String filePath;
@override final  String message;

/// Create a copy of EncodeFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncodeFailureCopyWith<_EncodeFailure> get copyWith => __$EncodeFailureCopyWithImpl<_EncodeFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncodeFailure&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,filePath,message);

@override
String toString() {
  return 'EncodeFailure(filePath: $filePath, message: $message)';
}


}

/// @nodoc
abstract mixin class _$EncodeFailureCopyWith<$Res> implements $EncodeFailureCopyWith<$Res> {
  factory _$EncodeFailureCopyWith(_EncodeFailure value, $Res Function(_EncodeFailure) _then) = __$EncodeFailureCopyWithImpl;
@override @useResult
$Res call({
 String filePath, String message
});




}
/// @nodoc
class __$EncodeFailureCopyWithImpl<$Res>
    implements _$EncodeFailureCopyWith<$Res> {
  __$EncodeFailureCopyWithImpl(this._self, this._then);

  final _EncodeFailure _self;
  final $Res Function(_EncodeFailure) _then;

/// Create a copy of EncodeFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? message = null,}) {
  return _then(_EncodeFailure(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
