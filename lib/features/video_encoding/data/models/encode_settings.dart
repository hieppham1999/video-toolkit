import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/features/video_encoding/domain/timestamp_subtitle.dart';

part 'generated/encode_settings.freezed.dart';
part 'generated/encode_settings.g.dart';

String _requireSubtitleValue(String? value) =>
    value ?? (throw StateError('Subtitle value is missing'));

/// Position anchor for text overlay placement.
enum TextOverlayPosition { topLeft, topRight, bottomLeft, bottomRight, center }

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

  factory TextOverlay.fromJson(Map<String, dynamic> json) =>
      _$TextOverlayFromJson(json);
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
  if (t.fontFile != null) {
    parts.add("fontfile='${t.fontFile!.escapedForWindowsCmd}'");
  }
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
  final baseUtcSec =
      (creationDate ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
  final offsetDuration = parseTimestampOffset(sourceTimezoneOffset);
  final useGmtime = offsetDuration != null;
  final unixTs = useGmtime ? baseUtcSec + offsetDuration.inSeconds : baseUtcSec;
  final timeFn = useGmtime ? 'gmtime' : 'localtime';
  // Resolve the offset string actually shown in the overlay: source override
  // when present, else the encode machine's local offset.
  final tzLabel =
      sourceTimezoneOffset ??
      formatLocalTimestampOffset(DateTime.now().timeZoneOffset);
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
    if (t.fontFile != null) {
      parts.add("fontfile='${t.fontFile!.escapedForWindowsCmd}'");
    }
    return parts;
  }

  final timeText = t.showTimezone
      ? '%{pts:$timeFn:$unixTs:%H\\:%M\\:%S}$tzLabel'
      : '%{pts:$timeFn:$unixTs:%H\\:%M\\:%S}';
  final timeParts = buildParts(timeText, yTime);
  final dateParts = buildParts('%{pts:$timeFn:$unixTs:%b.%d %Y}', yBase);

  return ['drawtext=${timeParts.join(':')}', 'drawtext=${dateParts.join(':')}'];
}

String _xExpr(TextOverlay t) => switch (t.position) {
  TextOverlayPosition.topLeft ||
  TextOverlayPosition.bottomLeft => '${t.offsetX}',
  TextOverlayPosition.topRight ||
  TextOverlayPosition.bottomRight => '(w-text_w-${t.offsetX})',
  TextOverlayPosition.center => '(w-text_w)/2',
};

String _yExpr(TextOverlay t) => switch (t.position) {
  TextOverlayPosition.topLeft || TextOverlayPosition.topRight => '${t.offsetY}',
  TextOverlayPosition.bottomLeft ||
  TextOverlayPosition.bottomRight => '(h-text_h-${t.offsetY})',
  TextOverlayPosition.center => '(h-text_h)/2',
};

/// Like [_yExpr] but adds extra pixel offset (used to stack timestamp lines).
String _yExprOffset(TextOverlay t, int extra) => switch (t.position) {
  TextOverlayPosition.topLeft ||
  TextOverlayPosition.topRight => '${t.offsetY + extra}',
  TextOverlayPosition.bottomLeft ||
  TextOverlayPosition.bottomRight => '(h-text_h-${t.offsetY + extra})',
  TextOverlayPosition.center => '((h-text_h)/2-$extra)',
};

/// Full encode settings for a video.
@freezed
abstract class EncodeSettings with _$EncodeSettings {
  const EncodeSettings._();

  const factory EncodeSettings({
    @Default(VideoEncoder.h264) VideoEncoder codec,
    @Default(EncoderMode.software) EncoderMode encoderMode,
    @Default(EncodePreset.veryfast) EncodePreset preset,
    @Default(VideoProfile.auto) VideoProfile videoProfile,
    @Default(VideoLevel.auto) VideoLevel videoLevel,
    @Default(PixelFormat.auto) PixelFormat pixelFormat,
    double? frameRate,
    @Default(ToneMapMode.off) ToneMapMode toneMapMode,
    @Default(23) int crf,
    @Default(OutputExtension.mp4) OutputExtension outputExtension,

    /// Null = keep original resolution. Format: "1920:1080".
    String? resolution,
    @Default(AudioCodec.passthrough) AudioCodec audioCodec,
    @Default(AudioBitrate.k128) AudioBitrate audioBitrate,
    @Default(true) bool preserveAllAudioTracks,
    @Default([]) List<TextOverlay> textOverlays,
    @Default(false) bool embedTimestampSubtitle,
    @Default(false) bool preserveSourceSubtitles,

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
    @Default(100) int targetSizeMb,
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
    @Default(Rotation.none) Rotation rotation,

    /// When true and [rotation] != none, write rotation as display metadata
    /// only (no pixel re-encode). Best with MP4/MOV containers.
    @Default(false) bool useDisplayRotation,
    @Default(false) bool flipHorizontal,
    @Default(false) bool flipVertical,
  }) = _EncodeSettings;

