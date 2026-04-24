// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../font_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FontState {

 List<FontInfo> get fonts; bool get isLoading;
/// Create a copy of FontState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontStateCopyWith<FontState> get copyWith => _$FontStateCopyWithImpl<FontState>(this as FontState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontState&&const DeepCollectionEquality().equals(other.fonts, fonts)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(fonts),isLoading);

@override
String toString() {
  return 'FontState(fonts: $fonts, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $FontStateCopyWith<$Res>  {
  factory $FontStateCopyWith(FontState value, $Res Function(FontState) _then) = _$FontStateCopyWithImpl;
@useResult
$Res call({
 List<FontInfo> fonts, bool isLoading
});




}
/// @nodoc
class _$FontStateCopyWithImpl<$Res>
    implements $FontStateCopyWith<$Res> {
  _$FontStateCopyWithImpl(this._self, this._then);

  final FontState _self;
  final $Res Function(FontState) _then;

/// Create a copy of FontState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fonts = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
fonts: null == fonts ? _self.fonts : fonts // ignore: cast_nullable_to_non_nullable
as List<FontInfo>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FontState].
extension FontStatePatterns on FontState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FontState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FontState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FontState value)  $default,){
final _that = this;
switch (_that) {
case _FontState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FontState value)?  $default,){
final _that = this;
switch (_that) {
case _FontState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FontInfo> fonts,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FontState() when $default != null:
return $default(_that.fonts,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FontInfo> fonts,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _FontState():
return $default(_that.fonts,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FontInfo> fonts,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _FontState() when $default != null:
return $default(_that.fonts,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _FontState implements FontState {
  const _FontState({final  List<FontInfo> fonts = const [], this.isLoading = false}): _fonts = fonts;
  

 final  List<FontInfo> _fonts;
@override@JsonKey() List<FontInfo> get fonts {
  if (_fonts is EqualUnmodifiableListView) return _fonts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fonts);
}

@override@JsonKey() final  bool isLoading;

/// Create a copy of FontState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FontStateCopyWith<_FontState> get copyWith => __$FontStateCopyWithImpl<_FontState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontState&&const DeepCollectionEquality().equals(other._fonts, _fonts)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_fonts),isLoading);

@override
String toString() {
  return 'FontState(fonts: $fonts, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$FontStateCopyWith<$Res> implements $FontStateCopyWith<$Res> {
  factory _$FontStateCopyWith(_FontState value, $Res Function(_FontState) _then) = __$FontStateCopyWithImpl;
@override @useResult
$Res call({
 List<FontInfo> fonts, bool isLoading
});




}
/// @nodoc
class __$FontStateCopyWithImpl<$Res>
    implements _$FontStateCopyWith<$Res> {
  __$FontStateCopyWithImpl(this._self, this._then);

  final _FontState _self;
  final $Res Function(_FontState) _then;

/// Create a copy of FontState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fonts = null,Object? isLoading = null,}) {
  return _then(_FontState(
fonts: null == fonts ? _self._fonts : fonts // ignore: cast_nullable_to_non_nullable
as List<FontInfo>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
