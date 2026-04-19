// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../font_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FontInfo {

 String get name; String get path; bool get isBundled;
/// Create a copy of FontInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FontInfoCopyWith<FontInfo> get copyWith => _$FontInfoCopyWithImpl<FontInfo>(this as FontInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FontInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isBundled, isBundled) || other.isBundled == isBundled));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,isBundled);

@override
String toString() {
  return 'FontInfo(name: $name, path: $path, isBundled: $isBundled)';
}


}

/// @nodoc
abstract mixin class $FontInfoCopyWith<$Res>  {
  factory $FontInfoCopyWith(FontInfo value, $Res Function(FontInfo) _then) = _$FontInfoCopyWithImpl;
@useResult
$Res call({
 String name, String path, bool isBundled
});




}
/// @nodoc
class _$FontInfoCopyWithImpl<$Res>
    implements $FontInfoCopyWith<$Res> {
  _$FontInfoCopyWithImpl(this._self, this._then);

  final FontInfo _self;
  final $Res Function(FontInfo) _then;

/// Create a copy of FontInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? path = null,Object? isBundled = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isBundled: null == isBundled ? _self.isBundled : isBundled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FontInfo].
extension FontInfoPatterns on FontInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FontInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FontInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FontInfo value)  $default,){
final _that = this;
switch (_that) {
case _FontInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FontInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FontInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String path,  bool isBundled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FontInfo() when $default != null:
return $default(_that.name,_that.path,_that.isBundled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String path,  bool isBundled)  $default,) {final _that = this;
switch (_that) {
case _FontInfo():
return $default(_that.name,_that.path,_that.isBundled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String path,  bool isBundled)?  $default,) {final _that = this;
switch (_that) {
case _FontInfo() when $default != null:
return $default(_that.name,_that.path,_that.isBundled);case _:
  return null;

}
}

}

/// @nodoc


class _FontInfo implements FontInfo {
  const _FontInfo({required this.name, required this.path, this.isBundled = false});
  

@override final  String name;
@override final  String path;
@override@JsonKey() final  bool isBundled;

/// Create a copy of FontInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FontInfoCopyWith<_FontInfo> get copyWith => __$FontInfoCopyWithImpl<_FontInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FontInfo&&(identical(other.name, name) || other.name == name)&&(identical(other.path, path) || other.path == path)&&(identical(other.isBundled, isBundled) || other.isBundled == isBundled));
}


@override
int get hashCode => Object.hash(runtimeType,name,path,isBundled);

@override
String toString() {
  return 'FontInfo(name: $name, path: $path, isBundled: $isBundled)';
}


}

/// @nodoc
abstract mixin class _$FontInfoCopyWith<$Res> implements $FontInfoCopyWith<$Res> {
  factory _$FontInfoCopyWith(_FontInfo value, $Res Function(_FontInfo) _then) = __$FontInfoCopyWithImpl;
@override @useResult
$Res call({
 String name, String path, bool isBundled
});




}
/// @nodoc
class __$FontInfoCopyWithImpl<$Res>
    implements _$FontInfoCopyWith<$Res> {
  __$FontInfoCopyWithImpl(this._self, this._then);

  final _FontInfo _self;
  final $Res Function(_FontInfo) _then;

/// Create a copy of FontInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? path = null,Object? isBundled = null,}) {
  return _then(_FontInfo(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,isBundled: null == isBundled ? _self.isBundled : isBundled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