  factory EncodeSettings.fromJson(Map<String, dynamic> json) =>
      _$EncodeSettingsFromJson(json);

  bool get supportsTimestampSubtitle => timestampSubtitleCodec != null;

  bool get supportsSourceSubtitlePassthrough =>
      outputExtension == OutputExtension.mkv;

  String? get timestampSubtitleCodec => switch (outputExtension) {
    OutputExtension.mp4 || OutputExtension.mov => 'mov_text',
    OutputExtension.mkv => 'subrip',
    OutputExtension.avi || OutputExtension.mts || OutputExtension.webm => null,
  };

  /// Builds the ffmpeg `-vf` filter chain from these settings.
  ///
  /// Returned string is the joined filter graph suitable for `-vf`, or null
  /// if no filters apply. Kept public so the preview pipeline can reuse the
  /// exact same chain as the real encode.
  String? buildVideoFilterChain({DateTime? creationDate}) {
    final overlayFilters = textOverlays
        .expand(
          (t) => textOverlayToFilter(
            t,
            creationDate: creationDate,
            sourceTimezoneOffset: sourceTimezoneOffset,
          ),
        )
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

    final transformFilters = <String>[];
    if (!useDisplayRotation) {
      switch (rotation) {
        case Rotation.none:
          break;
        case Rotation.cw90:
          transformFilters.add('transpose=1');
          break;
        case Rotation.ccw90:
          transformFilters.add('transpose=2');
          break;
        case Rotation.deg180:
          transformFilters.add('transpose=1');
          transformFilters.add('transpose=1');
          break;
      }
    }
    if (flipHorizontal) transformFilters.add('hflip');
    if (flipVertical) transformFilters.add('vflip');
    for (var i = transformFilters.length - 1; i >= 0; i--) {
      filters.insert(0, transformFilters[i]);
    }

    if (deinterlace.filter.isNotEmpty) {
      final prependedCount = filters.length - overlayFilters.length;
      filters.insert(prependedCount, deinterlace.filter);
    }

    if (toneMapMode != ToneMapMode.off) {
      final insertionIndex = filters.length - overlayFilters.length;
      filters.insertAll(insertionIndex, toneMapMode.filters);
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
    String? timestampSubtitlePath,
    String? resolvedVideoEncoder,
    int? resolvedVideoBitrateKbps,
  }) {
    final filterChain = buildVideoFilterChain(creationDate: creationDate);
    final nullSink = Platform.isWindows ? 'NUL' : '/dev/null';
    final encoder = resolvedVideoEncoder ?? codec.value;
    final codecParamsFlag = _codecParamsFlag(encoder);
    final mergedParams = _mergedCodecParams(pass: pass);
    final subtitleCodec = timestampSubtitleCodec;
    final includeTimestampSubtitle =
        embedTimestampSubtitle &&
        timestampSubtitlePath != null &&
        subtitleCodec != null;

    return [
      '-i', inputPath,
      if (includeTimestampSubtitle) ...[
        '-i',
        _requireSubtitleValue(timestampSubtitlePath),
      ],
      if (pass == 1) ...[
        '-map',
        '0:v:0',
      ] else ...[
        '-map',
        '0:v:0',
        '-map',
        preserveAllAudioTracks ? '0:a?' : '0:a:0?',
        if (includeTimestampSubtitle) ...['-map', '1:0'],
        if (preserveSourceSubtitles && supportsSourceSubtitlePassthrough) ...[
          '-map',
          '0:s?',
        ],
      ],
      '-c:v', encoder,
      ..._speedArgs(encoder),
      if (videoProfile.value != null && codec != VideoEncoder.prores) ...[
        '-profile:v',
        videoProfile.value!,
      ],
      if (videoLevel.value != null &&
          (codec == VideoEncoder.h264 || codec == VideoEncoder.h265)) ...[
        '-level:v',
        videoLevel.value!,
      ],
      if (codec == VideoEncoder.prores) ...[
        '-profile:v',
        '3',
      ] else ...[
        ..._qualityArgs(encoder, resolvedVideoBitrateKbps),
      ],
      if (pass != null) ...['-pass', '$pass'],
      if (pass != null && passLogPrefix != null) ...[
        '-passlogfile',
        passLogPrefix,
      ],
      if (codecParamsFlag != null && mergedParams.isNotEmpty) ...[
        codecParamsFlag,
        mergedParams,
      ],
      if (codecParamsFlag == null && extraParams.trim().isNotEmpty)
        ...extraParams.trim().split(RegExp(r'\s+')),
      if (filterChain != null) ...['-vf', filterChain],
      if (frameRate != null) ...['-r', _formatFrameRate(frameRate!)],
      if (pixelFormat.value != null) ...['-pix_fmt', pixelFormat.value!],
      if (pass != 1 &&
          (includeTimestampSubtitle ||
              (preserveSourceSubtitles &&
                  supportsSourceSubtitlePassthrough))) ...[
        '-c:s',
        preserveSourceSubtitles && supportsSourceSubtitlePassthrough
            ? 'copy'
            : _requireSubtitleValue(subtitleCodec),
      ],
      if (includeTimestampSubtitle && pass != 1) ...[
        '-metadata:s:s:0',
        'title=timestamp',
      ],
      if (pass == 1) ...[
        '-an',
        '-f',
        'null',
      ] else ...[
        '-c:a',
        audioCodec.value,
        if (audioCodec != AudioCodec.passthrough) ...[
          '-b:a',
          audioBitrate.value,
        ],
      ],
      if (pass != 1 &&
          webOptimized &&
          (outputExtension == OutputExtension.mp4 ||
              outputExtension == OutputExtension.mov)) ...[
        '-movflags',
        '+faststart',
      ],
      // Apple devices (QuickTime, iOS, macOS) only play HEVC in MP4/MOV when
      // the sample entry uses the `hvc1` tag. ffmpeg defaults to `hev1`, which
      // results in unplayable files on Apple platforms.
      if (pass != 1 &&
          codec == VideoEncoder.h265 &&
          (outputExtension == OutputExtension.mp4 ||
              outputExtension == OutputExtension.mov)) ...[
        '-tag:v',
        'hvc1',
      ],
      if (pass != 1 && useDisplayRotation && rotation != Rotation.none) ...[
        '-metadata:s:v:0',
        'rotate=${rotation.degrees}',
      ],
      if (pass != 1 && copySourceMetadata) ...[
        '-map_metadata',
        '0',
        '-map_chapters',
        '0',
      ],
      pass == 1 ? '-y' : '-n',
      pass == 1 ? nullSink : outputPath,
    ];
  }

