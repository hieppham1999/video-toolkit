import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_toolkit/core/i18n/app_language.dart';
import 'package:video_toolkit/core/theme/app_accent.dart';

part 'generated/app_setting_state.freezed.dart';

@freezed
abstract class AppSettingState with _$AppSettingState {
  const factory AppSettingState({
    @Default(AppAccent.blue) AppAccent accent,
    @Default(AppLanguage.system) AppLanguage language,
    String? defaultFontPath,
  }) = _AppSettingState;
}
