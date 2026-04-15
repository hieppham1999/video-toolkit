sealed class AppRoutes {
  final String path;

  const AppRoutes({required this.path});
}

class HomeRoute extends AppRoutes {
  const HomeRoute() : super(path: '/');
}

class EncodeRoute extends AppRoutes {
  const EncodeRoute({required this.filePath, required this.totalDuration})
      : super(path: '/encode');

  final String filePath;
  final Duration totalDuration;
}
