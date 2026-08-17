import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/core/app_info.dart';
import 'package:video_toolkit/core/notifications/app_notification_service.dart';
import 'package:video_toolkit/widgets/loading.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const env = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  await configureDependencies(env);
  await AppInfo.load();
  await AppNotificationService.initialize();
  runApp(const App());
  LoadingUtil.setup();
}
