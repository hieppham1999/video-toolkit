# Video Toolkit - AI Assistant Guidelines

> This file is the single source of truth for AI coding rules.
> Symlinked/referenced by: `.cursorrules`, `.github/copilot-instructions.md`, `.windsurfrules`

## Project Overview
Flutter desktop app (macOS + Windows) for video processing. Uses `macos_ui` for macOS and `fluent_ui` for Windows.

## Commands
- **Always prefix with `fvm`**: this project uses FVM for Flutter version management.
  - `fvm flutter run` (not `flutter run`)
  - `fvm flutter pub get` (not `flutter pub get`)
  - `fvm flutter analyze` (not `flutter analyze`)
  - `fvm dart run build_runner build --delete-conflicting-outputs` (not `dart run ...`)

## Localization
- **Never hardcode user-facing text.** All strings must go through `Languages.translate.<key>`.
- Template file: `lib/l10n/app_en.arb` (English, source of truth).
- Vietnamese: `lib/l10n/app_vi.arb` — must stay in sync with `app_en.arb`.
- Access: `import 'package:video_toolkit/app/languages.dart'` → `Languages.translate.<key>`.
- After adding/changing ARB keys, run `fvm flutter gen-l10n` to regenerate.
- Generated output: `lib/generated/l10n/app_localizations.dart`.

## Text & Styling
- Every `Text` widget must have an explicit `style` from the current theme:
  - macOS: `MacosTheme.of(context).typography.<variant>` (e.g. `.body`, `.title3`, `.caption1`)
  - Windows: `FluentTheme.of(context).typography.<variant>` (e.g. `.body`, `.subtitle`, `.caption`)
- For secondary/subtle text, use `.copyWith(color: ...)` with theme-aware colors.
- **Do not use `MacosColors.*` directly** — they are `CupertinoDynamicColor` and lose dark/light adaptation when `.withOpacity()` or `.withValues()` is called. Instead compute colors from `theme.brightness == Brightness.dark`.

## Icons
- macOS: use `MacosIcon(CupertinoIcons.*)` — never bare `Icon(CupertinoIcons.*)`.
- Windows: use `Icon(FluentIcons.*)`.
- The `cupertino_icons` package is required for CupertinoIcons to render.

## Architecture
- Feature-based clean architecture under `lib/features/<feature>/`.
- State management: `flutter_bloc` (Cubit pattern) + `freezed` for immutable models.
- Cubits extend `BaseCubit<T>` from `lib/presentation/base/base_cubit.dart`.
- UI state builders use `CubitStateBuilder<T>` from `lib/presentation/base/bloc_state_builder.dart`.
- DI: `get_it` + `injectable` — annotate with `@lazySingleton`, `@injectable`, etc.
- After adding DI or freezed classes: `fvm dart run build_runner build --delete-conflicting-outputs`.

## Platform UI Pattern
- **All logic lives in `HomePage`** (single StatefulWidget). It creates a `HomeViewData` (plain data class with state + callbacks) and passes it to platform-specific renderers.
- Renderers are **pure UI, zero logic**: `MacosHomeRenderer` and `WindowsHomeRenderer` — they only read `HomeViewData` and call its callbacks.
- macOS renderers use `MacosScaffold`, `ToolBar`, `MacosIcon`, `PushButton`, etc.
- Windows renderers use `ScaffoldPage`, `PageHeader`, `FilledButton`, `Icon(FluentIcons.*)`, etc.
- **When changing app behavior or UI features, always update BOTH platform renderers.** A change to one renderer without the other is a bug. Check both files before considering a task complete.

## Freezed Models
- Use `abstract class` with `@freezed` (freezed v3 pattern).
- Part files go in a `generated/` subdirectory: `part 'generated/<name>.freezed.dart'`.
