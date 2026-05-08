import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';

@lazySingleton
class PresetDatasource {
  Future<Directory> _dir() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'presets'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<SettingsPreset>> loadUserPresets() async {
    final dir = await _dir();
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .cast<File>()
        .toList();
    final presets = <SettingsPreset>[];
    for (final f in files) {
      try {
        final text = await f.readAsString();
        final json = jsonDecode(text) as Map<String, dynamic>;
        presets.add(SettingsPreset.fromJson(json));
      } catch (e) {
        appLogger.w('PresetDatasource: skipping invalid preset file ${f.path}: $e');
      }
    }
    presets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return presets;
  }

  Future<void> save(SettingsPreset preset) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '${preset.id}.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(preset.toJson()));
  }

  Future<void> delete(String id) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$id.json'));
    if (await file.exists()) {
      await file.delete();
    }
  }
}
