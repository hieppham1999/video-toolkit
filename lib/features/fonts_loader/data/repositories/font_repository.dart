import 'package:video_toolkit/features/fonts_loader/data/models/font_info.dart';

abstract class FontRepository {
  Future<List<FontInfo>> listFonts();
}
