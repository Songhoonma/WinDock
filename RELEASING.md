# Releasing WinDock

WinDock follows [Semantic Versioning](https://semver.org): **`MAJOR.MINOR.PATCH`**

| Bump | When |
|---|---|
| **MAJOR** | Behavior-breaking changes (e.g. a default that changes how apps hide) |
| **MINOR** | New features, backward compatible |
| **PATCH** | Bug fixes only |

The **single source of truth** for the version is `CFBundleShortVersionString` in `Info.plist`. The git tag and GitHub release must match it (prefixed with `v`, e.g. `v1.2.0`).

## Release steps

1. **Bump the version** in `Info.plist`:
   - `CFBundleShortVersionString` → the new `X.Y.Z`
   - `CFBundleVersion` → increment the integer build number
2. **Update `CHANGELOG.md`** — move items from `## [Unreleased]` into a new `## [X.Y.Z] - YYYY-MM-DD` section, and update the compare links at the bottom.
3. **Commit**: `git commit -am "Release vX.Y.Z"`
4. **Tag & push**: `git tag vX.Y.Z && git push origin main --tags`
5. **Build + notarize**: `./build.sh`
   - Requires the maintainer's Developer ID certificate and the `WinDock-notary` keychain profile.
   - Produces a notarized, stapled `build/WinDock.app`.
6. **Publish the release**:
   ```bash
   ditto -c -k --keepParent build/WinDock.app build/WinDock.zip
   gh release create vX.Y.Z build/WinDock.zip \
     --title "WinDock vX.Y.Z" --notes-file <release-notes.md>
   ```
7. **Update the Sparkle appcast** (this is what triggers auto-updates for existing users):
   ```bash
   # Sign the release zip and (re)generate the appcast. Keep prior versions'
   # zips in the folder so the appcast stays cumulative, OR re-run per release
   # and merge entries into docs/appcast.xml by hand.
   generate_appcast \
     --download-url-prefix "https://github.com/Songhoonma/WinDock/releases/download/vX.Y.Z/" \
     <folder-containing-WinDock.zip>
   cp <folder>/appcast.xml docs/appcast.xml
   git commit -am "Publish Sparkle appcast for vX.Y.Z" && git push origin main
   ```
   - `docs/appcast.xml` is served via **GitHub Pages** at `https://songhoonma.github.io/WinDock/appcast.xml`, which is the `SUFeedURL` baked into `Info.plist`.
   - `generate_appcast` signs with the **EdDSA private key in the login keychain** (created once via Sparkle's `generate_keys`; public key is `SUPublicEDKey` in `Info.plist`).
   - Verify: `curl -sI https://songhoonma.github.io/WinDock/appcast.xml` → 200, and the enclosure URL resolves.

## Notes

- **CI** (GitHub Actions) compiles every push and PR, but does **not** sign, notarize, or release — those are maintainer-only steps requiring the Developer ID certificate.
- Contributors never need signing/notarization; they build locally with `WINDOCK_SIGN="-" ./build.sh`.
- Keep `## [Unreleased]` at the top of `CHANGELOG.md` for the next cycle.
- **Back up the Sparkle EdDSA private key.** It lives in the maintainer's login keychain. If it is lost, no future build can be signed for auto-update and every user has to reinstall manually. Export/store it securely (never commit it).
