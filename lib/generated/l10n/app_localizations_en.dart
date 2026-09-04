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
  String get remove => 'Remove';

  @override
  String get removeAll => 'Remove all';

  @override
  String get revealInputInFolder => 'Show input in folder';

  @override
  String get revealOutputInFolder => 'Show output in folder';

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
  String get noPresetSelected => 'No preset selected';

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
  String get columnSetting => 'Setting';

  @override
  String get presetModifiedTooltipTitle => 'Modified from preset:';

  @override
  String get perFileSettingsOverrideTooltip =>
      'This file uses per-file settings overriding the global settings';

  @override
  String get columnSize => 'Size';

  @override
  String get columnImported => 'Imported';

  @override
  String get columnOutput => 'Output';

  @override
  String get columnOutputSize => 'Output Size';

  @override
  String get columnSizeRatio => 'Ratio';

  @override
  String get columnStatus => 'Status';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusFailed => 'Failed';

  @override
  String queueEncodingProgress(int current, int total) {
    return 'Encoding $current / $total';
  }

  @override
  String queueDoneProgress(int completed, int total) {
    return 'Done — $completed / $total completed';
  }

  @override
  String queueErrorProgress(int completed, int failed) {
    return '$completed completed, $failed failed';
  }

  @override
  String remainingTime(String time) {
    return 'Remaining $time';
  }

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

  @override
  String get font => 'Font';

  @override
  String get fontDefault => 'Default';

  @override
  String get fontBundled => 'App';

  @override
  String get dateTaken => 'Date Taken';

  @override
  String get duration => 'Duration';

  @override
  String get tabFile => 'File';

  @override
  String get tabContainer => 'Container';

  @override
  String get tabVideoCodec => 'Video Codec';

  @override
  String get tabSizing => 'Sizing';

  @override
  String get tabFilter => 'Filter';

  @override
  String get tabSubtitle => 'Subtitle';

  @override
  String get tabAudio => 'Audio';

  @override
  String get embedTimestampSubtitle => 'Embed timestamp subtitle';

  @override
  String get embedTimestampSubtitleDescription =>
      'Add the video timestamp as a selectable subtitle track named timestamp';

  @override
  String get subtitleUnsupportedContainer =>
      'Timestamp subtitles are supported for MP4, MOV and MKV only';

  @override
  String get quality => 'Quality';

  @override
  String get avgBitrateKbps => 'Avg bitrate (kbps)';

  @override
  String get constantQuality => 'Constant quality';

  @override
  String get twoPassEncoding => 'Two-pass encoding';

  @override
  String get copySourceMetadata => 'Copy metadata from source';

  @override
  String get sourceTimezone => 'Source timezone';

  @override
  String get sourceTimezoneAuto => 'Auto (system)';

  @override
  String get overlayShowTimezone => 'Show timezone after time';

  @override
  String get webOptimized => 'Web Optimized (MP4 faststart)';

  @override
  String get turboFirstPass => 'Turbo first pass';

  @override
  String get moreSettings => 'More settings';

  @override
  String get moreSettingsHintX265 => 'e.g. keyint=60:bframes=3';

  @override
  String get moreSettingsHintX264 => 'e.g. keyint=60:bframes=3';

  @override
  String get moreSettingsHintVpx => 'e.g. -row-mt 1 -tile-columns 2';

  @override
  String get outputName => 'Name template';

  @override
  String get outputNameHint => 'Leave empty for default (_encoded suffix)';

  @override
  String get outputNamePreview => 'Preview';

  @override
  String get availableTags => 'Available tags';

  @override
  String get resetToGlobal => 'Reset to Global';

  @override
  String get fileExtension => 'Extension';

  @override
  String get videoCodec => 'Video Codec';

  @override
  String get encodePreset => 'Preset';

  @override
  String get crf => 'CRF';

  @override
  String get deinterlace => 'Deinterlace';

  @override
  String get deinterlaceOff => 'Off';

  @override
  String get deinterlaceYadifFrame => 'Yadif (frame)';

  @override
  String get deinterlaceYadifField => 'Yadif (field, 2×fps)';

  @override
  String get deinterlaceBwdifFrame => 'Bwdif (frame)';

  @override
  String get deinterlaceBwdifField => 'Bwdif (field, 2×fps)';

  @override
  String get original => 'Original';

  @override
  String get sourceSize => 'Source';

  @override
  String get afterCrop => 'After crop';

  @override
  String get rotation => 'Rotation';

  @override
  String get rotationNone => 'None';

  @override
  String get rotation90Cw => '90° clockwise';

  @override
  String get rotation180 => '180°';

  @override
  String get rotation90Ccw => '90° counter-clockwise';

  @override
  String get displayRotateOnly => 'Display rotate only';

  @override
  String get displayRotateTooltip =>
      'Only writes rotation metadata; pixels are not re-encoded. Faster, but depends on player support and works best with MP4/MOV.';

  @override
  String get flipHorizontal => 'Flip horizontally';

  @override
  String get flipVertical => 'Flip vertically';

  @override
  String get textOverlays => 'Text Overlays';

  @override
  String get addText => '+ Add Text';

  @override
  String textOverlayLabel(int n) {
    return 'Text $n';
  }

  @override
  String get textLabel => 'Text';

  @override
  String get textHintTimestamp => 'Plain text or ffmpeg expression';

  @override
  String get fontSize => 'Size';

  @override
  String get color => 'Color';

  @override
  String get border => 'Border';

  @override
  String get noBorderHint => '0 = no border';

  @override
  String get borderColor => 'Border Color';

  @override
  String get position => 'Position';

  @override
  String get offsetX => 'Offset X';

  @override
  String get offsetY => 'Offset Y';

  @override
  String get offsetHint => 'Pixels from anchor';

  @override
  String get audioCodec => 'Audio Codec';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get presets => 'Presets';

  @override
  String get builtIn => 'Built-in';

  @override
  String get saveAs => 'Save as…';

  @override
  String get deletePreset => 'Delete';

  @override
  String get newPresetName => 'Preset name';

  @override
  String get presetNameHint => 'My preset';

  @override
  String confirmDeletePreset(String name) {
    return 'Delete preset \'$name\'?';
  }

  @override
  String get revert => 'Revert';

  @override
  String revertConfirm(String name) {
    return 'Revert all changes to preset \'\'$name\'\'?';
  }

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get importPresetNamePrompt =>
      'Save imported settings as preset? Leave empty to load without saving.';

  @override
  String get importFailed =>
      'Failed to import settings. File is invalid or unreadable.';

  @override
  String get importError => 'Import Error';

  @override
  String get exportSuccess => 'Settings exported';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accentColor => 'Accent color';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentPink => 'Pink';

  @override
  String get accentRed => 'Red';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentYellow => 'Yellow';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentTeal => 'Teal';

  @override
  String get accentGraphite => 'Graphite';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get defaultFont => 'Default font';

  @override
  String get previewNoSelection => 'Select a video to preview';

  @override
  String get previewLoadingFrame => 'Generating preview…';

  @override
  String get previewLiveBadge => 'LIVE';

  @override
  String get previewFrameError => 'Preview unavailable';

  @override
  String get cliTools => 'CLI Tools';

  @override
  String get cliToolSelectTool => 'Tool';

  @override
  String get cliToolPresets => 'Presets';

  @override
  String get cliToolCommand => 'Command';

  @override
  String get cliToolOutput => 'Output';

  @override
  String get cliToolExecute => 'Execute';

  @override
  String get cliToolStop => 'Stop';

  @override
  String get cliToolRunning => 'Running…';

  @override
  String cliToolExitCode(int code) {
    return 'Exit code: $code';
  }

  @override
  String get cliToolCopy => 'Copy';

  @override
  String get cliToolClear => 'Clear';

  @override
  String get cliToolNoOutput =>
      'No output yet. Click Execute to run the command.';

  @override
  String get cliToolCopied => 'Copied';

  @override
  String get cliToolFormatRaw => 'Raw';

  @override
  String get cliToolFormatJson => 'JSON';

  @override
  String get outputDirectory => 'Output directory';

  @override
  String get output => 'Output';

  @override
  String get setOutputDirectory => 'Set output directory';

  @override
  String get useGlobalOutputDirectory => 'Use global output directory';

  @override
  String get perFileOutputOverrideTooltip =>
      'This file uses its own output directory';

  @override
  String get outputDirSameAsSource => 'Same as source file';

  @override
  String get outputDirCustom => 'Custom directory';

  @override
  String get outputDirSubfolder => 'Save into sub-folder';

  @override
  String get outputDirSubfolderHint => 'Sub-folder name';

  @override
  String get outputDirChooseFolder => 'Choose folder…';

  @override
  String get outputDirPreview => 'Preview';

  @override
  String get outputDirCustomNotSet => 'No folder selected';

  @override
  String get outputDirCustomRequired =>
      'Choose a custom output directory before saving.';

  @override
  String get outputDirSubfolderRequired =>
      'Enter a sub-folder name before saving.';

  @override
  String get settingsTabGeneral => 'General';

  @override
  String get settingsTabFileHandling => 'File Handling';

  @override
  String get settingsTabAbout => 'About';

  @override
  String get aboutAuthor => 'Author';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutAppName => 'Video Toolkit';

  @override
  String get encodeCompletedTitle => 'Encoding complete';

  @override
  String encodeCompletedSummary(int count) {
    return '$count video(s) encoded successfully.';
  }

  @override
  String get encodeErrorsTitle => 'Encoding failed';

  @override
  String encodeErrorsSummary(int count) {
    return '$count file(s) failed to encode. Details below:';
  }

  @override
  String get afterQueue => 'After queue';

  @override
  String get queueActionNone => 'Do nothing';

  @override
  String get queueActionShutdown => 'Shut down';

  @override
  String get queueActionRestart => 'Restart';

  @override
  String get queueActionSleep => 'Sleep';

  @override
  String get powerCountdownTitle => 'Queue complete';

  @override
  String powerCountdownMessage(String action, int seconds) {
    return '$action in $seconds seconds.';
  }

  @override
  String powerCountdownLogPath(String path) {
    return 'Error log: $path';
  }

  @override
  String get executeNow => 'Execute now';

  @override
  String get powerActionFailedTitle => 'Power action failed';

  @override
  String get powerActionFailedMessage =>
      'The requested system action could not be completed.';

  @override
  String get failureLogUpdateFailedTitle => 'Could not update error log';

  @override
  String get failureLogUpdateFailedMessage =>
      'The power action was cancelled because the latest queue log could not be updated.';

  @override
  String failureLogSavedAt(String path) {
    return 'Error log saved at: $path';
  }

  @override
  String get errorDetails => 'Details';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get close => 'Close';
}
