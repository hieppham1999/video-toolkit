import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/datasources/bundled_font_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';

/// Resolves which font file ffmpeg should use for a given text overlay.
///
/// Resolution order:
///   1. Explicit `overlayFontFile` from the overlay/preset, if the file
///      still exists on disk.
///   2. The user's chosen default font (`UserSettings.defaultFontPath`),
///      if set and the file still exists.
///   3. The bundled `VCR_OSD_Mono_ALLCAPS.ttf` extracted from
///      `assets/fonts/` — guaranteed fallback.
///
/// Always returns a non-null path unless the bundled asset itself fails to
/// extract (extremely unlikely; in that case returns null and ffmpeg will
/// fall back to its own built-in font handling).
@lazySingleton
class FontResolver {
  FontResolver(this._bundled, this._userSettings);

  final BundledFontDatasource _bundled;
  final UserSettingsDatasource _userSettings;

  Future<String?> resolve(String? overlayFontFile) async {
    if (overlayFontFile != null && overlayFontFile.isNotEmpty) {
      if (File(overlayFontFile).existsSync()) return overlayFontFile;
      appLogger.w('FontResolver: overlay font missing: $overlayFontFile — '
          'falling back to user default / bundled');
    }

    final userDefault = (await _userSettings.load())?.defaultFontPath;
    if (userDefault != null && userDefault.isNotEmpty) {
      if (File(userDefault).existsSync()) return userDefault;
      appLogger.w('FontResolver: user default font missing: $userDefault — '
          'falling back to bundled');
    }

    return _bundled.extractDefaultFont();
  }
}
