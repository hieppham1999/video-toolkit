import 'dart:io';

import 'package:flutter/widgets.dart';

import 'macos/macos_video_list_page.dart';
import 'windows/windows_video_list_page.dart';

class VideoListPage extends StatelessWidget {
  const VideoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) return const WindowsVideoListPage();
    return const MacosVideoListPage();
  }
}
