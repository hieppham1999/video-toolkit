import 'package:video_toolkit/presentation/base/app_state.dart';
import 'package:video_toolkit/presentation/widgets/loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseCubit<T> extends Cubit<CubitState<T>> {
  BaseCubit.normal(T initialState) : super(CubitState.normal(initialState));

  BaseCubit.loading(T initialState) : super(CubitState.loading(initialState));

  BaseCubit.error(String message, T initialState)
      : super(CubitState.error(message: message, data: initialState));

  void emitNormal([T? data]) {
    emit(CubitState.normal(data ?? state.data));
  }

  void emitLoading() {
    emit(CubitState.loading(state.data));
  }

  void emitError(String message) {
    emit(CubitState.error(message: message, data: state.data));
  }

  Future<void> makeAnAction(Future<void> Function() action, {
    bool showLoading = true,
    Function(Object)? onError,
  }) async {
    if (showLoading) {
      LoadingUtil.show();
    }
    try {
      final result = await action();
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
    } finally {
      if (showLoading) {
        LoadingUtil.dismiss();
      }
    }
    return;
  }

  T get currentData => state.data;
}