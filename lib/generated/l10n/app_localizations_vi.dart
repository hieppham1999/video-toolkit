// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get dropFilesHere => 'Thả file vào đây';

  @override
  String get dragDropInstructions => 'Kéo & thả file video vào đây';

  @override
  String get supportedFormats => 'Hỗ trợ: MP4, MOV, AVI, MKV, WMV, FLV...';

  @override
  String get or => 'hoặc';

  @override
  String get selectVideoFiles => 'Chọn file video';

  @override
  String get videoList => 'Danh sách video';

  @override
  String get addVideo => 'Thêm video';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get noVideos => 'Chưa có video nào';

  @override
  String get clearAllConfirmMessage =>
      'Bạn có chắc muốn xóa tất cả video khỏi danh sách?';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';
}
