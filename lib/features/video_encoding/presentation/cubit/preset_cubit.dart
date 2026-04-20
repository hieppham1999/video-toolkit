import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/data/repositories/preset_repository.dart';
import 'package:video_toolkit/presentation/base/base_cubit.dart';

import 'preset_state.dart';

@injectable
class PresetCubit extends BaseCubit<PresetState> {
  PresetCubit(this._repository) : super.normal(const PresetState()) {
    loadAll();
  }

  final PresetRepository _repository;

  Future<void> loadAll() async {
    if (currentData.isLoading) return;
    emitNormal(currentData.copyWith(isLoading: true));
    try {
      final presets = await _repository.listAll();
      emitNormal(currentData.copyWith(presets: presets, isLoading: false));
    } catch (e) {
      appLogger.w('PresetCubit: failed to load presets: $e');
      emitNormal(currentData.copyWith(isLoading: false));
    }
  }

  void select(String? id) {
    emitNormal(currentData.copyWith(selectedId: id));
  }

  Future<SettingsPreset> saveAs(String name, EncodeSettings settings) async {
    final preset = await _repository.saveAs(name, settings);
    final updated = [...currentData.presets, preset]
      ..sort((a, b) {
        if (a.isBuiltIn != b.isBuiltIn) return a.isBuiltIn ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    emitNormal(currentData.copyWith(presets: updated, selectedId: preset.id));
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
    emitNormal(currentData.copyWith(
      presets: updated,
      selectedId: currentData.selectedId == id ? null : currentData.selectedId,
    ));
  }
}
