// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

class $AssetsBinGen {
  const $AssetsBinGen();

  /// Directory path: assets/bin/ffmpeg
  $AssetsBinFfmpegGen get ffmpeg => const $AssetsBinFfmpegGen();
}

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/.gitkeep
  String get aGitkeep => 'assets/fonts/.gitkeep';

  /// File path: assets/fonts/VCR_OSD_Mono_ALLCAPS.ttf
  String get vCROSDMonoALLCAPS => 'assets/fonts/VCR_OSD_Mono_ALLCAPS.ttf';

  /// List of all assets
  List<String> get values => [aGitkeep, vCROSDMonoALLCAPS];
}

class $AssetsBinFfmpegGen {
  const $AssetsBinFfmpegGen();

  /// Directory path: assets/bin/ffmpeg/macos
  $AssetsBinFfmpegMacosGen get macos => const $AssetsBinFfmpegMacosGen();
}

class $AssetsBinFfmpegMacosGen {
  const $AssetsBinFfmpegMacosGen();

  /// File path: assets/bin/ffmpeg/macos/ffmpeg
  String get ffmpeg => 'assets/bin/ffmpeg/macos/ffmpeg';

  /// File path: assets/bin/ffmpeg/macos/ffprobe
  String get ffprobe => 'assets/bin/ffmpeg/macos/ffprobe';

  /// List of all assets
  List<String> get values => [ffmpeg, ffprobe];
}

class Assets {
  const Assets._();

  static const $AssetsBinGen bin = $AssetsBinGen();
  static const $AssetsFontsGen fonts = $AssetsFontsGen();
}
