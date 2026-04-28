sealed class AppRoutes {
  final String path;

  const AppRoutes({required this.path});
}

class HomeRoute extends AppRoutes {
  const HomeRoute() : super(path: '/');
}
