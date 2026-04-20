import 'package:flutter/widgets.dart';
import 'package:video_toolkit/features/video_encoding/data/models/encode_settings.dart';
import 'package:video_toolkit/features/video_encoding/data/models/settings_preset.dart';
import 'package:video_toolkit/features/video_encoding/presentation/cubit/preset_cubit.dart';

/// Shared state + logic for the encode-settings sheet / dialog on both
/// macOS and Windows. Platform widgets are thin views that bind to this.
class EncodeSettingsController extends ChangeNotifier {
  EncodeSettingsController({
    required EncodeSettings initialSettings,
    required this.presetCubit,
  }) {
    _loadFromSettings(initialSettings);
  }

  final PresetCubit presetCubit;
  final ScrollController presetScrollController = ScrollController();

  static const double minSidebar = 160;
  static const double maxSidebar = 400;

  /// Quick-select aspect ratios shown as chips under the aspect input.
  static const List<String> aspectPresets = ['16:9', '9:16', '1:1', '4:3', '3:4'];

  // Form state
  late VideoEncoder codec;
  late EncodePreset preset;
  late int crf;
  late OutputExtension outputExtension;
  late AudioCodec audioCodec;
  late AudioBitrate audioBitrate;
  late List<TextOverlay> textOverlays;
  late String outputNameTemplate;
  String resWidth = '';
  String resHeight = '';
  String aspectNum = '';
  String aspectDen = '';

  // UI state
  int selectedTab = 0;
  String? selectedPresetId;
  double sidebarWidth = 190;
  Offset dragOffset = Offset.zero;

  void _loadFromSettings(EncodeSettings s) {
    codec = s.codec;
    preset = s.preset;
    crf = s.crf;
    outputExtension = s.outputExtension;
    audioCodec = s.audioCodec;
    audioBitrate = s.audioBitrate;
    textOverlays = List.of(s.textOverlays);
    outputNameTemplate = s.outputNameTemplate;

    resWidth = '';
    resHeight = '';
    final res = s.resolution?.split(':');
    if (res != null && res.length == 2) {
      resWidth = res[0].trim();
      resHeight = res[1].trim();
    }
    aspectNum = '';
    aspectDen = '';
    final aspect = s.cropAspectRatio?.split(':');
    if (aspect != null && aspect.length == 2) {
      aspectNum = aspect[0].trim();
      aspectDen = aspect[1].trim();
    }
  }

  EncodeSettings buildSettings() {
    final resolution = resWidth.isNotEmpty && resHeight.isNotEmpty
        ? '$resWidth:$resHeight'
        : null;
    final cropAspectRatio = aspectNum.isNotEmpty && aspectDen.isNotEmpty
        ? '$aspectNum:$aspectDen'
        : null;
    return EncodeSettings(
      codec: codec,
      preset: preset,
      crf: crf,
      outputExtension: outputExtension,
      resolution: resolution,
      audioCodec: audioCodec,
      audioBitrate: audioBitrate,
      textOverlays: textOverlays,
      outputNameTemplate: outputNameTemplate,
      cropAspectRatio: cropAspectRatio,
    );
  }

  // ── Setters (each notifies) ──────────────────────────────────────
  void setTab(int v) { selectedTab = v; notifyListeners(); }
  void setCodec(VideoEncoder v) { codec = v; notifyListeners(); }
  void setPreset(EncodePreset v) { preset = v; notifyListeners(); }
  void setCrf(int v) { crf = v; notifyListeners(); }
  void setOutputExtension(OutputExtension v) { outputExtension = v; notifyListeners(); }
  void setAudioCodec(AudioCodec v) { audioCodec = v; notifyListeners(); }
  void setAudioBitrate(AudioBitrate v) { audioBitrate = v; notifyListeners(); }
  void setOutputNameTemplate(String v) { outputNameTemplate = v; notifyListeners(); }
  void appendNameTag(String tag) {
    outputNameTemplate = '$outputNameTemplate{$tag}';
    notifyListeners();
  }

