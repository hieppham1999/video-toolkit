// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../preview_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreviewState {

 String? get framePath; int get frameRevision; bool get isLoading; bool get isLive; String? get errorMessage;
/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreviewStateCopyWith<PreviewState> get copyWith => _$PreviewStateCopyWithImpl<PreviewState>(this as PreviewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreviewState&&(identical(other.framePath, framePath) || other.framePath == framePath)&&(identical(other.frameRevision, frameRevision) || other.frameRevision == frameRevision)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,framePath,frameRevision,isLoading,isLive,errorMessage);

@override
String toString() {
  return 'PreviewState(framePath: $framePath, frameRevision: $frameRevision, isLoading: $isLoading, isLive: $isLive, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $PreviewStateCopyWith<$Res>  {
  factory $PreviewStateCopyWith(PreviewState value, $Res Function(PreviewState) _then) = _$PreviewStateCopyWithImpl;
@useResult
$Res call({
 String? framePath, int frameRevision, bool isLoading, bool isLive, String? errorMessage
});




}
/// @nodoc
class _$PreviewStateCopyWithImpl<$Res>
    implements $PreviewStateCopyWith<$Res> {
  _$PreviewStateCopyWithImpl(this._self, this._then);

  final PreviewState _self;
  final $Res Function(PreviewState) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? framePath = freezed,Object? frameRevision = null,Object? isLoading = null,Object? isLive = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
framePath: freezed == framePath ? _self.framePath : framePath // ignore: cast_nullable_to_non_nullable
as String?,frameRevision: null == frameRevision ? _self.frameRevision : frameRevision // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PreviewState].
extension PreviewStatePatterns on PreviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreviewState value)  $default,){
final _that = this;
switch (_that) {
case _PreviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreviewState value)?  $default,){
final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? framePath,  int frameRevision,  bool isLoading,  bool isLive,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
return $default(_that.framePath,_that.frameRevision,_that.isLoading,_that.isLive,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? framePath,  int frameRevision,  bool isLoading,  bool isLive,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _PreviewState():
return $default(_that.framePath,_that.frameRevision,_that.isLoading,_that.isLive,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? framePath,  int frameRevision,  bool isLoading,  bool isLive,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _PreviewState() when $default != null:
return $default(_that.framePath,_that.frameRevision,_that.isLoading,_that.isLive,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PreviewState implements PreviewState {
  const _PreviewState({this.framePath, this.frameRevision = 0, this.isLoading = false, this.isLive = false, this.errorMessage});
  

@override final  String? framePath;
@override@JsonKey() final  int frameRevision;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLive;
@override final  String? errorMessage;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreviewStateCopyWith<_PreviewState> get copyWith => __$PreviewStateCopyWithImpl<_PreviewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviewState&&(identical(other.framePath, framePath) || other.framePath == framePath)&&(identical(other.frameRevision, frameRevision) || other.frameRevision == frameRevision)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,framePath,frameRevision,isLoading,isLive,errorMessage);

@override
String toString() {
  return 'PreviewState(framePath: $framePath, frameRevision: $frameRevision, isLoading: $isLoading, isLive: $isLive, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$PreviewStateCopyWith<$Res> implements $PreviewStateCopyWith<$Res> {
  factory _$PreviewStateCopyWith(_PreviewState value, $Res Function(_PreviewState) _then) = __$PreviewStateCopyWithImpl;
@override @useResult
$Res call({
 String? framePath, int frameRevision, bool isLoading, bool isLive, String? errorMessage
});




}
/// @nodoc
class __$PreviewStateCopyWithImpl<$Res>
    implements _$PreviewStateCopyWith<$Res> {
  __$PreviewStateCopyWithImpl(this._self, this._then);

  final _PreviewState _self;
  final $Res Function(_PreviewState) _then;

/// Create a copy of PreviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? framePath = freezed,Object? frameRevision = null,Object? isLoading = null,Object? isLive = null,Object? errorMessage = freezed,}) {
  return _then(_PreviewState(
framePath: freezed == framePath ? _self.framePath : framePath // ignore: cast_nullable_to_non_nullable
as String?,frameRevision: null == frameRevision ? _self.frameRevision : frameRevision // ignore: cast_nullable_to_non_nullable
as int,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
