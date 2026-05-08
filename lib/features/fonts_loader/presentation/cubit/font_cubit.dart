import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/fonts_loader/data/repositories/font_repository.dart';
import 'package:video_toolkit/app/base/base_cubit.dart';

import 'font_state.dart';

@lazySingleton
class FontCubit extends BaseCubit<FontState> {
  FontCubit(this._repository) : super.normal(const FontState()) {
    loadFonts();
  }

  final FontRepository _repository;

  Future<void> loadFonts() async {
    if (currentData.isLoading) return;
    emitNormal(currentData.copyWith(isLoading: true));
    try {
      final fonts = await _repository.listFonts();
      emitNormal(currentData.copyWith(fonts: fonts, isLoading: false));
      appLogger.i('FontCubit: loaded ${fonts.length} fonts');
    } catch (e) {
      appLogger.w('FontCubit: failed to load fonts: $e');
      emitNormal(currentData.copyWith(isLoading: false));
    }
  }
}
