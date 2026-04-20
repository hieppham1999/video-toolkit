import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @dropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Drop files here'**
  String get dropFilesHere;

  /// No description provided for @dragDropInstructions.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop video files here'**
  String get dragDropInstructions;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported: MP4, MOV, AVI, MKV, WMV, FLV...'**
  String get supportedFormats;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @selectVideoFiles.
  ///
  /// In en, this message translates to:
  /// **'Select video files'**
  String get selectVideoFiles;

  /// No description provided for @videoList.
  ///
  /// In en, this message translates to:
  /// **'Video list'**
  String get videoList;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add video'**
  String get addVideo;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @noVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos yet'**
  String get noVideos;

  /// No description provided for @clearAllConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all videos from the list?'**
  String get clearAllConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @encodeSettings.
  ///
  /// In en, this message translates to:
  /// **'Encode Settings'**
  String get encodeSettings;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @videoPreview.
  ///
  /// In en, this message translates to:
  /// **'Video Preview'**
  String get videoPreview;

  /// No description provided for @columnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get columnName;

  /// No description provided for @columnPath.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get columnPath;

  /// No description provided for @columnSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get columnSize;

  /// No description provided for @columnImported.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get columnImported;

  /// No description provided for @columnOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get columnOutput;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @codec.
  ///
  /// In en, this message translates to:
  /// **'Codec'**
  String get codec;

  /// No description provided for @frameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame Rate'**
  String get frameRate;

  /// No description provided for @aspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Aspect Ratio'**
  String get aspectRatio;

  /// No description provided for @metadataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Metadata not available'**
  String get metadataNotAvailable;

  /// No description provided for @selectVideoToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select a video to preview info'**
  String get selectVideoToPreview;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @burnTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Burn timestamp'**
  String get burnTimestamp;

  /// No description provided for @burnTimestampDescription.
  ///
  /// In en, this message translates to:
  /// **'Overlay the recording date/time onto the video'**
  String get burnTimestampDescription;

  /// No description provided for @overlayType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get overlayType;

  /// No description provided for @overlayTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get overlayTypeCustom;

  /// No description provided for @overlayTypeTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get overlayTypeTimestamp;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fontDefault;

  /// No description provided for @fontBundled.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get fontBundled;

  /// No description provided for @dateTaken.
  ///
  /// In en, this message translates to:
  /// **'Date Taken'**
  String get dateTaken;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @tabFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get tabFile;

  /// No description provided for @tabContainer.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get tabContainer;

  /// No description provided for @tabSizing.
  ///
  /// In en, this message translates to:
  /// **'Sizing'**
  String get tabSizing;

  /// No description provided for @tabFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get tabFilter;

  /// No description provided for @tabAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get tabAudio;

  /// No description provided for @outputName.
  ///
  /// In en, this message translates to:
  /// **'Name template'**
  String get outputName;

  /// No description provided for @outputNameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for default (_encoded suffix)'**
  String get outputNameHint;

  /// No description provided for @outputNamePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get outputNamePreview;

  /// No description provided for @availableTags.
  ///
  /// In en, this message translates to:
  /// **'Available tags'**
  String get availableTags;

  /// No description provided for @resetToGlobal.
  ///
  /// In en, this message translates to:
  /// **'Reset to Global'**
  String get resetToGlobal;

  /// No description provided for @fileExtension.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get fileExtension;

  /// No description provided for @videoCodec.
  ///
  /// In en, this message translates to:
  /// **'Video Codec'**
  String get videoCodec;

  /// No description provided for @encodePreset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get encodePreset;

  /// No description provided for @crf.
  ///
  /// In en, this message translates to:
  /// **'CRF'**
  String get crf;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @sourceSize.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceSize;

  /// No description provided for @afterCrop.
  ///
  /// In en, this message translates to:
  /// **'After crop'**
  String get afterCrop;

  /// No description provided for @textOverlays.
  ///
  /// In en, this message translates to:
  /// **'Text Overlays'**
  String get textOverlays;

  /// No description provided for @addText.
  ///
  /// In en, this message translates to:
  /// **'+ Add Text'**
  String get addText;

  /// No description provided for @textOverlayLabel.
  ///
  /// In en, this message translates to:
  /// **'Text {n}'**
  String textOverlayLabel(int n);

  /// No description provided for @textLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textLabel;

  /// No description provided for @textHintTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Plain text or ffmpeg expression'**
  String get textHintTimestamp;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get fontSize;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @border.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get border;

  /// No description provided for @noBorderHint.
  ///
  /// In en, this message translates to:
  /// **'0 = no border'**
  String get noBorderHint;

  /// No description provided for @borderColor.
  ///
  /// In en, this message translates to:
  /// **'Border Color'**
  String get borderColor;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @audioCodec.
  ///
  /// In en, this message translates to:
  /// **'Audio Codec'**
  String get audioCodec;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @builtIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtIn;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as…'**
  String get saveAs;

  /// No description provided for @deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePreset;

  /// No description provided for @newPresetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get newPresetName;

  /// No description provided for @presetNameHint.
  ///
  /// In en, this message translates to:
  /// **'My preset'**
  String get presetNameHint;

  /// No description provided for @confirmDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset \'{name}\'?'**
  String confirmDeletePreset(String name);

  /// No description provided for @noPresetSelected.
  ///
  /// In en, this message translates to:
  /// **'No preset selected'**
  String get noPresetSelected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
