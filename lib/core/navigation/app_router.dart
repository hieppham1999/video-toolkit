import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:video_toolkit/core/navigation/app_routes.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_import/presentation/pages/import_page.dart';
import 'package:video_toolkit/features/video_import/presentation/pages/video_list_page.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    final logger = GetIt.I<AppLogger>();
    logger.i('Navigate to "${settings.name}" — args: $args');

    if (args is! AppRoutes) {
      if (settings.name == '/') {
        return _buildRoute(const ImportPage());
      }
      return _errorRoute();
    }

    return switch (args) {
      ImportRoute() => _buildRoute(const ImportPage()),
      VideoListRoute() => _buildRoute(const VideoListPage()),
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
