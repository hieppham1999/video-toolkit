import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/encode_settings.freezed.dart';
part 'generated/encode_settings.g.dart';

/// Position anchor for text overlay placement.
enum TextOverlayPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// Whether the overlay is free-form text or an auto-generated timestamp.
enum TextOverlayType { custom, timestamp }

/// A single text overlay to burn into the video via ffmpeg drawtext filter.
@freezed
abstract class TextOverlay with _$TextOverlay {
  const factory TextOverlay({
    /// The text content. Ignored when [type] is [TextOverlayType.timestamp].
    required String text,
    @Default(TextOverlayType.custom) TextOverlayType type,
    @Default(24) int fontSize,
    @Default('white') String fontColor,
    @Default(TextOverlayPosition.bottomRight) TextOverlayPosition position,
    @Default(16) int offsetX,
    @Default(16) int offsetY,
    String? fontFile,
    @Default(true) bool showBackground,
    @Default('black@0.5') String backgroundColor,
    /// Border (stroke) width in pixels around each character. 0 disables.
    @Default(0) int borderWidth,
    @Default('black') String borderColor,
  }) = _TextOverlay;

  factory TextOverlay.fromJson(Map<String, dynamic> json) => _$TextOverlayFromJson(json);
}

/// Builds ffmpeg drawtext filter string(s) for a [TextOverlay].
///
/// Returns a list because [TextOverlayType.timestamp] produces two filters
/// (time + date), while [TextOverlayType.custom] produces one.
List<String> textOverlayToFilter(TextOverlay t, {DateTime? creationDate}) {
  if (t.type == TextOverlayType.timestamp) {
    return _timestampFilters(t, creationDate);
  }
  return [_customFilter(t)];
}

String _customFilter(TextOverlay t) {
  final x = _xExpr(t);
  final y = _yExpr(t);

  final parts = <String>[
    "text='${t.text.replaceAll("'", r"\\'")}'",
    'fontsize=${t.fontSize}',
    'fontcolor=${t.fontColor}',
    'x=$x',
    'y=$y',
  ];
  if (t.fontFile != null) parts.add("fontfile='${t.fontFile?.escapedForWindowsCmd}'");
  if (t.borderWidth > 0) {
    parts.add('borderw=${t.borderWidth}');
    parts.add('bordercolor=${t.borderColor}');
  }
  if (t.showBackground) {
    parts.add('box=1');
    parts.add('boxcolor=${t.backgroundColor}');
    parts.add('boxborderw=6');
  }
  return 'drawtext=${parts.join(':')}';
}

