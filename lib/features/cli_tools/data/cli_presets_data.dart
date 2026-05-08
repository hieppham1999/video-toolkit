import 'package:video_toolkit/features/cli_tools/domain/cli_preset.dart';
import 'package:video_toolkit/features/cli_tools/domain/cli_tool.dart';

/// Built-in command presets, grouped by tool.
///
/// Presets are intentionally read-only / inspection commands — we don't ship
/// destructive ffmpeg transforms as presets because they'd need output-path
/// handling. User can still type their own args for any tool.
const Map<CliTool, List<CliPreset>> kBuiltInPresets = {
  CliTool.ffprobe: [
    CliPreset(
      tool: CliTool.ffprobe,
      label: 'Show all streams (JSON)',
      args: [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        CliPreset.inputPlaceholder,
      ],
    ),
    CliPreset(
      tool: CliTool.ffprobe,
      label: 'Video stream info',
      args: [
        '-v', 'error',
        '-select_streams', 'v:0',
        '-show_entries',
        'stream=codec_name,width,height,r_frame_rate,duration,bit_rate',
        '-of', 'default=noprint_wrappers=1',
        CliPreset.inputPlaceholder,
      ],
    ),
    CliPreset(
      tool: CliTool.ffprobe,
      label: 'Duration only',
      args: [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        CliPreset.inputPlaceholder,
      ],
    ),
  ],
  CliTool.exiftool: [
    CliPreset(
      tool: CliTool.exiftool,
      label: 'All time tags',
      args: ['-time:all', '-G1', '-a', '-s', CliPreset.inputPlaceholder],
    ),
    CliPreset(
      tool: CliTool.exiftool,
      label: 'All metadata',
      args: ['-a', '-G1', '-s', CliPreset.inputPlaceholder],
    ),
    CliPreset(
      tool: CliTool.exiftool,
      label: 'Creation / modify dates',
      args: [
        '-CreateDate',
        '-ModifyDate',
        '-DateTimeOriginal',
        '-s',
        CliPreset.inputPlaceholder,
      ],
    ),
    CliPreset(
      tool: CliTool.exiftool,
      label: 'GPS tags',
      args: ['-GPS:all', '-G1', '-a', '-s', CliPreset.inputPlaceholder],
    ),
  ],
  CliTool.ffmpeg: [
    CliPreset(
      tool: CliTool.ffmpeg,
      label: 'Show input info',
      args: ['-hide_banner', '-i', CliPreset.inputPlaceholder],
    ),
    CliPreset(
      tool: CliTool.ffmpeg,
      label: 'List codecs',
      args: ['-hide_banner', '-codecs'],
    ),
    CliPreset(
      tool: CliTool.ffmpeg,
      label: 'List formats',
      args: ['-hide_banner', '-formats'],
    ),
  ],
};
