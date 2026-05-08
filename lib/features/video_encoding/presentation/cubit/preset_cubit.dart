import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/preset_repository.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import 'preset_state.dart';

@lazySingleton
class PresetCubit extends BaseCubit<PresetState> {
  PresetCubit(this._repository, this._userSettings)
      : super.normal(const PresetState()) {
    loadAll();
  }

  final PresetRepository _repository;
  final UserSettingsDatasource _userSettings;

  Future<void> loadAll() async {
    if (currentData.isLoading) return;
    emitNormal(currentData.copyWith(isLoading: true));
    try {
      final presets = await _repository.listAll();
      final persisted = await _userSettings.load();
      String? selectedId = persisted?.selectedPresetId;
      if (selectedId == null) {
        selectedId = kBuiltInPresets.first.id;
        await _userSettings.saveSelectedPresetId(selectedId);
      } else if (presets.every((p) => p.id != selectedId)) {
        // Persisted preset was deleted — fall back to built-in default.
        selectedId = kBuiltInPresets.first.id;
        await _userSettings.saveSelectedPresetId(selectedId);
      }
      emitNormal(currentData.copyWith(
        presets: presets,
        selectedId: selectedId,
        isLoading: false,
      ));
    } catch (e) {
      appLogger.w('PresetCubit: failed to load presets: $e');
      emitNormal(currentData.copyWith(isLoading: false));
    }
  }

  void select(String? id) {
    emitNormal(currentData.copyWith(selectedId: id));
    _userSettings.saveSelectedPresetId(id);
  }

  Future<SettingsPreset> saveAs(String name, EncodeSettings settings) async {
    final preset = await _repository.saveAs(name, settings);
    final updated = [...currentData.presets, preset]
      ..sort((a, b) {
        if (a.isBuiltIn != b.isBuiltIn) return a.isBuiltIn ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    emitNormal(currentData.copyWith(presets: updated, selectedId: preset.id));
    _userSettings.saveSelectedPresetId(preset.id);
    return preset;
  }

  Future<SettingsPreset> overwrite(String id, EncodeSettings settings) async {
    final preset = await _repository.overwrite(id, settings);
    final updated = currentData.presets
        .map((p) => p.id == id ? preset : p)
        .toList();
    emitNormal(currentData.copyWith(presets: updated));
    return preset;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    final updated = currentData.presets.where((p) => p.id != id).toList();
    final newSelectedId =
        currentData.selectedId == id ? null : currentData.selectedId;
    emitNormal(currentData.copyWith(
      presets: updated,
      selectedId: newSelectedId,
    ));
    if (currentData.selectedId == id) {
      await _userSettings.saveSelectedPresetId(null);
    }
  }
}
