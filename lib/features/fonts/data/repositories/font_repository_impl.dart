import 'package:injectable/injectable.dart';
import 'package:video_toolkit/features/fonts/data/datasources/bundled_font_datasource.dart';
import 'package:video_toolkit/features/fonts/data/datasources/system_font_datasource.dart';
import 'package:video_toolkit/features/fonts/data/models/font_info.dart';
import 'package:video_toolkit/features/fonts/data/repositories/font_repository.dart';

@LazySingleton(as: FontRepository)
class FontRepositoryImpl implements FontRepository {
  FontRepositoryImpl(this._system, this._bundled);

  final SystemFontDatasource _system;
  final BundledFontDatasource _bundled;

  List<FontInfo>? _cache;

  @override
  Future<List<FontInfo>> listFonts() async {
    if (_cache != null) return _cache!;

    final results = await Future.wait([
      _system.list(),
      _bundled.list(),
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
}
