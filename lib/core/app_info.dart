import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static const String author = 'HiepPT';
  static String appName = 'Video Toolkit';
  static String version = '';

  static Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    appName = info.appName.isEmpty ? 'Video Toolkit' : info.appName;
    version = info.version;
  }
}
