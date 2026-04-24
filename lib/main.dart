import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/injection.dart';
import 'package:video_toolkit/widgets/loading.dart';

import 'app/app.dart';

void main() async {
  const env = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  await configureDependencies(env);
  runApp(const App());
  LoadingUtil.setup();
}
