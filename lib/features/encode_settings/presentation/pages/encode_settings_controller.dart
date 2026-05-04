import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:video_toolkit/app/languages.dart';
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
    selectedPresetId = presetCubit.currentData.selectedId;
  }

  final PresetCubit presetCubit;
  final ScrollController presetScrollController = ScrollController();

  static const double minSidebar = 160;
  static const double maxSidebar = 400;

  /// Quick-select aspect ratios shown as chips under the aspect input.
  static const List<String> aspectPresets = ['16:9', '9:16', '1:1', '4:3', '3:4'];

  /// Selectable source-timezone offsets for the encode-settings dropdown.
  /// `null` represents "auto" (use the encoding machine's local TZ).
  static const List<String?> timezoneOffsets = [
    null,
    '-12:00', '-11:00', '-10:00', '-09:00', '-08:00', '-07:00', '-06:00',
    '-05:00', '-04:00', '-03:30', '-03:00', '-02:00', '-01:00',
    '+00:00',
    '+01:00', '+02:00', '+03:00', '+03:30', '+04:00', '+05:00', '+05:30',
    '+05:45', '+06:00', '+07:00', '+08:00', '+09:00', '+09:30', '+10:00',
    '+11:00', '+12:00', '+13:00', '+14:00',
  ];

  // Form state
  late VideoEncoder codec;
  late EncodePreset preset;
  late int crf;
  late OutputExtension outputExtension;
  late AudioCodec audioCodec;
  late AudioBitrate audioBitrate;
  late List<TextOverlay> textOverlays;
  late String outputNameTemplate;
  late Deinterlace deinterlace;
  late QualityMode qualityMode;
  late int avgBitrateKbps;
  late bool twoPass;
  late bool turboFirstPass;
  late String extraParams;
  late bool copySourceMetadata;
  /// Null = auto (use the encoding machine's local TZ).
  String? sourceTimezoneOffset;
  late bool webOptimized;
  String resWidth = '';
  String resHeight = '';
  String aspectNum = '';
  String aspectDen = '';
  late Rotation rotation;
  late bool useDisplayRotation;
  late bool flipHorizontal;
  late bool flipVertical;

  // UI state
  int selectedTab = 0;
  String? selectedPresetId;
  double sidebarWidth = 190;

  void _loadFromSettings(EncodeSettings s) {
    codec = s.codec;
    preset = s.preset;
    crf = s.crf;
    outputExtension = s.outputExtension;
    audioCodec = s.audioCodec;
    audioBitrate = s.audioBitrate;
    textOverlays = List.of(s.textOverlays);
    outputNameTemplate = s.outputNameTemplate;
    deinterlace = s.deinterlace;
    qualityMode = s.qualityMode;
    avgBitrateKbps = s.avgBitrateKbps;
    twoPass = s.twoPass;
    turboFirstPass = s.turboFirstPass;
    extraParams = s.extraParams;
    copySourceMetadata = s.copySourceMetadata;
    sourceTimezoneOffset = s.sourceTimezoneOffset;
    webOptimized = s.webOptimized;
    rotation = s.rotation;
    useDisplayRotation = s.useDisplayRotation;
    flipHorizontal = s.flipHorizontal;
    flipVertical = s.flipVertical;

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
      deinterlace: deinterlace,
      qualityMode: qualityMode,
      avgBitrateKbps: avgBitrateKbps,
      twoPass: twoPass,
      turboFirstPass: turboFirstPass,
      extraParams: extraParams,
      copySourceMetadata: copySourceMetadata,
      sourceTimezoneOffset: sourceTimezoneOffset,
      webOptimized: webOptimized,
      rotation: rotation,
      useDisplayRotation: useDisplayRotation,
      flipHorizontal: flipHorizontal,
      flipVertical: flipVertical,
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
  void setDeinterlace(Deinterlace v) { deinterlace = v; notifyListeners(); }
  void setQualityMode(QualityMode v) { qualityMode = v; notifyListeners(); }
  void setAvgBitrateKbps(int v) { avgBitrateKbps = v; notifyListeners(); }
  void setTwoPass(bool v) {
    twoPass = v;
    if (!v) turboFirstPass = false;
    notifyListeners();
  }
  void setTurboFirstPass(bool v) { turboFirstPass = v; notifyListeners(); }
  void setExtraParams(String v) { extraParams = v; notifyListeners(); }
  void setCopySourceMetadata(bool v) { copySourceMetadata = v; notifyListeners(); }
  void setSourceTimezoneOffset(String? v) { sourceTimezoneOffset = v; notifyListeners(); }
  void setWebOptimized(bool v) { webOptimized = v; notifyListeners(); }
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
  void swapResolution() {
    final tmp = resWidth;
    resWidth = resHeight;
    resHeight = tmp;
    _syncAspectFromResolution();
    notifyListeners();
  }

  void clearAspect() {
    aspectNum = '';
    aspectDen = '';
    notifyListeners();
  }

  void setRotation(Rotation v) {
    rotation = v;
    if (v == Rotation.none) useDisplayRotation = false;
    notifyListeners();
  }
  void setUseDisplayRotation(bool v) { useDisplayRotation = v; notifyListeners(); }
  void setFlipHorizontal(bool v) { flipHorizontal = v; notifyListeners(); }
  void setFlipVertical(bool v) { flipVertical = v; notifyListeners(); }

  /// Localized label for a [Rotation] enum value.
  static String rotationLabel(Rotation r) {
    final l10n = Languages.translate;
    return switch (r) {
      Rotation.none => l10n.rotationNone,
      Rotation.cw90 => l10n.rotation90Cw,
      Rotation.deg180 => l10n.rotation180,
      Rotation.ccw90 => l10n.rotation90Ccw,
    };
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

  /// Localized label for a [Deinterlace] enum value.
  static String deinterlaceLabel(Deinterlace d) {
    final l10n = Languages.translate;
    return switch (d) {
      Deinterlace.off => l10n.deinterlaceOff,
      Deinterlace.yadifFrame => l10n.deinterlaceYadifFrame,
      Deinterlace.yadifField => l10n.deinterlaceYadifField,
      Deinterlace.bwdifFrame => l10n.deinterlaceBwdifFrame,
      Deinterlace.bwdifField => l10n.deinterlaceBwdifField,
    };
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

  // ── Sidebar ──────────────────────────────────────────────────────
  void resizeSidebar(double delta) {
    sidebarWidth = (sidebarWidth + delta).clamp(minSidebar, maxSidebar);
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

  /// Reloads the form from the currently-selected preset, discarding any
  /// edits the user has made in this session.
  void revertToSelectedPreset() {
    final id = selectedPresetId;
    if (id == null) return;
    final match = presetCubit.currentData.presets
        .where((p) => p.id == id)
        .firstOrNull;
    if (match == null) return;
    _loadFromSettings(match.settings);
    notifyListeners();
  }

  /// Name of the selected preset, or null if none is selected.
  String? selectedPresetName() {
    final id = selectedPresetId;
    if (id == null) return null;
    return presetCubit.currentData.presets
        .where((p) => p.id == id)
        .firstOrNull
        ?.name;
  }

  /// Opens a file picker, parses the chosen JSON into [EncodeSettings], loads
  /// them into the form, then optionally saves as a new user preset using the
  /// name returned by [promptName] (caller decides how to prompt). Returns the
  /// created preset, or null when the user cancelled the picker or the name
  /// prompt. Throws [FormatException] or [IOException] on parse/read errors.
  Future<SettingsPreset?> importAndSaveAsPreset(
    Future<String?> Function() promptName,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    final raw = await File(path).readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object at root');
    }
    final imported = EncodeSettings.fromJson(decoded);
    _loadFromSettings(imported);
    notifyListeners();
    final name = await promptName();
    if (name == null || name.isEmpty) return null;
    return saveAsPreset(name);
  }

  /// Writes the currently-selected preset's settings to a user-chosen .json
  /// file. Returns true on success, false when no preset is selected or the
  /// user cancelled the save dialog.
  Future<bool> exportSelectedPreset() async {
    final id = selectedPresetId;
    if (id == null) return false;
    final preset = presetCubit.currentData.presets
        .where((p) => p.id == id)
        .firstOrNull;
    if (preset == null) return false;
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export preset',
      fileName: '${preset.name}.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (path == null) return false;
    final withExt = path.toLowerCase().endsWith('.json') ? path : '$path.json';
    const encoder = JsonEncoder.withIndent('  ');
    await File(withExt).writeAsString(encoder.convert(preset.settings.toJson()));
    return true;
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