List<String> _timestampFilters(TextOverlay t, DateTime? creationDate) {
  final unixTs = (creationDate ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
  final x = _xExpr(t);
  // Time line sits above the date line; spacing = fontSize + 10.
  final yBase = _yExpr(t);
  final yTime = _yExprOffset(t, t.fontSize + 10);

  List<String> buildParts(String textExpr, String y) {
    final parts = <String>[
      "text='${textExpr.escapedForWindowsCmd}'",
      'fontsize=${t.fontSize}',
      'fontcolor=${t.fontColor}',
      'x=$x',
      'y=$y',
    ];
    if (t.borderWidth > 0) {
      parts.add('borderw=${t.borderWidth}');
      parts.add('bordercolor=${t.borderColor}');
    }
    if (t.fontFile != null) parts.add("fontfile='${t.fontFile?.escapedForWindowsCmd}'");
    return parts;
  }

  final timeParts = buildParts(
    '%{pts:localtime:$unixTs:%H\\:%M\\:%S}',
    yTime,
  );
  final dateParts = buildParts(
    '%{pts:localtime:$unixTs:%b.%d %Y}',
    yBase,
  );

  return [
    'drawtext=${timeParts.join(':')}',
    'drawtext=${dateParts.join(':')}',
  ];
}

String _xExpr(TextOverlay t) => switch (t.position) {
  TextOverlayPosition.topLeft || TextOverlayPosition.bottomLeft => '${t.offsetX}',
  TextOverlayPosition.topRight || TextOverlayPosition.bottomRight => '(w-text_w-${t.offsetX})',
  TextOverlayPosition.center => '(w-text_w)/2',
};

String _yExpr(TextOverlay t) => switch (t.position) {
  TextOverlayPosition.topLeft || TextOverlayPosition.topRight => '${t.offsetY}',
  TextOverlayPosition.bottomLeft || TextOverlayPosition.bottomRight => '(h-text_h-${t.offsetY})',
  TextOverlayPosition.center => '(h-text_h)/2',
};

/// Like [_yExpr] but adds extra pixel offset (used to stack timestamp lines).
String _yExprOffset(TextOverlay t, int extra) => switch (t.position) {
  TextOverlayPosition.topLeft || TextOverlayPosition.topRight => '${t.offsetY + extra}',
  TextOverlayPosition.bottomLeft || TextOverlayPosition.bottomRight => '(h-text_h-${t.offsetY + extra})',
  TextOverlayPosition.center => '((h-text_h)/2-$extra)',
};

/// Full encode settings for a video.
@freezed
abstract class EncodeSettings with _$EncodeSettings {
  const EncodeSettings._();

  const factory EncodeSettings({
    @Default(VideoEncoder.h264) VideoEncoder codec,
    @Default(EncodePreset.veryfast) EncodePreset preset,
    @Default(23) int crf,
    @Default(OutputExtension.mp4) OutputExtension outputExtension,
    /// Null = keep original resolution. Format: "1920:1080".
    String? resolution,
    @Default(AudioCodec.passthrough) AudioCodec audioCodec,
    @Default(AudioBitrate.k128) AudioBitrate audioBitrate,
    @Default([]) List<TextOverlay> textOverlays,
    /// Template for output file name (without extension). Empty = default
    /// `<name>_encoded`. See [FilenameTemplate] for supported tags.
    @Default('') String outputNameTemplate,
    /// Target aspect ratio `num:den` (e.g. "16:9", "9:16", "1:1"). Null or
    /// empty = keep original, no crop.
    String? cropAspectRatio,
    /// Deinterlacing filter applied before text overlays.
    @Default(Deinterlace.off) Deinterlace deinterlace,
  }) = _EncodeSettings;

  factory EncodeSettings.fromJson(Map<String, dynamic> json) => _$EncodeSettingsFromJson(json);

  /// Builds ffmpeg arguments from these settings.
  List<String> buildArgs(String inputPath, String outputPath, {DateTime? creationDate}) {
    final filters = textOverlays
        .expand((t) => textOverlayToFilter(t, creationDate: creationDate))
        .toList();

    if (resolution != null) {
      filters.insert(0, 'scale=$resolution');
    }

    // Crop to target aspect ratio (center crop). Runs before scale so scale
    // operates on the cropped image. Commas inside the expressions must be
    // escaped (`\,`) — otherwise they'd be parsed as filter-graph separators.
    if (cropAspectRatio != null && cropAspectRatio!.isNotEmpty) {
      final parts = cropAspectRatio!.split(':');
      if (parts.length == 2) {
        final num = parts[0].trim();
        final den = parts[1].trim();
        filters.insert(0, 'crop=min(iw\\,ih*$num/$den):min(ih\\,iw*$den/$num)');
      }
    }

    // Deinterlacing runs after crop/scale but before drawtext overlays so the
    // text is drawn onto clean progressive frames. Example full chain:
    //   crop=...,scale=...,yadif=mode=1,drawtext=...
    if (deinterlace.filter.isNotEmpty) {
      // Count of preset prepends (crop, scale) already at the head of `filters`.
      // Insert yadif right after them, before the drawtext entries.
      final prependedCount = filters.length - textOverlays
          .expand((t) => textOverlayToFilter(t, creationDate: creationDate))
          .length;
      filters.insert(prependedCount, deinterlace.filter);
    }

    return [
      '-i', inputPath,
      '-c:v', codec.value,
      if (preset.value.isNotEmpty) ...['-preset', preset.value],
      '-crf', '$crf',
      if (filters.isNotEmpty) ...['-vf', filters.join(',')],
      '-c:a', audioCodec.value,
      '-b:a', audioBitrate.value,
      '-y',
      outputPath,
    ];
  }
}

extension StringOnWindows on String {
  /// Escapes special characters in a string for safe use in Windows cmd.exe.
  /// Specifically, it doubles backslashes and escapes colons.
  String get escapedForWindowsCmd {
    return replaceAll('\\', '\\\\').replaceAll(':', r'\:');
  }
}

enum VideoEncoder {
  h264('libx264'),
  h265('libx265'),
  vp9('libvpx-vp9');

  const VideoEncoder(this.value);

  final String value;
}

enum EncodePreset {
  veryfast('veryfast'),
  faster('faster'),
  fast('fast'),
  medium('medium'),
  slow('slow'),
  slower('slower'),
  veryslow('veryslow');

  const EncodePreset(this.value);

  final String value;
}

enum OutputExtension {
  mp4('mp4'),
  mov('mov'),
  avi('avi'),
  mkv('mkv'),
  mts('mts');

  const OutputExtension(this.value);

  final String value;
}

enum AudioCodec {
  aac('aac'),
  mp3('mp3'),
  ac3('ac3'),
  passthrough('copy');

  const AudioCodec(this.value);

  final String value;
}

/// Deinterlacing via ffmpeg.
/// - [off]: no filter applied.
/// - [yadifFrame]: `yadif=mode=0` — one output frame per input frame (preserves fps).
/// - [yadifField]: `yadif=mode=1` — one output frame per input field (doubles fps, smoother).
/// - [bwdifFrame]: `bwdif=mode=0` — better quality than yadif, single fps.
/// - [bwdifField]: `bwdif=mode=1` — better quality than yadif, doubles fps.
enum Deinterlace {
  off(''),
  yadifFrame('yadif=mode=0'),
  yadifField('yadif=mode=1'),
  bwdifFrame('bwdif=mode=0'),
  bwdifField('bwdif=mode=1');

  const Deinterlace(this.filter);

  final String filter;
}

enum AudioBitrate {
  k64('64k'),
  k128('128k'),
  k192('192k'),
  k256('256k'),
  k320('320k');

  const AudioBitrate(this.value);

  final String value;
}
  
