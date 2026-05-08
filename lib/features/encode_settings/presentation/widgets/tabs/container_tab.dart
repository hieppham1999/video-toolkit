import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/widgets/app_checkbox.dart';
import 'package:video_toolkit/widgets/app_dropdown.dart';
import 'package:video_toolkit/features/encode_settings/presentation/pages/encode_settings_controller.dart';

class ContainerTab extends StatelessWidget {
  const ContainerTab({super.key, required this.controller});

  final EncodeSettingsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = Languages.translate;
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropdown<OutputExtension>(
          label: l10n.fileExtension,
          value: c.outputExtension,
          items: OutputExtension.values,
          itemLabel: (e) => e.value,
          onChanged: c.setOutputExtension,
        ),
        const SizedBox(height: 12),
        AppCheckbox(
          value: c.webOptimized,
          onChanged: c.setWebOptimized,
          label: Text(l10n.webOptimized),
        ),
      ],
    );
  }
}
