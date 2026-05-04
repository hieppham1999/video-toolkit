# Video Toolkit

A professional desktop video processing application for **macOS** and **Windows**, built with Flutter. Designed for batch video encoding, metadata inspection, and advanced FFmpeg-powered filter pipelines — all through a clean, native-feeling UI.

---

## Features

### Video Encoding & Transcoding
- **Codecs**: H.264 (libx264), H.265/HEVC (libx265), VP9 (libvpx-vp9)
- **Quality modes**: Constant Rate Factor (CRF) or Average Bitrate
- **Two-pass encoding** with optional turbo first pass
- **Output formats**: MP4, MOV, AVI, MKV, MTS
- **Web-optimized** MP4 output (faststart flag)
- Smart Apple device support — auto-applies `hvc1` tag for HEVC in MP4/MOV

### Filters & Transformations
- **Deinterlacing**: Yadif and Bwdif (frame and field modes)
- **Rotation**: 0°, 90° CW, 180°, 90° CCW (pixel-based or metadata-only)
- **Flipping**: Horizontal and vertical
- **Resolution scaling** and aspect ratio cropping

### Text Overlays & Watermarking
- Burn timestamps with timezone-aware date/time expressions
- Custom text overlays: font size, color, border/stroke, 5-position anchoring, X/Y offset
- Multiple overlays per video
- Bundled fonts + system font selection

### Audio
- **Codecs**: AAC, MP3, AC3, passthrough (stream copy)
- **Bitrates**: 64k – 320k

### Batch Processing
- Drag-and-drop multi-file import
- Encode multiple videos with real-time progress tracking per file
- Template-based output filenames (source name, date, custom text)

### Metadata & Preview
- Frame preview generation
- Video metadata panel (resolution, codec, frame rate, duration, aspect ratio)
- ffprobe stream analysis + exiftool extended metadata

### Presets
- Save, load, import, and export encoding presets
- Built-in preset library with per-preset revert capability

### CLI Tools Interface
- Direct access to bundled **ffmpeg**, **ffprobe**, and **exiftool**
- Command builder with preset templates
- Real-time output with raw and JSON display modes

### Application Settings
- Theme: System / Light / Dark
- Accent color: 9 choices (Blue, Purple, Pink, Red, Orange, Yellow, Green, Teal, Graphite)
- Language: English / Vietnamese
- Output directory: same-as-source, custom folder, or subfolder organization

---

## Screenshots

> _Coming soon_

---

## Tech Stack

| Layer | Libraries |
|---|---|
| UI (macOS) | [`macos_ui`](https://pub.dev/packages/macos_ui) |
| UI (Windows) | [`fluent_ui`](https://pub.dev/packages/fluent_ui) |
| State management | `flutter_bloc` · `freezed` |
| Dependency injection | `get_it` · `injectable` |
| File handling | `file_picker` · `desktop_drop` · `path_provider` |
| Serialization | `json_annotation` · `json_serializable` |
| Localization | `flutter_localizations` · ARB files |
| CLI integration | Bundled `ffmpeg`, `ffprobe`, `exiftool` binaries (macOS & Windows) |

Architecture follows **feature-based clean architecture** with Cubit state management and platform-specific UI renderers (`MacosHomeRenderer` / `WindowsHomeRenderer`) driven by a single shared `HomePage` logic layer.

---

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev) via [FVM](https://fvm.app) (version pinned in `.fvmrc`)
- macOS 12+ or Windows 10+
- Xcode (macOS builds) or Visual Studio with C++ workload (Windows builds)

### Install dependencies

```bash
fvm flutter pub get
```

### Run code generation (after modifying models or DI)

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Regenerate localization (after editing ARB files)

```bash
fvm flutter gen-l10n
```

### Run the app

```bash
# macOS
fvm flutter run -d macos

# Windows
fvm flutter run -d windows
```

### Analyze

```bash
fvm flutter analyze
```

---

## Localization

All user-facing strings are managed via ARB files:

| File | Language |
|---|---|
| `lib/l10n/app_en.arb` | English (source of truth) |
| `lib/l10n/app_vi.arb` | Vietnamese |

Access strings via `Languages.translate.<key>` after importing `package:video_toolkit/app/languages.dart`.

---

## Project Structure

```
lib/
├── app/                    # App entry, routing, theme, language helpers
├── features/
│   ├── video_import/       # Home screen, encode settings, video table, preview
│   ├── settings/           # App settings page
│   └── cli_tools/          # Integrated CLI runner (ffmpeg, ffprobe, exiftool)
├── presentation/
│   └── base/               # BaseCubit, CubitStateBuilder, shared UI base classes
└── generated/              # Code-generated files (l10n, freezed, injectable)
```

---

## Contributing

1. Follow the platform UI pattern: all logic in `HomePage`, pure UI in `MacosHomeRenderer` / `WindowsHomeRenderer`. **Always update both renderers.**
2. Use `App*` cross-platform widget wrappers (`AppField`, `AppDropdown`, etc.) before writing platform-specific pairs.
3. Never hardcode user-facing strings — add keys to both ARB files and run `fvm flutter gen-l10n`.
4. Run `fvm flutter analyze` before submitting changes.

---

## License

Private — all rights reserved.
