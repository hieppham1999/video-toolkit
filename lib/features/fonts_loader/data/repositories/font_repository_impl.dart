import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/datasources/bundled_font_datasource.dart';
import 'package:video_toolkit/features/fonts_loader/data/datasources/system_font_datasource.dart';
import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts_loader/data/repositories/font_repository.dart';

@LazySingleton(as: FontRepository)
class FontRepositoryImpl implements FontRepository {
  FontRepositoryImpl(this._system, this._bundled);

  final SystemFontDatasource _system;
  final BundledFontDatasource _bundled;

  List<FontInfo>? _cache;

  @override
  Future<List<FontInfo>> listFonts() async {
    if (_cache != null) return _cache!;

    // Isolate each source: one throwing (e.g. system font scan hitting a
    // permission error on Windows) must not drop the other's results —
    // bundled fonts are the only ones surfaced in the settings picker.
    final results = await Future.wait([
      _safeList('system', _system.list),
      _safeList('bundled', _bundled.list),
    ]);
    final system = results[0];
    final bundled = results[1];

    final seenNames = <String>{};
    final merged = <FontInfo>[];
    for (final f in [...system, ...bundled]) {
      final key = f.name.toLowerCase();
      if (seenNames.add(key)) merged.add(f);
    }

    _cache = merged;
    return merged;
  }

  Future<List<FontInfo>> _safeList(
    String label,
    Future<List<FontInfo>> Function() fn,
  ) async {
    try {
      return await fn();
    } catch (e, st) {
      appLogger.w('FontRepositoryImpl: $label font source failed: $e\n$st');
      return const [];
    }
  }
}
