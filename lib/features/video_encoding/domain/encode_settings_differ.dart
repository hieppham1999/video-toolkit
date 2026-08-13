import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

/// A single field-level difference between two [EncodeSettings] (or two
/// [TextOverlay]) instances. Pure data — formatting and i18n stay in the UI.
class EncodeSettingsDiff {
  const EncodeSettingsDiff({
    required this.label,
    required this.before,
    required this.after,
  });

  final String label;
  final String before;
  final String after;
}

/// Pure, UI-free comparator producing a flat list of field diffs.
/// List fields (currently [TextOverlay]s) and nested freezed objects are
/// expanded so callers see a per-field breakdown rather than a single
/// "list changed" entry.
class EncodeSettingsDiffer {
  const EncodeSettingsDiffer._();

  static const String _none = '–';

  static List<EncodeSettingsDiff> diff(EncodeSettings a, EncodeSettings b) {
    final out = <EncodeSettingsDiff>[];

    _scalar(out, 'Codec', a.codec.value, b.codec.value);
    _scalar(out, 'Speed', a.preset.value, b.preset.value);
    _scalar(out, 'CRF', a.crf, b.crf);
    _scalar(out, 'Container', a.outputExtension.value, b.outputExtension.value);
    _scalar(out, 'Resolution', a.resolution, b.resolution);
    _scalar(out, 'Audio codec', a.audioCodec.value, b.audioCodec.value);
    _scalar(out, 'Audio bitrate', a.audioBitrate.value, b.audioBitrate.value);
    _scalar(
      out,
      'Embed timestamp subtitle',
      a.embedTimestampSubtitle,
      b.embedTimestampSubtitle,
    );
    _scalar(
      out,
      'Filename template',
      a.outputNameTemplate,
      b.outputNameTemplate,
    );
    _scalar(out, 'Crop ratio', a.cropAspectRatio, b.cropAspectRatio);
    _scalar(out, 'Deinterlace', a.deinterlace.name, b.deinterlace.name);
    _scalar(out, 'Quality mode', a.qualityMode.name, b.qualityMode.name);
    _scalar(out, 'Avg bitrate', '${a.avgBitrateKbps}k', '${b.avgBitrateKbps}k');
    _scalar(out, 'Two-pass', a.twoPass, b.twoPass);
    _scalar(out, 'Turbo first pass', a.turboFirstPass, b.turboFirstPass);
    _scalar(out, 'Extra params', a.extraParams, b.extraParams);
    _scalar(out, 'Copy metadata', a.copySourceMetadata, b.copySourceMetadata);
    _scalar(out, 'Source TZ', a.sourceTimezoneOffset, b.sourceTimezoneOffset);
    _scalar(out, 'Web optimized', a.webOptimized, b.webOptimized);
    _scalar(out, 'Rotation', a.rotation.name, b.rotation.name);
    _scalar(
      out,
      'Use display rotation',
      a.useDisplayRotation,
      b.useDisplayRotation,
    );
    _scalar(out, 'Flip horizontal', a.flipHorizontal, b.flipHorizontal);
    _scalar(out, 'Flip vertical', a.flipVertical, b.flipVertical);

    _diffOverlays(out, a.textOverlays, b.textOverlays);

    return out;
  }

  static void _scalar(
    List<EncodeSettingsDiff> out,
    String label,
    Object? a,
    Object? b,
  ) {
    if (a == b) return;
    out.add(EncodeSettingsDiff(label: label, before: _fmt(a), after: _fmt(b)));
  }

  static String _fmt(Object? v) {
    if (v == null) return _none;
    if (v is String && v.isEmpty) return _none;
    return v.toString();
  }

  static void _diffOverlays(
    List<EncodeSettingsDiff> out,
    List<TextOverlay> a,
    List<TextOverlay> b,
  ) {
    final shared = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < shared; i++) {
      _diffOverlay(out, i, a[i], b[i]);
    }
    for (var i = shared; i < a.length; i++) {
      out.add(
        EncodeSettingsDiff(
          label: 'Overlay #${i + 1}',
          before: _overlaySummary(a[i]),
          after: _none,
        ),
      );
    }
    for (var i = shared; i < b.length; i++) {
      out.add(
        EncodeSettingsDiff(
          label: 'Overlay #${i + 1}',
          before: _none,
          after: _overlaySummary(b[i]),
        ),
      );
    }
  }

  static void _diffOverlay(
    List<EncodeSettingsDiff> out,
    int index,
    TextOverlay a,
    TextOverlay b,
  ) {
    final prefix = 'Overlay #${index + 1}';
    _scalar(out, '$prefix type', a.type.name, b.type.name);
    _scalar(out, '$prefix text', a.text, b.text);
    _scalar(out, '$prefix font size', a.fontSize, b.fontSize);
    _scalar(out, '$prefix font color', a.fontColor, b.fontColor);
    _scalar(out, '$prefix position', a.position.name, b.position.name);
    _scalar(out, '$prefix offset X', a.offsetX, b.offsetX);
    _scalar(out, '$prefix offset Y', a.offsetY, b.offsetY);
    _scalar(out, '$prefix font file', a.fontFile, b.fontFile);
    _scalar(out, '$prefix background', a.showBackground, b.showBackground);
    _scalar(out, '$prefix bg color', a.backgroundColor, b.backgroundColor);
    _scalar(out, '$prefix border width', a.borderWidth, b.borderWidth);
    _scalar(out, '$prefix border color', a.borderColor, b.borderColor);
    _scalar(out, '$prefix show TZ', a.showTimezone, b.showTimezone);
  }

  static String _overlaySummary(TextOverlay o) =>
      o.type == TextOverlayType.timestamp ? '[timestamp]' : '"${o.text}"';
}
