import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:video_toolkit/core/navigation/app_routes.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart';
import 'package:video_toolkit/features/video_encoding/presentation/pages/encode_page.dart';
import 'package:video_toolkit/features/video_import/presentation/pages/home_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    final logger = GetIt.I<AppLogger>();
    logger.i('Navigate to "${settings.name}" — args: $args');

    if (args is! AppRoutes) {
      if (settings.name == '/') {
        return _buildRoute(const HomePage());
      }
      return _errorRoute();
    }

    return switch (args) {
      HomeRoute() => _buildRoute(const HomePage()),
      EncodeRoute(:final filePath, :final totalDuration) => _buildRoute(
          BlocProvider(
            create: (_) => GetIt.I<VideoEncodeCubit>(),
            child: EncodePage(
              filePath: filePath,
              totalDuration: totalDuration,
            ),
          ),
        ),
    };
  }

  static Route<dynamic> _buildRoute(Widget page) {
    if (Platform.isWindows) {
      return fluent.FluentPageRoute(builder: (_) => page);
    }
    return CupertinoPageRoute(builder: (_) => page);
  }

  static Route<dynamic> _errorRoute() {
    return _buildRoute(
      const Center(child: Text('Page not found')),
    );
  }
}
