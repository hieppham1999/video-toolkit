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

  @override
  String get encodeSettings => 'Encode Settings';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get videoPreview => 'Video Preview';

  @override
  String get columnName => 'Name';

  @override
  String get columnPath => 'Path';

  @override
  String get columnSize => 'Size';

  @override
  String get columnImported => 'Imported';

  @override
  String get resolution => 'Resolution';

  @override
  String get codec => 'Codec';

  @override
  String get frameRate => 'Frame Rate';

  @override
  String get aspectRatio => 'Aspect Ratio';

  @override
  String get metadataNotAvailable => 'Metadata not available';

  @override
  String get selectVideoToPreview => 'Select a video to preview info';

  @override
  String get save => 'Save';

  @override
  String get burnTimestamp => 'Burn timestamp';

  @override
  String get burnTimestampDescription =>
      'Overlay the recording date/time onto the video';

  @override
  String get overlayType => 'Type';

  @override
  String get overlayTypeCustom => 'Custom';

  @override
  String get overlayTypeTimestamp => 'Timestamp';
}
