// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dropFilesHere => 'Drop files here';

  @override
  String get dragDropInstructions => 'Drag & drop video files here';

  @override
  String get supportedFormats => 'Supported: MP4, MOV, AVI, MKV, WMV, FLV...';

  @override
  String get or => 'or';

  @override
  String get selectVideoFiles => 'Select video files';

  @override
  String get videoList => 'Video list';

  @override
  String get addVideo => 'Add video';

  @override
  String get clearAll => 'Clear all';

  @override
  String get noVideos => 'No videos yet';

  @override
  String get clearAllConfirmMessage =>
      'Are you sure you want to remove all videos from the list?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';
}
