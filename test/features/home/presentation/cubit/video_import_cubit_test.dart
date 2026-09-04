import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/features/home/presentation/cubit/video_import_cubit.dart';
import 'package:video_toolkit/features/home/data/datasources/video_queue_datasource.dart';
import 'package:video_toolkit/features/home/data/models/video_file.dart';
import 'package:video_toolkit/features/video_encoding/data/datasources/user_settings_datasource.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/output_directory_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/user_settings.dart';
import 'package:video_toolkit/features/video_metadata/data/models/video_metadata.dart';
import 'package:video_toolkit/features/video_metadata/data/repositories/video_metadata_repository.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<AppLogger>(AppLogger(Logger(level: Level.off)));
  });

  tearDownAll(GetIt.I.reset);

  test('output override resets independently from encode override', () async {
    final temp = Directory.systemTemp.createTempSync('video-toolkit-import-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final input = File('${temp.path}${Platform.pathSeparator}video.mp4')
      ..writeAsStringSync('video');
    final cubit = VideoImportCubit(
      _FakeMetadataRepository(),
      _FakeUserSettingsDatasource(),
      _FakeVideoQueueDatasource(),
    );
    addTearDown(cubit.close);
    cubit.addFiles([input.path]);
    const encodeOverride = EncodeSettings(crf: 18);
    const outputOverride = OutputDirectorySettings(
      mode: OutputDirectoryMode.custom,
      customPath: '/exports',
    );

    cubit.updateFileSettings(input.path, encodeOverride, 'preset');
    cubit.updateFileOutputDirectory(input.path, outputOverride);

    expect(cubit.currentData.files.single.overrideSettings, encodeOverride);
    expect(
      cubit.currentData.files.single.outputDirectoryOverride,
      outputOverride,
    );

    cubit.updateFileOutputDirectory(input.path, null);

    expect(cubit.currentData.files.single.overrideSettings, encodeOverride);
    expect(cubit.currentData.files.single.outputDirectoryOverride, isNull);
  });

  test('reorders files and persists the new queue order', () async {
    final temp = Directory.systemTemp.createTempSync('video-toolkit-order-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final first = File('${temp.path}${Platform.pathSeparator}first.mp4')
      ..writeAsStringSync('first');
    final second = File('${temp.path}${Platform.pathSeparator}second.mp4')
      ..writeAsStringSync('second');
    final queue = _FakeVideoQueueDatasource();
    final cubit = VideoImportCubit(
      _FakeMetadataRepository(),
      _FakeUserSettingsDatasource(),
      queue,
    );
    addTearDown(cubit.close);

    cubit.addFiles([first.path, second.path]);
    cubit.moveFile(second.path, -1);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.currentData.files.map((file) => file.path), [
      second.path,
      first.path,
    ]);
    expect(queue.saved.map((file) => file.path), [second.path, first.path]);
  });
}

class _FakeVideoQueueDatasource extends VideoQueueDatasource {
  List<VideoFile> saved = const [];

  @override
  Future<List<PersistedVideoQueueItem>> load() async => const [];

  @override
  Future<void> save(List<VideoFile> files) async {
    saved = List.of(files);
  }
}

class _FakeMetadataRepository implements VideoMetadataRepository {
  @override
  Future<VideoMetadata> extractMetadata(String filePath) async =>
      const VideoMetadata();

  @override
  Future<bool> isExiftoolAvailable() async => true;

  @override
  Future<bool> isFfprobeAvailable() async => true;
}

class _FakeUserSettingsDatasource extends UserSettingsDatasource {
  @override
  Future<UserSettings?> load() async => null;

  @override
  Future<void> saveEncodeSettings(EncodeSettings settings) async {}
}
