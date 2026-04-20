import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats a [DateTime] as `yyyy-MM-dd HH:mm` in local time.
  /// Returns `-` when [dt] is null.
  static String format(DateTime? dt, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    if (dt == null) return '-';
    return DateFormat(pattern).format(dt.toLocal());
  }

  /// Formats a [Duration] as `HH:MM:SS` (or `MM:SS` when under an hour).
  /// Returns `-` when [d] is null.
  static String formatDuration(Duration? d) {
    if (d == null) return '-';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
