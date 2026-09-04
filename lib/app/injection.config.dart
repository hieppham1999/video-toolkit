// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:video_toolkit/app/injection.dart' as _i747;
import 'package:video_toolkit/core/cli/bundled_binary_resolver.dart' as _i753;
import 'package:video_toolkit/core/cli/cli_tool_runner.dart' as _i297;
import 'package:video_toolkit/core/cli/cli_tool_runner_impl.dart' as _i873;
import 'package:video_toolkit/core/system/system_power_service.dart' as _i737;
import 'package:video_toolkit/core/utils/app_logger.dart' as _i70;
import 'package:video_toolkit/features/app_settings/presentation/cubit/app_setting_cubit.dart'
    as _i762;
import 'package:video_toolkit/features/fonts_loader/data/datasources/bundled_font_datasource.dart'
    as _i393;
import 'package:video_toolkit/features/fonts_loader/data/datasources/system_font_datasource.dart'
    as _i814;
import 'package:video_toolkit/features/fonts_loader/data/font_resolver.dart'
    as _i702;
import 'package:video_toolkit/features/fonts_loader/data/repositories/font_repository.dart'
    as _i175;
import 'package:video_toolkit/features/fonts_loader/data/repositories/font_repository_impl.dart'
    as _i1005;
import 'package:video_toolkit/features/fonts_loader/presentation/cubit/font_cubit.dart'
    as _i1070;
import 'package:video_toolkit/features/home/data/datasources/video_queue_datasource.dart'
    as _i84;
import 'package:video_toolkit/features/home/presentation/cubit/preview_cubit.dart'
    as _i883;
import 'package:video_toolkit/features/home/presentation/cubit/video_import_cubit.dart'
    as _i709;
import 'package:video_toolkit/features/video_encoding/data/datasources/encode_failure_log_writer.dart'
    as _i956;
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart'
    as _i1066;
import 'package:video_toolkit/features/video_encoding/data/datasources/preset_datasource.dart'
    as _i1063;
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart'
    as _i1056;
import 'package:video_toolkit/features/video_encoding/data/repositories/preset_repository.dart'
    as _i337;
import 'package:video_toolkit/features/video_encoding/data/repositories/preset_repository_impl.dart'
    as _i1016;
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart'
    as _i954;
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository_impl.dart'
    as _i848;
import 'package:video_toolkit/features/video_encoding/domain/encode_preflight_validator.dart'
    as _i38;
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart'
    as _i657;
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart'
    as _i987;
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart'
    as _i675;
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart'
    as _i735;
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart'
    as _i993;
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository_impl.dart'
    as _i996;
