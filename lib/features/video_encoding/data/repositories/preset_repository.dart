import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';

abstract class PresetRepository {
  Future<List<SettingsPreset>> listAll();
  Future<SettingsPreset> saveAs(String name, EncodeSettings settings);
  Future<SettingsPreset> overwrite(String id, EncodeSettings settings);
  Future<void> delete(String id);
}
