// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../cli_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CliResult {

 String get stdout; String get stderr; int get exitCode;
/// Create a copy of CliResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CliResultCopyWith<CliResult> get copyWith => _$CliResultCopyWithImpl<CliResult>(this as CliResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CliResult&&(identical(other.stdout, stdout) || other.stdout == stdout)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,stdout,stderr,exitCode);

@override
String toString() {
  return 'CliResult(stdout: $stdout, stderr: $stderr, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class $CliResultCopyWith<$Res>  {
  factory $CliResultCopyWith(CliResult value, $Res Function(CliResult) _then) = _$CliResultCopyWithImpl;
@useResult
$Res call({
 String stdout, String stderr, int exitCode
});




}
/// @nodoc
class _$CliResultCopyWithImpl<$Res>
    implements $CliResultCopyWith<$Res> {
  _$CliResultCopyWithImpl(this._self, this._then);

  final CliResult _self;
  final $Res Function(CliResult) _then;

/// Create a copy of CliResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stdout = null,Object? stderr = null,Object? exitCode = null,}) {
  return _then(_self.copyWith(
stdout: null == stdout ? _self.stdout : stdout // ignore: cast_nullable_to_non_nullable
as String,stderr: null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,exitCode: null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CliResult].
extension CliResultPatterns on CliResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CliResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CliResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CliResult value)  $default,){
final _that = this;
switch (_that) {
case _CliResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CliResult value)?  $default,){
final _that = this;
switch (_that) {
case _CliResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stdout,  String stderr,  int exitCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CliResult() when $default != null:
return $default(_that.stdout,_that.stderr,_that.exitCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stdout,  String stderr,  int exitCode)  $default,) {final _that = this;
switch (_that) {
case _CliResult():
return $default(_that.stdout,_that.stderr,_that.exitCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stdout,  String stderr,  int exitCode)?  $default,) {final _that = this;
switch (_that) {
case _CliResult() when $default != null:
return $default(_that.stdout,_that.stderr,_that.exitCode);case _:
  return null;

}
}

}

/// @nodoc


class _CliResult extends CliResult {
  const _CliResult({required this.stdout, required this.stderr, required this.exitCode}): super._();
  

@override final  String stdout;
@override final  String stderr;
@override final  int exitCode;

/// Create a copy of CliResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CliResultCopyWith<_CliResult> get copyWith => __$CliResultCopyWithImpl<_CliResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CliResult&&(identical(other.stdout, stdout) || other.stdout == stdout)&&(identical(other.stderr, stderr) || other.stderr == stderr)&&(identical(other.exitCode, exitCode) || other.exitCode == exitCode));
}


@override
int get hashCode => Object.hash(runtimeType,stdout,stderr,exitCode);

@override
String toString() {
  return 'CliResult(stdout: $stdout, stderr: $stderr, exitCode: $exitCode)';
}


}

/// @nodoc
abstract mixin class _$CliResultCopyWith<$Res> implements $CliResultCopyWith<$Res> {
  factory _$CliResultCopyWith(_CliResult value, $Res Function(_CliResult) _then) = __$CliResultCopyWithImpl;
@override @useResult
$Res call({
 String stdout, String stderr, int exitCode
});




}
/// @nodoc
class __$CliResultCopyWithImpl<$Res>
    implements _$CliResultCopyWith<$Res> {
  __$CliResultCopyWithImpl(this._self, this._then);

  final _CliResult _self;
  final $Res Function(_CliResult) _then;

/// Create a copy of CliResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stdout = null,Object? stderr = null,Object? exitCode = null,}) {
  return _then(_CliResult(
stdout: null == stdout ? _self.stdout : stdout // ignore: cast_nullable_to_non_nullable
as String,stderr: null == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String,exitCode: null == exitCode ? _self.exitCode : exitCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
