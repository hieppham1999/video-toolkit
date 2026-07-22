/// Resolves user-defined filename templates with date tags.
///
/// Supported tags:
/// - `{name}` — original filename without extension
/// - `{year}`, `{month}`, `{day}` — from video's creation date (zero-padded)
/// - `{hour}`, `{minute}`, `{second}` — from video's creation date (zero-padded)
///
/// Date tags resolve from the video's `creationDate` metadata. If that metadata
/// is not available, date tags are replaced with an empty string. A template
/// that then produces no meaningful filename falls back to
/// `<originalName>_encoded` rather than returning an empty/punctuation-only
/// name.
class FilenameTemplate {
  /// All supported tag names for UI display.
  static const tags = [
    'name',
    'year',
    'month',
    'day',
    'hour',
    'minute',
    'second',
  ];

  /// Date-dependent tags (all except `{name}`).
  static const dateTags = ['year', 'month', 'day', 'hour', 'minute', 'second'];

  /// Applies [template] using [originalName] and [creationDate].
  /// If [template] is empty, returns `${originalName}_encoded` (default).
  /// If [creationDate] is null, date tags resolve to an empty string. If the
  /// result is empty or contains only common separators, returns
  /// `${originalName}_encoded`.
  ///
  /// [sourceTimezoneOffset] (e.g. "+09:00") shifts [creationDate] into that
  /// timezone before extracting tag values — so the filename reflects the
  /// recording's local wall-clock in the source's TZ rather than the encode
  /// machine's local TZ. Null = use the machine's local TZ (legacy behavior).
  ///
  /// When [creationDateFromFileSystem] is true and the template uses date
  /// tags, `_FILEDATE` is appended to show that the timestamp came from the
  /// file creation time rather than embedded recording metadata.
  static String apply(
    String template, {
    required String originalName,
    DateTime? creationDate,
    bool creationDateFromFileSystem = false,
    String? sourceTimezoneOffset,
  }) {
    if (template.trim().isEmpty) return '${originalName}_encoded';

    // Do not render a partial date template (for example `_VID`) while
    // metadata is still loading or when neither embedded nor FileCreateDate is
    // available. Once a date arrives, callers rebuild and render the requested
    // timestamp normally.
    final usesDateTags = dateTags.any((tag) => template.contains('{$tag}'));
    if (creationDate == null && usesDateTags) {
      return '${originalName}_encoded';
    }

    final map = <String, String>{'name': originalName};
    if (creationDate != null) {
      final d = _shiftDate(creationDate, sourceTimezoneOffset);
      map['year'] = d.year.toString().padLeft(4, '0');
      map['month'] = d.month.toString().padLeft(2, '0');
      map['day'] = d.day.toString().padLeft(2, '0');
      map['hour'] = d.hour.toString().padLeft(2, '0');
      map['minute'] = d.minute.toString().padLeft(2, '0');
      map['second'] = d.second.toString().padLeft(2, '0');
    } else {
      for (final t in dateTags) {
        map[t] = '';
      }
    }

    var result = template;
    map.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });

    if (creationDateFromFileSystem &&
        creationDate != null &&
        usesDateTags &&
        !result.toUpperCase().endsWith('_FILEDATE')) {
      result = '${result}_FILEDATE';
    }

    // A date-only template such as
    // `{year}-{month}-{day}_{hour}-{minute}-{second}` becomes `--_--` when the
    // source has no creation date. Never pass that through as an output name.
    final meaningfulPart = result.replaceAll(RegExp(r'[-_.\s]'), '');
    return meaningfulPart.isEmpty ? '${originalName}_encoded' : result;
  }

  /// When [offset] is null, falls back to the machine's local TZ. When set
  /// (e.g. "+09:00"), shifts [date] from UTC to that offset and returns a
  /// DateTime whose components reflect the wall-clock in that TZ.
  static DateTime _shiftDate(DateTime date, String? offset) {
    if (offset == null) return date.toLocal();
    final parsed = _parseOffset(offset);
    if (parsed == null) return date.toLocal();
    return date.toUtc().add(parsed);
  }

  /// Parses "+HH:MM" / "-HH:MM" into a [Duration]. Returns null on bad input.
  static Duration? _parseOffset(String offset) {
    final match = RegExp(r'^([+-])(\d{2}):(\d{2})$').firstMatch(offset);
    if (match == null) return null;
    final sign = match.group(1) == '-' ? -1 : 1;
    final h = int.parse(match.group(2)!);
    final m = int.parse(match.group(3)!);
    return Duration(hours: sign * h, minutes: sign * m);
  }
}
