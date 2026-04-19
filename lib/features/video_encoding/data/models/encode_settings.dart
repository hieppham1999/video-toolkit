import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/encode_settings.freezed.dart';

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
  if (t.fontFile != null) parts.add("fontfile='${t.fontFile}'");
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
      "text='$textExpr'",
      'fontsize=${t.fontSize}',
      'fontcolor=${t.fontColor}',
      'x=$x',
      'y=$y',
    ];
    if (t.borderWidth > 0) {
      parts.add('borderw=${t.borderWidth}');
      parts.add('bordercolor=${t.borderColor}');
    }
    if (t.fontFile != null) parts.add("fontfile='${t.fontFile}'");
    return parts;
  }

  final timeParts = buildParts(
    '%{pts\\:localtime\\:$unixTs\\:%H\\\\\\:%M\\\\\\:%S}',
    yTime,
  );
  final dateParts = buildParts(
    '%{pts\\:localtime\\:$unixTs\\:%b.%d %Y}',
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
  }) = _EncodeSettings;

  /// Builds ffmpeg arguments from these settings.
  List<String> buildArgs(String inputPath, String outputPath, {DateTime? creationDate}) {
    final filters = textOverlays
        .expand((t) => textOverlayToFilter(t, creationDate: creationDate))
        .toList();

    if (resolution != null) {
      filters.insert(0, 'scale=$resolution');
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

enum AudioBitrate {
  k64('64k'),
  k128('128k'),
  k192('192k'),
  k256('256k'),
  k320('320k');

  const AudioBitrate(this.value);

  final String value;
}
  