  void setResWidth(String v) {
    resWidth = v;
    _syncAspectFromResolution();
    notifyListeners();
  }
  void setResHeight(String v) {
    resHeight = v;
    _syncAspectFromResolution();
    notifyListeners();
  }
  void setAspectNum(String v) {
    aspectNum = v;
    _syncResolutionFromAspect();
    notifyListeners();
  }
  void setAspectDen(String v) {
    aspectDen = v;
    _syncResolutionFromAspect();
    notifyListeners();
  }
  void applyAspectPreset(String presetStr) {
    final parts = presetStr.split(':');
    if (parts.length != 2) return;
    aspectNum = parts[0];
    aspectDen = parts[1];
    _syncResolutionFromAspect();
    notifyListeners();
  }
  void clearAspect() {
    aspectNum = '';
    aspectDen = '';
    notifyListeners();
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  void _syncAspectFromResolution() {
    final w = int.tryParse(resWidth);
    final h = int.tryParse(resHeight);
    if (w == null || h == null || w <= 0 || h <= 0) return;
    final g = _gcd(w, h);
    aspectNum = (w ~/ g).toString();
    aspectDen = (h ~/ g).toString();
  }

  void _syncResolutionFromAspect() {
    final n = int.tryParse(aspectNum);
    final d = int.tryParse(aspectDen);
    if (n == null || d == null || n <= 0 || d <= 0) return;
    final w = int.tryParse(resWidth);
    final h = int.tryParse(resHeight);
    if (w != null && w > 0) {
      resHeight = (w * d / n).round().toString();
    } else if (h != null && h > 0) {
      resWidth = (h * n / d).round().toString();
    }
  }

  /// Returns formatted output size after a center-crop to the given aspect.
  static String computeCropOutput(int? srcW, int? srcH, String aspect) {
    if (srcW == null || srcH == null) return '-';
    if (aspect.isEmpty) return '$srcW × $srcH';
    final parts = aspect.split(':');
    if (parts.length != 2) return '-';
    final num = double.tryParse(parts[0].trim());
    final den = double.tryParse(parts[1].trim());
    if (num == null || den == null || num <= 0 || den <= 0) return '-';
    final srcRatio = srcW / srcH;
    final tgtRatio = num / den;
    int outW, outH;
    if (srcRatio > tgtRatio) {
      outH = srcH;
      outW = (srcH * tgtRatio).round();
    } else {
      outW = srcW;
      outH = (srcW / tgtRatio).round();
    }
    return '${outW}x$outH';
  }

  // ── Text overlay mutations ───────────────────────────────────────
  void addOverlay() {
    textOverlays = [...textOverlays, const TextOverlay(text: 'Text')];
    notifyListeners();
  }
  void removeOverlay(int i) {
    textOverlays = [...textOverlays]..removeAt(i);
    notifyListeners();
  }
  void updateOverlay(int i, TextOverlay o) {
    textOverlays = [...textOverlays]..[i] = o;
    notifyListeners();
  }

  // ── Sidebar / drag ───────────────────────────────────────────────
  void resizeSidebar(double delta) {
    sidebarWidth = (sidebarWidth + delta).clamp(minSidebar, maxSidebar);
    notifyListeners();
  }
  void dragBy(Offset delta) {
    dragOffset += delta;
    notifyListeners();
  }
  void resetDrag() {
    dragOffset = Offset.zero;
    notifyListeners();
  }

  // ── Preset actions ───────────────────────────────────────────────
  void selectPreset(SettingsPreset p) {
    selectedPresetId = p.id;
    _loadFromSettings(p.settings);
    presetCubit.select(p.id);
    notifyListeners();
  }

  /// Returns the newly created preset (callers may want to show a toast).
  Future<SettingsPreset> saveAsPreset(String name) async {
    final preset = await presetCubit.saveAs(name, buildSettings());
    selectedPresetId = preset.id;
    notifyListeners();
    return preset;
  }

  /// Returns the current user preset if overwrite happened, or null when the
  /// selection is built-in / absent (caller should fall back to Save As).
  SettingsPreset? currentUserPreset() {
    final id = selectedPresetId;
    final match = presetCubit.currentData.presets
        .where((p) => p.id == id)
        .firstOrNull;
    if (match == null || match.isBuiltIn) return null;
    return match;
  }

  Future<void> overwriteSelectedPreset() async {
    final current = currentUserPreset();
    if (current == null) return;
    await presetCubit.overwrite(current.id, buildSettings());
  }

  Future<void> deleteSelectedPreset() async {
    final current = currentUserPreset();
    if (current == null) return;
    await presetCubit.delete(current.id);
    selectedPresetId = null;
    notifyListeners();
  }

  // ── High-level flows (platform view just wires prompt/confirm) ──
  /// Prompt for a name, then create a new user preset.
  Future<void> handleSaveAs(Future<String?> Function() promptName) async {
    final name = await promptName();
    if (name == null || name.isEmpty) return;
    await saveAsPreset(name);
  }

  /// Overwrite current user preset, or fall back to Save As when nothing
  /// (or a built-in) is selected.
  Future<void> handleSave(Future<String?> Function() promptName) async {
    if (currentUserPreset() == null) {
      await handleSaveAs(promptName);
      return;
    }
    await overwriteSelectedPreset();
  }

  /// Confirm first, then delete the selected user preset.
  Future<void> handleDelete(
    Future<bool?> Function(String name) confirmDelete,
  ) async {
    final current = currentUserPreset();
    if (current == null) return;
    final ok = await confirmDelete(current.name);
    if (ok != true) return;
    await deleteSelectedPreset();
  }

  @override
  void dispose() {
    presetScrollController.dispose();
    super.dispose();
  }
}
