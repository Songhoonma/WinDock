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

## Notes

- **CI** (GitHub Actions) compiles every push and PR, but does **not** sign, notarize, or release — those are maintainer-only steps requiring the Developer ID certificate.
- Contributors never need signing/notarization; they build locally with `WINDOCK_SIGN="-" ./build.sh`.
- Keep `## [Unreleased]` at the top of `CHANGELOG.md` for the next cycle.
