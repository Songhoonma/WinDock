#!/bin/bash
#
# WinDock 빌드 스크립트 — swiftc로 .app 번들 직접 생성 + (선택) 공증
#
# ── 로컬 개발 빌드 (서명 인증서 없이, ad-hoc) ───────────────────────
#     WINDOCK_SIGN="-" ./build.sh
#   누구나 가능. Gatekeeper 경고가 뜰 수 있고, 재빌드 때마다 손쉬운 사용
#   권한을 다시 허용해야 할 수 있다. 개발/테스트 전용.
#
# ── 공식 배포 빌드 (Developer ID + 공증) ────────────────────────────
#     ./build.sh
#   기본 서명 인증서는 메인테이너의 Developer ID. 공증하려면 먼저 1회:
#     xcrun notarytool store-credentials "WinDock-notary" \
#       --apple-id <Apple ID> --team-id 7VTLG34BP5 --password <앱 암호>
#
set -euo pipefail

APP_NAME="WinDock"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
EXEC="$MACOS_DIR/$APP_NAME"
ENTITLEMENTS="entitlements.plist"

# 서명 인증서. 미지정이면 메인테이너 Developer ID.
# 기여자는  WINDOCK_SIGN="-" ./build.sh  로 ad-hoc 서명.
SIGN_IDENTITY="${WINDOCK_SIGN:-Developer ID Application: L2M Group Ltd. (7VTLG34BP5)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-WinDock-notary}"

cd "$(dirname "$0")"

rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"

echo "[1/5] Compiling Swift..."
swiftc \
    -O \
    -target x86_64-apple-macos13.0 \
    -framework Cocoa \
    -o "$EXEC" \
    AppDelegate.swift main.swift

echo "[2/5] Bundling Info.plist..."
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

if [ "$SIGN_IDENTITY" = "-" ]; then
    echo "[3/5] Codesigning (ad-hoc — 로컬 개발용, 배포 불가)..."
    codesign --force --options runtime --entitlements "$ENTITLEMENTS" --sign "-" "$APP_BUNDLE"
else
    echo "[3/5] Codesigning (Developer ID + Hardened Runtime)..."
    codesign --force --options runtime --timestamp \
        --entitlements "$ENTITLEMENTS" \
        --sign "$SIGN_IDENTITY" \
        "$APP_BUNDLE"
fi
codesign --verify --strict --verbose=2 "$APP_BUNDLE"

# 공증: Developer ID 서명이고 자격증명 프로파일이 있을 때만
if [ "$SIGN_IDENTITY" != "-" ] && xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    echo "[4/5] Notarizing (profile: $NOTARY_PROFILE)... 수 분 걸릴 수 있음"
    ZIP="$BUILD_DIR/$APP_NAME.zip"
    ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP"
    xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
    rm -f "$ZIP"

    echo "[5/5] Stapling notarization ticket..."
    xcrun stapler staple "$APP_BUNDLE"
    xcrun stapler validate "$APP_BUNDLE"
    spctl --assess --type execute --verbose=2 "$APP_BUNDLE" || true
    echo ""
    echo "✅ 공증·스테이플 완료 — 다른 Mac에서 경고 없이 실행됩니다."
else
    echo "[4/5] ⏭  공증 건너뜀 (ad-hoc 서명이거나 '$NOTARY_PROFILE' 프로파일 없음)."
fi

echo ""
echo "Built: $(pwd)/$APP_BUNDLE"
echo "Run:   open $APP_BUNDLE"
