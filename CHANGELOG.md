# Changelog

All notable changes to WinDock are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-06-06

### Added
- **Automatic updates** — a built-in Sparkle updater with a "Check for Updates…" menu item. Updates are delivered over a signed appcast (EdDSA), so you no longer need to revisit the Releases page to upgrade.
- **App icon** — blue rounded-square WinDock icon (bundled `.icns`) shown in Finder and the Dock.
- **Manual language selection** — pick the UI language (System / English / 한국어 / 日本語 / 中文) in Settings, on top of the existing automatic detection.

### Changed
- **Settings moved into a dedicated window** — the toggles (auto-hide on switch, hide on re-click, hide method) and the language picker now live in a Settings window, so several options can be changed at once without the status menu closing after each click. The status menu is now just ON/OFF · Settings… · Quit.

### Fixed
- Settings window title bar now updates immediately when the language is switched (previously it kept whichever language was active when the window was first opened, so the title and body could disagree).

## [1.0.0] - 2026-06-06

### Added
- **Click-to-toggle** — re-click the Dock icon of the frontmost app to hide/minimize it; click again to restore (the Windows-taskbar behavior macOS lacks).
- **Hide or Minimize modes** — choose how apps tuck away. Minimize slides windows into the Dock; WinDock detects and offers to enable macOS's "Minimize windows into application icon" setting.
- **Single-app focus** (optional) — automatically hide the previous app when switching; multi-monitor aware (apps on other displays are left alone, with a delayed re-check for accurate screen detection).
- **Multilingual UI** — English, Korean, Japanese, Chinese, auto-selected by system language.
- **First-run onboarding** — explains and opens the Accessibility permission pane.
- **Menu-bar icon** — `dock.rectangle` SF Symbol (vector, theme-aware).
- Notarized distribution under Developer ID (L2M Group Ltd.).

[Unreleased]: https://github.com/Songhoonma/WinDock/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/Songhoonma/WinDock/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Songhoonma/WinDock/releases/tag/v1.0.0
