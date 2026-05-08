import 'package:injectable/injectable.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/preset_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/preset_repository.dart';

@LazySingleton(as: PresetRepository)
class PresetRepositoryImpl implements PresetRepository {
  PresetRepositoryImpl(this._datasource);

  final PresetDatasource _datasource;

  static const _userPrefix = 'user.';

  bool _isBuiltIn(String id) => kBuiltInPresets.any((p) => p.id == id);

  @override
  Future<List<SettingsPreset>> listAll() async {
    final user = await _datasource.loadUserPresets();
    return [...kBuiltInPresets, ...user];
  }

  @override
  Future<SettingsPreset> saveAs(String name, EncodeSettings settings) async {
    final id = '$_userPrefix${DateTime.now().microsecondsSinceEpoch}';
    final preset = SettingsPreset(id: id, name: name, settings: settings);
    await _datasource.save(preset);
    return preset;
  }

  @override
  Future<SettingsPreset> overwrite(String id, EncodeSettings settings) async {
    if (_isBuiltIn(id)) {
      throw StateError('Cannot overwrite built-in preset "$id"');
    }
    final existing = (await _datasource.loadUserPresets()).firstWhere(
      (p) => p.id == id,
      orElse: () => throw StateError('Preset not found: $id'),
    );
    final updated = existing.copyWith(settings: settings);
    await _datasource.save(updated);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    if (_isBuiltIn(id)) {
      throw StateError('Cannot delete built-in preset "$id"');
    }
    await _datasource.delete(id);
  }
}
