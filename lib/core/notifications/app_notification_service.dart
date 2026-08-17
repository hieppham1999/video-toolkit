import 'dart:io';

import 'package:local_notifier/local_notifier.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';

/// Sends native desktop notifications without coupling UI code to a platform.
class AppNotificationService {
  AppNotificationService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (!Platform.isWindows && !Platform.isMacOS) return;

    try {
      await localNotifier.setup(
        appName: 'Video Toolkit',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
      _initialized = true;
    } catch (e) {
      appLogger.w('Unable to initialize desktop notifications: $e');
    }
  }

  static Future<void> show({
    required String title,
    required String message,
  }) async {
    if (!_initialized) return;

    try {
      final notification = LocalNotification(title: title, body: message);
      await notification.show();
    } catch (e) {
      appLogger.w('Unable to show desktop notification: $e');
    }
  }
}
