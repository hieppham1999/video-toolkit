import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/app_state.freezed.dart';

@freezed
sealed class CubitState<T> with _$CubitState<T> {
  const factory CubitState.normal(T data) = NormalState<T>;
  const factory CubitState.loading(T data) = LoadingState<T>;
  const factory CubitState.error({
    required String message,
    required T data,
  }) = ErrorState<T>;
}
