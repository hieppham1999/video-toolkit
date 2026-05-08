class BitrateFormatter {
  /// Formats an ffprobe bitrate (bits per second) as a human string.
  /// Returns "-" for null/non-positive.
  static String format(int? bps) {
    if (bps == null || bps <= 0) return '-';
    return '${(bps / 1000).round()} kbps';
  }
}
