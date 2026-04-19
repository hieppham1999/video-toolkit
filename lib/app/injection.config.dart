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
import 'package:video_toolkit/core/utils/app_logger.dart' as _i70;
import 'package:video_toolkit/features/fonts/data/datasources/bundled_font_datasource.dart'
    as _i465;
import 'package:video_toolkit/features/fonts/data/datasources/system_font_datasource.dart'
    as _i894;
import 'package:video_toolkit/features/fonts/data/repositories/font_repository.dart'
    as _i234;
import 'package:video_toolkit/features/fonts/data/repositories/font_repository_impl.dart'
    as _i710;
import 'package:video_toolkit/features/fonts/presentation/cubit/font_cubit.dart'
    as _i739;
import 'package:video_toolkit/features/video_encoding/data/datasources/ffmpeg_datasource.dart'
    as _i1066;
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository.dart'
    as _i954;
import 'package:video_toolkit/features/video_encoding/data/repositories/video_encode_repository_impl.dart'
    as _i848;
import 'package:video_toolkit/features/video_encoding/presentation/cubit/video_encode_cubit.dart'
    as _i987;
import 'package:video_toolkit/features/video_import/presentation/cubit/video_import_cubit.dart'
    as _i1027;
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
    gh.lazySingleton<_i894.SystemFontDatasource>(
      () => _i894.SystemFontDatasource(),
    );
    gh.lazySingleton<_i465.BundledFontDatasource>(
      () => _i465.BundledFontDatasource(),
    );
    gh.lazySingleton<_i974.Logger>(
      () => loggerModule.devLogger,
      registerFor: {_dev},
    );
    gh.lazySingleton<_i297.CliToolRunner>(
      () => _i873.CliToolRunnerImpl(gh<_i753.BundledBinaryResolver>()),
    );
    gh.lazySingleton<_i974.Logger>(
      () => loggerModule.prodLogger,
      registerFor: {_prod},
    );
    gh.lazySingleton<_i1066.FfmpegDatasource>(
      () => _i1066.FfmpegDatasource(
        gh<_i297.CliToolRunner>(),
        gh<_i753.BundledBinaryResolver>(),
      ),
    );
    gh.lazySingleton<_i234.FontRepository>(
      () => _i710.FontRepositoryImpl(
        gh<_i894.SystemFontDatasource>(),
        gh<_i465.BundledFontDatasource>(),
      ),
    );
    gh.lazySingleton<_i954.VideoEncodeRepository>(
      () => _i848.VideoEncodeRepositoryImpl(gh<_i1066.FfmpegDatasource>()),
    );
    gh.factory<_i987.VideoEncodeCubit>(
      () => _i987.VideoEncodeCubit(gh<_i954.VideoEncodeRepository>()),
    );
    gh.lazySingleton<_i735.FfprobeDatasource>(
      () => _i735.FfprobeDatasource(gh<_i297.CliToolRunner>()),
    );
    gh.lazySingleton<_i675.ExiftoolDatasource>(
      () => _i675.ExiftoolDatasource(gh<_i297.CliToolRunner>()),
    );
    gh.factory<_i739.FontCubit>(
      () => _i739.FontCubit(gh<_i234.FontRepository>()),
    );
    gh.lazySingleton<_i993.VideoMetadataRepository>(
      () => _i996.VideoMetadataRepositoryImpl(
        gh<_i675.ExiftoolDatasource>(),
        gh<_i735.FfprobeDatasource>(),
      ),
    );
    gh.factory<_i1027.VideoImportCubit>(
      () => _i1027.VideoImportCubit(gh<_i993.VideoMetadataRepository>()),
    );
    gh.factory<_i19.VideoMetadataCubit>(
      () => _i19.VideoMetadataCubit(gh<_i993.VideoMetadataRepository>()),
    );
    gh.singleton<_i70.AppLogger>(() => _i70.AppLogger(gh<_i974.Logger>()));
    return this;
  }
}

class _$LoggerModule extends _i747.LoggerModule {}
