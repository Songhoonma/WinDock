# Changelog

All notable changes to WinDock are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-06-06

### Added
- **Click-to-toggle** — re-click the Dock icon of the frontmost app to hide/minimize it; click again to restore (the Windows-taskbar behavior macOS lacks).
- **Hide or Minimize modes** — choose how apps tuck away. Minimize slides windows into the Dock; WinDock detects and offers to enable macOS's "Minimize windows into application icon" setting.
- **Single-app focus** (optional) — automatically hide the previous app when switching; multi-monitor aware (apps on other displays are left alone, with a delayed re-check for accurate screen detection).
- **Multilingual UI** — English, Korean, Japanese, Chinese, auto-selected by system language.
- **First-run onboarding** — explains and opens the Accessibility permission pane.
- **Menu-bar icon** — `dock.rectangle` SF Symbol (vector, theme-aware).
- Notarized distribution under Developer ID (L2M Group Ltd.).

[Unreleased]: https://github.com/Songhoonma/WinDock/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Songhoonma/WinDock/releases/tag/v1.0.0
