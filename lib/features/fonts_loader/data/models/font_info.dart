import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/font_info.freezed.dart';

@freezed
abstract class FontInfo with _$FontInfo {
  const factory FontInfo({
    required String name,
    required String path,
    @Default(false) bool isBundled,
  }) = _FontInfo;
}