  String? _codecParamsFlag(String encoder) {
    if (encoder != codec.value) return null;
    return switch (codec) {
      VideoEncoder.h264 => '-x264-params',
      VideoEncoder.h265 => '-x265-params',
      VideoEncoder.vp9 => null,
      VideoEncoder.av1 => '-svtav1-params',
      VideoEncoder.prores => null,
    };
  }

  String _formatFrameRate(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  bool get isVideoProfileSupported => switch (codec) {
    VideoEncoder.h264 =>
      videoProfile == VideoProfile.auto ||
          videoProfile == VideoProfile.baseline ||
          videoProfile == VideoProfile.main ||
          videoProfile == VideoProfile.high,
    VideoEncoder.h265 =>
      videoProfile == VideoProfile.auto ||
          videoProfile == VideoProfile.main ||
          videoProfile == VideoProfile.main10,
    VideoEncoder.vp9 ||
    VideoEncoder.av1 ||
    VideoEncoder.prores => videoProfile == VideoProfile.auto,
  };

  List<String> _qualityArgs(String encoder, int? resolvedVideoBitrateKbps) {
    if (encoder != codec.value || qualityMode != QualityMode.crf) {
      return ['-b:v', '${resolvedVideoBitrateKbps ?? avgBitrateKbps}k'];
    }
    return ['-crf', '$crf'];
  }

  /// Calculates the video bitrate needed to approach [targetSizeMb].
  ///
  /// Two percent is reserved for container overhead. Passthrough audio has no
  /// configured bitrate, so a conservative 192 kbps estimate is used.
  int targetVideoBitrateKbps(Duration duration) {
    if (duration <= Duration.zero || targetSizeMb <= 0) return 0;
    final audioKbps = audioCodec == AudioCodec.passthrough
        ? 192
        : audioBitrate.kbps;
    final durationSeconds =
        duration.inMilliseconds / Duration.millisecondsPerSecond;
    final totalKbps = targetSizeMb * 8000 * 0.98 / durationSeconds;
    return (totalKbps - audioKbps).floor();
  }

  List<String> _speedArgs(String encoder) {
    if (encoder != codec.value) return const [];
    return switch (codec) {
      VideoEncoder.h264 || VideoEncoder.h265 => ['-preset', preset.value],
      VideoEncoder.vp9 => [
        '-deadline',
        'good',
        '-cpu-used',
        '${preset.speedRank}',
      ],
      VideoEncoder.av1 => ['-preset', '${preset.av1Preset}'],
      VideoEncoder.prores => const [],
    };
  }

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
    VideoEncoder.av1 => '',
    VideoEncoder.prores => '',
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
  vp9('libvpx-vp9'),
  av1('libsvtav1'),
  prores('prores_ks');

  const VideoEncoder(this.value);

  final String value;
}

enum EncoderMode { software, auto, hardware }

enum VideoProfile {
  auto(null),
  baseline('baseline'),
  main('main'),
  high('high'),
  main10('main10');

