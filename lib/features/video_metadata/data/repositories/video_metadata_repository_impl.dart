import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/exiftool_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/datasources/ffprobe_datasource.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';

@LazySingleton(as: VideoMetadataRepository)
class VideoMetadataRepositoryImpl implements VideoMetadataRepository {
  VideoMetadataRepositoryImpl(this._exiftool, this._ffprobe);

  final ExiftoolDatasource _exiftool;
  final FfprobeDatasource _ffprobe;

  @override
  Future<VideoMetadata> extractMetadata(String filePath) async {
    // Keep both extractors independent. A timeout/error from ffprobe must not
    // prevent exiftool from supplying FileCreateDate for timestamp filenames.
    final results = await Future.wait([
      _extractSafely('ffprobe', () => _ffprobe.extract(filePath)),
      _extractSafely('exiftool', () => _exiftool.extract(filePath)),
    ]);
    final ffprobeData = results[0] ?? const VideoMetadata();
    final exiftoolData = results[1];
    final extractedCreationDate =
        exiftoolData?.creationDate ?? ffprobeData.creationDate;
    final nativeFileCreateDate = extractedCreationDate == null
        ? await _readWindowsFileCreateDate(filePath)
        : null;

    return ffprobeData.copyWith(
      // Do not discard a valid ffprobe date when exiftool has no matching
      // creation-date tag (or cannot parse it).
      creationDate: extractedCreationDate ?? nativeFileCreateDate,
      creationDateFromFileSystem: exiftoolData?.creationDate != null
          ? exiftoolData!.creationDateFromFileSystem
          : nativeFileCreateDate != null,
      timezoneOffset:
          exiftoolData?.timezoneOffset ??
          ffprobeData.timezoneOffset ??
          _formatOffset(nativeFileCreateDate?.timeZoneOffset),
      gpsLatitude: ffprobeData.gpsLatitude ?? exiftoolData?.gpsLatitude,
      gpsLongitude: ffprobeData.gpsLongitude ?? exiftoolData?.gpsLongitude,
      cameraModel: ffprobeData.cameraModel ?? exiftoolData?.cameraModel,
    );
  }

  Future<VideoMetadata?> _extractSafely(
    String source,
    Future<VideoMetadata?> Function() extract,
  ) async {
    try {
      return await extract();
    } catch (e, stackTrace) {
      appLogger.e('$source metadata extraction failed', e, stackTrace);
      return null;
    }
  }

  /// Dart exposes the filesystem creation timestamp as [FileStat.changed] on
  /// Windows. This is the same system timestamp reported by exiftool as
  /// FileCreateDate, and remains available if either CLI extractor fails.
  Future<DateTime?> _readWindowsFileCreateDate(String filePath) async {
    if (!Platform.isWindows) return null;
    try {
      final stat = await File(filePath).stat();
      return stat.type == FileSystemEntityType.notFound ? null : stat.changed;
    } catch (e) {
      appLogger.w('Unable to read native FileCreateDate for $filePath: $e');
      return null;
    }
  }

  String? _formatOffset(Duration? offset) {
    if (offset == null) return null;
    final sign = offset.isNegative ? '-' : '+';
    final absolute = offset.abs();
    final hours = absolute.inHours.toString().padLeft(2, '0');
    final minutes = (absolute.inMinutes % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }

  @override
  Future<bool> isExiftoolAvailable() => _exiftool.isAvailable;

  @override
  Future<bool> isFfprobeAvailable() => _ffprobe.isAvailable;
}
