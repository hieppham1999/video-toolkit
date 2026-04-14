import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/presentation/base/app_state.dart';
import 'package:video_toolkit/presentation/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


typedef ChildStateBuilder<T> = Widget Function(BuildContext context, T state);

/// A BlocConsumer wrapper
class CubitStateBuilder<T> extends StatefulWidget {
  const CubitStateBuilder({
    super.key,
    required this.builder,
    required this.cubit,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final Cubit<CubitState<T>> cubit;
  final ChildStateBuilder<T> builder;
  final ChildStateBuilder<T>? loadingBuilder;
  final ChildStateBuilder<T>? errorBuilder;

  @override
  State<CubitStateBuilder<T>> createState() => _CubitStateBuilderState<T>();
}

class _CubitStateBuilderState<T> extends State<CubitStateBuilder<T>> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Cubit<CubitState<T>>, CubitState<T>>(
      bloc: widget.cubit,
      listener: (context, state) {
        appLogger.d(
          "${widget.cubit.runtimeType}: New state -> ${state.toString()}",
        );
      },
      builder: (context, state) {
        switch (state) {
          case NormalState<T>():
            return widget.builder.call(context, state.data);
          case LoadingState<T>():
            return widget.loadingBuilder?.call(context, state.data) ?? Center(child: CircularProgressIndicator(),);
          case ErrorState<T>():
            return widget.errorBuilder?.call(context, state.data) ?? Center(child: Text(state.message));
        }
      },
      buildWhen: (oldState, newState) {
        switch (newState) {
          case NormalState<T>():
            return true;
          case LoadingState<T>():
            return true;
          case ErrorState<T>():
            return true;
        }
      },
    );
  }
}