  const VideoProfile(this.value);

  final String? value;
}

enum VideoLevel {
  auto(null),
  l3_1('3.1'),
  l4_0('4.0'),
  l4_1('4.1'),
  l5_0('5.0'),
  l5_1('5.1');

  const VideoLevel(this.value);

  final String? value;
}

enum PixelFormat {
  auto(null),
  yuv420p('yuv420p'),
  yuv420p10le('yuv420p10le'),
  yuv422p10le('yuv422p10le');

  const PixelFormat(this.value);

  final String? value;
}

enum ToneMapMode {
  off(''),
  hable('hable'),
  reinhard('reinhard'),
  mobius('mobius');

  const ToneMapMode(this.value);

  final String value;

  List<String> get filters => this == ToneMapMode.off
      ? const []
      : [
          'zscale=t=linear:npl=100',
          'format=gbrpf32le',
          'zscale=p=bt709',
          'tonemap=tonemap=$value:desat=0',
          'zscale=t=bt709:m=bt709:r=tv',
          'format=yuv420p',
        ];
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

  int get speedRank => switch (this) {
    EncodePreset.veryfast => 8,
    EncodePreset.faster => 7,
    EncodePreset.fast => 6,
    EncodePreset.medium => 4,
    EncodePreset.slow => 3,
    EncodePreset.slower => 2,
    EncodePreset.veryslow => 1,
  };

  int get av1Preset => switch (this) {
    EncodePreset.veryfast => 10,
    EncodePreset.faster => 9,
    EncodePreset.fast => 8,
    EncodePreset.medium => 6,
    EncodePreset.slow => 4,
    EncodePreset.slower => 2,
    EncodePreset.veryslow => 0,
  };
}

enum OutputExtension {
  mp4('mp4'),
  mov('mov'),
  avi('avi'),
  mkv('mkv'),
  mts('mts'),
  webm('webm');

  const OutputExtension(this.value);

  final String value;
}

enum AudioCodec {
  aac('aac'),
  mp3('mp3'),
  ac3('ac3'),
  opus('libopus'),
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

/// Rotation applied to the video.
/// Pixel-rotation maps to ffmpeg `transpose` filters; metadata-only rotation
/// is emitted via `-metadata:s:v:0 rotate=<degrees>` in [EncodeSettings.buildArgs].
enum Rotation {
  none(0),
  cw90(90),
  deg180(180),
  ccw90(270);

  const Rotation(this.degrees);

  final int degrees;
}

/// How the encoder picks a bitrate.
/// - [crf]: constant quality, variable bitrate (`-crf <N>`).
/// - [avgBitrate]: target average bitrate in kbps (`-b:v <N>k`), optional 2-pass.
/// - [targetSize]: derive bitrate from the duration and desired output size.
enum QualityMode { crf, avgBitrate, targetSize }

enum AudioBitrate {
  k64('64k'),
  k128('128k'),
  k192('192k'),
  k256('256k'),
  k320('320k');

  const AudioBitrate(this.value);

  final String value;

  int get kbps => int.parse(value.substring(0, value.length - 1));
}
