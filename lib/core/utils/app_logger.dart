import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

AppLogger get appLogger => GetIt.I<AppLogger>();

@Order(1)
@singleton
class AppLogger {
  final Logger _logger;

  AppLogger(this._logger);

  void d(dynamic message) => _logger.d(message);
  void i(dynamic message) => _logger.i(message);
  void w(dynamic message) => _logger.w(message);
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
