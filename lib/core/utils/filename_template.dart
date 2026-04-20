/// Resolves user-defined filename templates with date tags.
///
/// Supported tags:
/// - `{name}` — original filename without extension
/// - `{year}`, `{month}`, `{day}` — from video's creation date (zero-padded)
/// - `{hour}`, `{minute}`, `{second}` — from video's creation date (zero-padded)
///
/// Date tags resolve from the video's `creationDate` metadata. If that metadata
/// is not available, date tags are replaced with an empty string so the user
/// can tell the info is missing (rather than silently falling back to "now").
class FilenameTemplate {
  /// All supported tag names for UI display.
  static const tags = ['name', 'year', 'month', 'day', 'hour', 'minute', 'second'];

  /// Date-dependent tags (all except `{name}`).
  static const dateTags = ['year', 'month', 'day', 'hour', 'minute', 'second'];

  /// Applies [template] using [originalName] and [creationDate].
  /// If [template] is empty, returns `${originalName}_encoded` (default).
  /// If [creationDate] is null, date tags resolve to an empty string.
  static String apply(String template, {required String originalName, DateTime? creationDate}) {
    if (template.trim().isEmpty) return '${originalName}_encoded';

    final map = <String, String>{'name': originalName};
    if (creationDate != null) {
      final d = creationDate.toLocal();
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
    return result;
  }
}
