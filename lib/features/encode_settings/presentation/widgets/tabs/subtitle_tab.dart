import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';

class SubtitleTab extends StatelessWidget {
  const SubtitleTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final supported = controller.supportsTimestampSubtitle;
    final sourceSupported = controller.supportsSourceSubtitlePassthrough;
    final textStyle = DefaultTextStyle.of(context).style;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCheckbox(
            value: controller.embedTimestampSubtitle,
            onChanged: controller.setEmbedTimestampSubtitle,
            enabled: supported,
            label: Text(l10n.embedTimestampSubtitle, style: textStyle),
          ),
          const SizedBox(height: 10),
          Text(
            supported
                ? l10n.embedTimestampSubtitleDescription
                : l10n.subtitleUnsupportedContainer,
            style: textStyle,
          ),
          const SizedBox(height: 18),
          AppCheckbox(
            value: controller.preserveSourceSubtitles,
            onChanged: controller.setPreserveSourceSubtitles,
            enabled: sourceSupported,
            label: Text(l10n.preserveSourceSubtitles, style: textStyle),
          ),
          const SizedBox(height: 10),
          Text(
            sourceSupported
                ? l10n.preserveSourceSubtitlesDescription
                : l10n.sourceSubtitlesMkvOnly,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
