sealed class AppRoutes {
  final String path;

  const AppRoutes({required this.path});
}

class ImportRoute extends AppRoutes {
  const ImportRoute() : super(path: '/import');
}

class VideoListRoute extends AppRoutes {
  const VideoListRoute() : super(path: '/video-list');
}