import 'package:video_toolkit/features/video_metadata/presentation/cubit/video_metadata_cubit.dart'
    as _i19;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final loggerModule = _$LoggerModule();
    gh.lazySingleton<_i753.BundledBinaryResolver>(
      () => _i753.BundledBinaryResolver(),
    );
    gh.lazySingleton<_i814.SystemFontDatasource>(
      () => _i814.SystemFontDatasource(),
    );
    gh.lazySingleton<_i393.BundledFontDatasource>(
      () => _i393.BundledFontDatasource(),
    );
    gh.lazySingleton<_i1056.UserSettingsDatasource>(
      () => _i1056.UserSettingsDatasource(),
    );
    gh.lazySingleton<_i1063.PresetDatasource>(() => _i1063.PresetDatasource());
    gh.lazySingleton<_i956.EncodeFailureLogWriter>(
      () => _i956.EncodeFailureLogWriter(),
    );
    gh.lazySingleton<_i84.VideoQueueDatasource>(
      () => _i84.VideoQueueDatasource(),
    );
    gh.lazySingleton<_i38.EncodePreflightValidator>(
      () => _i38.EncodePreflightValidator(),
    );
    gh.lazySingleton<_i762.AppSettingCubit>(
      () => _i762.AppSettingCubit(gh<_i1056.UserSettingsDatasource>()),
    );
    gh.lazySingleton<_i974.Logger>(
      () => loggerModule.devLogger,
      registerFor: {_dev},
    );
    gh.lazySingleton<_i737.SystemCommandRunner>(
      () => _i737.DartSystemCommandRunner(),
    );
    gh.lazySingleton<_i737.SystemPowerService>(
      () => _i737.SystemPowerServiceImpl(gh<_i737.SystemCommandRunner>()),
    );
    gh.lazySingleton<_i297.CliToolRunner>(
      () => _i873.CliToolRunnerImpl(gh<_i753.BundledBinaryResolver>()),
    );
    gh.lazySingleton<_i175.FontRepository>(
      () => _i1005.FontRepositoryImpl(
        gh<_i814.SystemFontDatasource>(),
        gh<_i393.BundledFontDatasource>(),
      ),
    );
    gh.lazySingleton<_i974.Logger>(
      () => loggerModule.prodLogger,
      registerFor: {_prod},
    );
    gh.lazySingleton<_i337.PresetRepository>(
      () => _i1016.PresetRepositoryImpl(gh<_i1063.PresetDatasource>()),
    );
    gh.lazySingleton<_i1066.FfmpegDatasource>(
      () => _i1066.FfmpegDatasource(
        gh<_i297.CliToolRunner>(),
        gh<_i753.BundledBinaryResolver>(),
      ),
    );
    gh.lazySingleton<_i1070.FontCubit>(
      () => _i1070.FontCubit(gh<_i175.FontRepository>()),
    );
    gh.lazySingleton<_i657.PresetCubit>(
      () => _i657.PresetCubit(
        gh<_i337.PresetRepository>(),
        gh<_i1056.UserSettingsDatasource>(),
      ),
    );
    gh.lazySingleton<_i883.PreviewCubit>(
      () => _i883.PreviewCubit(gh<_i1066.FfmpegDatasource>()),
    );
    gh.lazySingleton<_i702.FontResolver>(
      () => _i702.FontResolver(
        gh<_i393.BundledFontDatasource>(),
        gh<_i1056.UserSettingsDatasource>(),
      ),
    );
    gh.lazySingleton<_i735.FfprobeDatasource>(
      () => _i735.FfprobeDatasource(gh<_i297.CliToolRunner>()),
    );
    gh.lazySingleton<_i675.ExiftoolDatasource>(
      () => _i675.ExiftoolDatasource(gh<_i297.CliToolRunner>()),
    );
    gh.lazySingleton<_i954.VideoEncodeRepository>(
      () => _i848.VideoEncodeRepositoryImpl(
        gh<_i1066.FfmpegDatasource>(),
        gh<_i702.FontResolver>(),
        gh<_i735.FfprobeDatasource>(),
      ),
    );
    gh.lazySingleton<_i987.VideoEncodeCubit>(
      () => _i987.VideoEncodeCubit(
        gh<_i954.VideoEncodeRepository>(),
        gh<_i883.PreviewCubit>(),
        gh<_i675.ExiftoolDatasource>(),
        gh<_i38.EncodePreflightValidator>(),
      ),
    );
    gh.lazySingleton<_i993.VideoMetadataRepository>(
      () => _i996.VideoMetadataRepositoryImpl(
        gh<_i675.ExiftoolDatasource>(),
        gh<_i735.FfprobeDatasource>(),
      ),
    );
    gh.lazySingleton<_i19.VideoMetadataCubit>(
      () => _i19.VideoMetadataCubit(gh<_i993.VideoMetadataRepository>()),
    );
    gh.lazySingleton<_i709.VideoImportCubit>(
      () => _i709.VideoImportCubit(
        gh<_i993.VideoMetadataRepository>(),
        gh<_i1056.UserSettingsDatasource>(),
        gh<_i84.VideoQueueDatasource>(),
      ),
    );
    gh.singleton<_i70.AppLogger>(() => _i70.AppLogger(gh<_i974.Logger>()));
    return this;
  }
}

class _$LoggerModule extends _i747.LoggerModule {}
