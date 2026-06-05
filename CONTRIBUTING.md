# Contributing to WinDock

Thanks for your interest in improving WinDock! This is a small, focused menu-bar app, and contributions of all kinds are welcome — bug fixes, features, translations, and docs.

## Development setup

Requirements:
- macOS 13 or later
- Xcode command-line tools: `xcode-select --install`

Build a local development version (ad-hoc signed — no certificate needed):

```bash
WINDOCK_SIGN="-" ./build.sh
open build/WinDock.app
```

Then grant Accessibility permission: **System Settings → Privacy & Security → Accessibility → enable WinDock**.

> Note: ad-hoc builds change identity on each rebuild, so macOS may ask you to re-grant Accessibility permission after rebuilding. This is expected for local dev. Official releases (Developer ID + notarized) keep their permission across updates.

A runtime debug log is written to `/tmp/windock.log` (auto-trimmed) — useful when diagnosing click/hide behavior.

## Project layout

| File | Purpose |
|---|---|
| `AppDelegate.swift` | All app logic — menu bar, Dock-click detection, hide/minimize, localization |
| `main.swift` | NSApplication bootstrap |
| `Info.plist` | Bundle metadata (`kr.l2mgroup.WinDock`, menu-bar-only via `LSUIElement`) |
| `entitlements.plist` | Hardened Runtime entitlements |
| `build.sh` | Build + sign (+ optional notarize) |

## Making changes

- Keep changes **focused and minimal** — one concern per PR.
- Match the existing code style and comment density.
- When touching window/screen logic, **test on both single-monitor and multi-monitor** setups — that's where most edge cases live.
- For any user-facing string, add **all four languages** (English, Korean, Japanese, Chinese) in the `L10n` table in `AppDelegate.swift`. English is the fallback.

## Pull requests

1. Fork the repo and create a branch.
2. Make your change; ensure it compiles (`WINDOCK_SIGN="-" ./build.sh`).
3. Open a PR against `main` using the PR template.
4. CI (GitHub Actions) must pass — the app must compile cleanly.

## Reporting bugs

Open an issue with the **Bug report** template. Please include your macOS version, single/multi-monitor, the hide method (Hide/Minimize), and reproduction steps.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
