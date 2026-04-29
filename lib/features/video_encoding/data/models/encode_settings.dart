import 'dart:io';

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
    /// When [type] is [TextOverlayType.timestamp], appends the timezone offset
    /// (e.g. " +07:00") after the time line. Ignored for custom overlays.
    @Default(false) bool showTimezone,
  }) = _TextOverlay;

  factory TextOverlay.fromJson(Map<String, dynamic> json) => _$TextOverlayFromJson(json);
}

/// Builds ffmpeg drawtext filter string(s) for a [TextOverlay].
///
/// Returns a list because [TextOverlayType.timestamp] produces two filters
/// (time + date), while [TextOverlayType.custom] produces one.
List<String> textOverlayToFilter(
  TextOverlay t, {
  DateTime? creationDate,
  String? sourceTimezoneOffset,
}) {
  if (t.type == TextOverlayType.timestamp) {
    return _timestampFilters(t, creationDate, sourceTimezoneOffset);
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

List<String> _timestampFilters(
  TextOverlay t,
  DateTime? creationDate,
  String? sourceTimezoneOffset,
) {
  // When the user has chosen a source TZ override, shift the unix timestamp
  // by that offset and use ffmpeg's `gmtime` (raw, no machine TZ shift) so
  // the rendered wall-clock matches the source's local time. Otherwise fall
  // back to `localtime`, which uses the encode machine's TZ.
  final baseUtcSec = (creationDate ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
  final offsetDuration = _parseOffsetDuration(sourceTimezoneOffset);
  final useGmtime = offsetDuration != null;
  final unixTs = useGmtime ? baseUtcSec + offsetDuration.inSeconds : baseUtcSec;
  final timeFn = useGmtime ? 'gmtime' : 'localtime';
  // Resolve the offset string actually shown in the overlay: source override
  // when present, else the encode machine's local offset.
  final tzLabel = sourceTimezoneOffset ?? _formatLocalOffset(DateTime.now().timeZoneOffset);
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

  final timeText = t.showTimezone
      ? '%{pts:$timeFn:$unixTs:%H\\:%M\\:%S}$tzLabel'
      : '%{pts:$timeFn:$unixTs:%H\\:%M\\:%S}';
  final timeParts = buildParts(timeText, yTime);
  final dateParts = buildParts(
    '%{pts:$timeFn:$unixTs:%b.%d %Y}',
    yBase,
  );

  return [
    'drawtext=${timeParts.join(':')}',
    'drawtext=${dateParts.join(':')}',
  ];
}

Duration? _parseOffsetDuration(String? offset) {
  if (offset == null) return null;
  final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(offset);
  if (match == null) return null;
  final sign = match.group(1) == '-' ? -1 : 1;
  final h = int.parse(match.group(2)!);
  final m = int.parse(match.group(3)!);
  return Duration(hours: sign * h, minutes: sign * m);
}

String _formatLocalOffset(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final abs = offset.abs();
  final h = abs.inHours.toString().padLeft(2, '0');
  final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
  return '$sign$h:$m';
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
    @Default(QualityMode.crf) QualityMode qualityMode,
    @Default(4000) int avgBitrateKbps,
    @Default(false) bool twoPass,
    @Default(false) bool turboFirstPass,
    /// Raw extra params forwarded via codec-specific flag (e.g. `-x265-params`).
    @Default('') String extraParams,
    @Default(true) bool copySourceMetadata,
    /// Override for the source video's timezone offset (e.g. "+07:00"). Used
    /// when the source MP4 doesn't carry an offset itself — typical for non-
    /// Apple cameras. Null = fall back to the encoding machine's local TZ.
    String? sourceTimezoneOffset,
    @Default(true) bool webOptimized,
  }) = _EncodeSettings;

  factory EncodeSettings.fromJson(Map<String, dynamic> json) => _$EncodeSettingsFromJson(json);

  /// Builds the ffmpeg `-vf` filter chain from these settings.
  ///
  /// Returned string is the joined filter graph suitable for `-vf`, or null
  /// if no filters apply. Kept public so the preview pipeline can reuse the
  /// exact same chain as the real encode.
  String? buildVideoFilterChain({DateTime? creationDate}) {
    final overlayFilters = textOverlays
        .expand((t) => textOverlayToFilter(
              t,
              creationDate: creationDate,
              sourceTimezoneOffset: sourceTimezoneOffset,
            ))
        .toList();
    final filters = [...overlayFilters];

    if (resolution != null) {
      filters.insert(0, 'scale=$resolution');
    }

    if (cropAspectRatio != null && cropAspectRatio!.isNotEmpty) {
      final parts = cropAspectRatio!.split(':');
      if (parts.length == 2) {
        final num = parts[0].trim();
        final den = parts[1].trim();
        filters.insert(0, 'crop=min(iw\\,ih*$num/$den):min(ih\\,iw*$den/$num)');
      }
    }

    if (deinterlace.filter.isNotEmpty) {
      final prependedCount = filters.length - overlayFilters.length;
      filters.insert(prependedCount, deinterlace.filter);
    }

    return filters.isEmpty ? null : filters.join(',');
  }

  /// Builds ffmpeg arguments from these settings.
  ///
  /// [pass] controls two-pass behavior: `null` = single pass; `1` or `2` =
  /// corresponding pass of a 2-pass encode. Pass 1 writes to a null sink and
  /// drops audio. Pass 2 writes the real file. The caller is responsible for
  /// running pass 1 then pass 2 when `twoPass` is true.
  List<String> buildArgs(
    String inputPath,
    String outputPath, {
    DateTime? creationDate,
    int? pass,
    String? passLogPrefix,
  }) {
    final filterChain = buildVideoFilterChain(creationDate: creationDate);
    final nullSink = Platform.isWindows ? 'NUL' : '/dev/null';
    final codecParamsFlag = _codecParamsFlag;
    final mergedParams = _mergedCodecParams(pass: pass);

    return [
      '-i', inputPath,
      '-c:v', codec.value,
      if (preset.value.isNotEmpty) ...['-preset', preset.value],
      if (qualityMode == QualityMode.crf)
        ...['-crf', '$crf']
      else
        ...['-b:v', '${avgBitrateKbps}k'],
      if (pass != null) ...['-pass', '$pass'],
      if (pass != null && passLogPrefix != null)
        ...['-passlogfile', passLogPrefix],
      if (codecParamsFlag != null && mergedParams.isNotEmpty)
        ...[codecParamsFlag, mergedParams],
      if (codecParamsFlag == null && extraParams.trim().isNotEmpty)
        ...extraParams.trim().split(RegExp(r'\s+')),
      if (filterChain != null) ...['-vf', filterChain],
      if (pass == 1) ...['-an', '-f', 'null']
      else ...[
        '-c:a', audioCodec.value,
        if (audioCodec != AudioCodec.passthrough)
          ...['-b:a', audioBitrate.value],
      ],
      if (pass != 1 &&
          webOptimized &&
          (outputExtension == OutputExtension.mp4 ||
              outputExtension == OutputExtension.mov))
        ...['-movflags', '+faststart'],
      '-y',
      pass == 1 ? nullSink : outputPath,
    ];
  }

  String? get _codecParamsFlag => switch (codec) {
        VideoEncoder.h264 => '-x264-params',
        VideoEncoder.h265 => '-x265-params',
        VideoEncoder.vp9 => null,
      };

  /// Merges user [extraParams] with the codec-specific turbo-first-pass string
  /// when [pass] is 1 and [turboFirstPass] is on.
  String _mergedCodecParams({int? pass}) {
    final user = extraParams.trim();
    final useTurbo = pass == 1 && turboFirstPass;
    final turbo = useTurbo ? _turboParams : '';
    if (user.isEmpty) return turbo;
    if (turbo.isEmpty) return user;
    return '$user:$turbo';
  }

  // Pass-1-only speedups. Keep to options x264/x265 tolerate differing between
  // passes; skip anything that changes stats format (e.g. `weightp`, `8x8dct`)
  // — x264 aborts pass 2 with "different X setting than first pass" otherwise.
  String get _turboParams => switch (codec) {
        VideoEncoder.h264 =>
          'ref=1:me=dia:subme=1:trellis=0:mixed-refs=0:fast-pskip=1',
        VideoEncoder.h265 =>
          'no-rect=1:no-amp=1:max-merge=1:early-skip=1:fast-intra=1:ref=1:rd=2:subme=1',
        VideoEncoder.vp9 => '',
      };
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

/// How the encoder picks a bitrate.
/// - [crf]: constant quality, variable bitrate (`-crf <N>`).
/// - [avgBitrate]: target average bitrate in kbps (`-b:v <N>k`), optional 2-pass.
enum QualityMode { crf, avgBitrate }

enum AudioBitrate {
  k64('64k'),
  k128('128k'),
  k192('192k'),
  k256('256k'),
  k320('320k');

  const AudioBitrate(this.value);

  final String value;
}
  
