enum EncodePreset {
  h264Fast(
    label: 'H.264 (Fast)',
    codec: 'libx264',
    preset: 'veryfast',
    crf: '23',
    extension: 'mp4',
  ),
  h264Quality(
    label: 'H.264 (Quality)',
    codec: 'libx264',
    preset: 'slow',
    crf: '18',
    extension: 'mp4',
  ),
  h265(
    label: 'H.265 / HEVC',
    codec: 'libx265',
    preset: 'medium',
    crf: '28',
    extension: 'mp4',
  ),
  webm(
    label: 'VP9 WebM',
    codec: 'libvpx-vp9',
    preset: '',
    crf: '30',
    extension: 'webm',
  );

  const EncodePreset({
    required this.label,
    required this.codec,
    required this.preset,
    required this.crf,
    required this.extension,
  });

  final String label;
  final String codec;
  final String preset;
  final String crf;
  final String extension;

  List<String> buildArgs(
    String inputPath,
    String outputPath, {
    bool burnTimestamp = false,
  }) {
    final filters = <String>[];

    if (burnTimestamp) {
      // drawtext filter: renders the frame timestamp (pts) as HH:MM:SS
      // at the bottom-right corner with a semi-transparent background box.
      filters.add(
        "drawtext="
        "text='%{pts\\:hms}':"
        "fontsize=24:"
        "fontcolor=white:"
        "x=(w-text_w-16):"
        "y=(h-text_h-16):"
        "box=1:"
        "boxcolor=black@0.5:"
        "boxborderw=6",
      );
    }

    return [
      '-i', inputPath,
      '-c:v', codec,
      if (preset.isNotEmpty) ...['-preset', preset],
      '-crf', crf,
      if (filters.isNotEmpty) ...['-vf', filters.join(',')],
      '-c:a', 'aac',
      '-b:a', '128k',
      '-y',
      outputPath,
    ];
  }
}
