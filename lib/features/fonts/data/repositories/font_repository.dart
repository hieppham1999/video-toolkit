import 'package:video_toolkit/features/fonts/data/models/font_info.dart';

abstract class FontRepository {
  Future<List<FontInfo>> listFonts();
}
