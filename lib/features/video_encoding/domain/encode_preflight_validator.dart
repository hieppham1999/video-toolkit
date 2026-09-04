import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:video_toolkit/app/languages.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_failure.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';

/// Validates the complete batch before the first expensive encode starts.
@lazySingleton
class EncodePreflightValidator {
  Future<List<EncodeFailure>> validate({
    required List<VideoFile> files,
    required Map<String, String> outputPaths,
    required EncodeSettings Function(VideoFile file) settingsFor,
    required bool ffmpegAvailable,
  }) async {
    final failures = <EncodeFailure>[];
    final l10n = Languages.translate;
    if (!ffmpegAvailable) {
      return [
        EncodeFailure(
          filePath: files.first.path,
          message: l10n.preflightFfmpegMissing,
        ),
      ];
    }

    final writableDirectories = <String, bool>{};
    for (final file in files) {
      final input = File(file.path);
      if (!await input.exists()) {
        failures.add(
          EncodeFailure(
            filePath: file.path,
            message: l10n.preflightInputMissing,
          ),
        );
        continue;
      }
      if (await input.length() == 0) {
        failures.add(
          EncodeFailure(filePath: file.path, message: l10n.preflightInputEmpty),
        );
        continue;
      }

      final settingsError = _settingsError(
        settingsFor(file),
        duration: file.metadata?.duration,
      );
      if (settingsError != null) {
        failures.add(
          EncodeFailure(filePath: file.path, message: settingsError),
        );
        continue;
      }

      final outputPath = outputPaths[file.path];
      if (outputPath == null) {
        failures.add(
          EncodeFailure(
            filePath: file.path,
            message: l10n.preflightOutputUnresolved,
          ),
        );
        continue;
      }
      final directory = p.dirname(outputPath);
      final writable =
          writableDirectories[directory] ?? await _canWriteDirectory(directory);
      writableDirectories[directory] = writable;
      if (!writable) {
        failures.add(
          EncodeFailure(
            filePath: file.path,
            message: l10n.preflightOutputNotWritable(directory),
          ),
        );
      }
    }
    return failures;
  }

  String? _settingsError(EncodeSettings settings, {Duration? duration}) {
    final l10n = Languages.translate;
    if (settings.qualityMode == QualityMode.avgBitrate &&
        settings.avgBitrateKbps <= 0) {
      return l10n.preflightInvalidBitrate;
    }
    if (settings.qualityMode == QualityMode.crf &&
        (settings.crf < 0 || settings.crf > 63)) {
      return l10n.preflightInvalidCrf;
    }
    if (settings.qualityMode == QualityMode.targetSize) {
      if (settings.targetSizeMb <= 0) {
        return l10n.preflightInvalidTargetSize;
      }
      if (duration == null || duration <= Duration.zero) {
        return l10n.preflightTargetSizeDurationMissing;
      }
      if (settings.targetVideoBitrateKbps(duration) < 100) {
        return l10n.preflightTargetSizeTooSmall;
      }
    }
    if (settings.frameRate != null &&
        (!settings.frameRate!.isFinite ||
            settings.frameRate! <= 0 ||
            settings.frameRate! > 240)) {
      return l10n.preflightInvalidFrameRate;
    }
    if (!settings.isVideoProfileSupported) {
      return l10n.preflightIncompatibleVideoProfile;
    }
    if (!settings.audioGainDb.isFinite ||
        settings.audioGainDb < -60 ||
        settings.audioGainDb > 60) {
      return l10n.preflightInvalidAudioGain;
    }
    final resolution = settings.resolution;
    if (resolution != null) {
      final parts = resolution.split(':');
      final width = parts.length == 2 ? int.tryParse(parts[0]) : null;
      final height = parts.length == 2 ? int.tryParse(parts[1]) : null;
      if (width == null || height == null || width <= 0 || height <= 0) {
        return l10n.preflightInvalidResolution;
      }
    }
    if (settings.outputExtension == OutputExtension.webm &&
        settings.codec != VideoEncoder.vp9 &&
        settings.codec != VideoEncoder.av1) {
      return l10n.preflightIncompatibleWebm;
    }
    if (settings.codec == VideoEncoder.prores &&
        settings.outputExtension != OutputExtension.mov &&
        settings.outputExtension != OutputExtension.mkv) {
      return l10n.preflightIncompatibleProres;
    }
    return null;
  }

  Future<bool> _canWriteDirectory(String path) async {
    File? probe;
    try {
      final directory = Directory(path);
      await directory.create(recursive: true);
      probe = File(
        p.join(
          path,
          '.video-toolkit-write-$pid-${DateTime.now().microsecondsSinceEpoch}',
        ),
      );
      await probe.writeAsString('ok', flush: true);
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        if (probe != null && await probe.exists()) await probe.delete();
      } catch (_) {}
    }
  }
}
