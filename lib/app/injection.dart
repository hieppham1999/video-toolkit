import 'package:video_toolkit/app/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  asExtension: true, // default
)
Future<void> configureDependencies(String environment) async {
  getIt.init(environment: environment);
  await getIt.allReady();

}

@module
abstract class LoggerModule {
  @prod
  @lazySingleton
  Logger get prodLogger => Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      colors: false,
      printEmojis: false,
    ),
  );

  @dev
  @lazySingleton
  Logger get devLogger => Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      colors: true,
      printEmojis: false,
    ),
  );
}
