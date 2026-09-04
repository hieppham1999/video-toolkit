import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/widgets/app_radio.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';

class VideoCodecTab extends StatelessWidget {
  const VideoCodecTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    final isAvg = c.qualityMode == QualityMode.avgBitrate;
    final isCrf = c.qualityMode == QualityMode.crf;
    final isTargetSize = c.qualityMode == QualityMode.targetSize;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdown<VideoEncoder>(
            label: l10n.videoCodec,
            value: c.codec,
            items: VideoEncoder.values,
            itemLabel: (e) => e.value,
            onChanged: c.setCodec,
          ),
          const SizedBox(height: 16),
          AppDropdown<EncoderMode>(
            label: l10n.encoderMode,
            value: c.encoderMode,
            items: EncoderMode.values,
            itemLabel: (mode) => switch (mode) {
              EncoderMode.software => l10n.encoderModeSoftware,
              EncoderMode.auto => l10n.encoderModeAuto,
              EncoderMode.hardware => l10n.encoderModeHardware,
            },
            onChanged: c.setEncoderMode,
            enabled: c.supportsHardwareEncoder,
          ),
          const SizedBox(height: 16),
          _QualityLabel(text: l10n.quality),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppRadio<QualityMode>(
                  value: QualityMode.avgBitrate,
                  groupValue: c.qualityMode,
                  onChanged: c.setQualityMode,
                  label: Text(l10n.avgBitrateKbps),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: _BareNumberField(
                  value: '${c.avgBitrateKbps}',
                  enabled: isAvg,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) c.setAvgBitrateKbps(n);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AppCheckbox(
                      value: c.twoPass,
                      enabled: (isAvg || isTargetSize) && c.supportsTwoPass,
                      onChanged: c.setTwoPass,
                      label: Text(l10n.twoPassEncoding),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: AppCheckbox(
                      value: c.turboFirstPass,
                      enabled:
                          (isAvg || isTargetSize) &&
                          c.twoPass &&
                          c.supportsTwoPass,
                      onChanged: c.setTurboFirstPass,
                      label: Text(l10n.turboFirstPass),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppRadio<QualityMode>(
                value: QualityMode.targetSize,
                groupValue: c.qualityMode,
                onChanged: c.setQualityMode,
                label: Text(
                  l10n.targetFileSizeMb,
                  style: DefaultTextStyle.of(context).style,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: _BareNumberField(
                  value: '${c.targetSizeMb}',
                  enabled: isTargetSize,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) c.setTargetSizeMb(n);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AppRadio<QualityMode>(
                value: QualityMode.crf,
                groupValue: c.qualityMode,
                onChanged: c.setQualityMode,
                label: Text(l10n.constantQuality),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: _BareNumberField(
                  value: '${c.crf}',
                  enabled: isCrf,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) c.setCrf(n);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown<EncodePreset>(
            label: l10n.encodePreset,
            value: c.preset,
            items: EncodePreset.values,
            itemLabel: (e) => e.value,
            onChanged: c.setPreset,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _FieldLabel(text: l10n.moreSettings),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MultilineField(
                  value: c.extraParams,
                  hint: _moreSettingsHint(c.codec, l10n),
                  onChanged: c.setExtraParams,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _moreSettingsHint(VideoEncoder codec, dynamic l10n) => switch (codec) {
    VideoEncoder.h264 => l10n.moreSettingsHintX264,
    VideoEncoder.h265 => l10n.moreSettingsHintX265,
    VideoEncoder.vp9 => l10n.moreSettingsHintVpx,
    VideoEncoder.av1 => l10n.moreSettingsHintAv1,
    VideoEncoder.prores => l10n.moreSettingsHintProres,
  };
}

class _QualityLabel extends StatelessWidget {
  const _QualityLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Platform.isWindows
        ? fluent.FluentTheme.of(context).typography.bodyStrong
        : MacosTheme.of(context).typography.headline;
    return Text(text, style: style);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Platform.isWindows
        ? fluent.FluentTheme.of(context).typography.body
        : MacosTheme.of(context).typography.body;
    return Text(text, style: style);
  }
}

class _MultilineField extends StatefulWidget {
  const _MultilineField({
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;

  @override
  State<_MultilineField> createState() => _MultilineFieldState();
}

class _MultilineFieldState extends State<_MultilineField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _MultilineField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return fluent.TextBox(
        controller: _controller,
        placeholder: widget.hint,
        onChanged: widget.onChanged,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
      );
    }
    return MacosTextField(
      controller: _controller,
      placeholder: widget.hint,
      onChanged: widget.onChanged,
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
    );
  }
}

class _BareNumberField extends StatefulWidget {
  const _BareNumberField({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<_BareNumberField> createState() => _BareNumberFieldState();
}

class _BareNumberFieldState extends State<_BareNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _BareNumberField old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return fluent.TextBox(
        controller: _controller,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
      );
    }
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: MacosTextField(
        controller: _controller,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
      ),
    );
  }
}
