//
//  AppDelegate.swift
//  WinDock
//
//  Windows 작업표시줄처럼 동작하는 macOS Dock 메뉴바 앱.
//  Dock 아이콘 재클릭으로 앱을 가리기/최소화 토글하고,
//  앱 전환 시 직전 앱을 자동으로 숨길 수 있다.
//

import Cocoa
import ApplicationServices

// UI 문자열을 언어별로 고른다. 기본은 시스템 언어(영·한·일·중)를 따르되,
// 설정 창에서 명시적으로 고른 언어가 있으면 그걸 우선한다(UserDefaults "language").
// swiftc 단일 파일 빌드라 .strings 번들 대신 코드 내 테이블을 쓴다.
enum L10n {
    static let prefKey = "language"   // "system"(기본)/"ko"/"en"/"ja"/"zh"

    // 설정에서 바꾸면 즉시 반영되도록 매번 계산한다(상수 캐시 X).
    static var lang: String {
        let pref = UserDefaults.standard.string(forKey: prefKey) ?? "system"
        if pref != "system" { return pref }
        let sys = (Locale.preferredLanguages.first ?? "en").lowercased()
        if sys.hasPrefix("ko") { return "ko" }
        if sys.hasPrefix("ja") { return "ja" }
        if sys.hasPrefix("zh") { return "zh" }
        return "en"
    }

    static func t(_ key: String) -> String {
        let entry = table[key]
        return entry?[lang] ?? entry?["en"] ?? key
    }

    private static let table: [String: [String: String]] = [
        "disable": ["en": "Disable", "ko": "비활성화", "ja": "無効にする", "zh": "禁用"],
        "enable": ["en": "Enable", "ko": "활성화", "ja": "有効にする", "zh": "启用"],
        "autoHideSwitch": [
            "en": "Auto-hide previous app on switch",
            "ko": "앱 전환 시 이전 앱 자동 숨김",
            "ja": "アプリ切り替え時に前のアプリを自動で隠す",
            "zh": "切换应用时自动隐藏上一个应用"],
        "hideReclick": [
            "en": "Hide on re-click of same app",
            "ko": "같은 앱 재클릭 시 숨김",
            "ja": "同じアプリの再クリックで隠す",
            "zh": "再次点击同一应用时隐藏"],
        "minimizeMode": [
            "en": "Hide method: Minimize (into Dock)",
            "ko": "숨김 방식: 최소화(Dock으로)",
            "ja": "隠す方法：最小化（Dockへ）",
            "zh": "隐藏方式：最小化（到 Dock）"],
        "minimizeTooltip": [
            "en": "When on, minimizes windows into the Dock instead of hiding (⌘H) — Windows taskbar style",
            "ko": "켜면 가리기(⌘H) 대신 창을 Dock으로 최소화합니다 (Windows 작업표시줄 방식)",
            "ja": "オンにすると、隠す（⌘H）代わりにウインドウをDockに最小化します（Windowsのタスクバー方式）",
            "zh": "开启后，将窗口最小化到 Dock，而不是隐藏（⌘H）——Windows 任务栏方式"],
        "launchAtLoginMenu": [
            "en": "How to launch at login",
            "ko": "로그인 시 자동 실행 설정 안내",
            "ja": "ログイン時に自動起動する方法",
            "zh": "如何在登录时自动启动"],
        "quit": ["en": "Quit", "ko": "종료", "ja": "終了", "zh": "退出"],
        "launchInfoTitle": [
            "en": "Launch at login",
            "ko": "로그인 시 자동 실행",
            "ja": "ログイン時に自動起動",
            "zh": "登录时自动启动"],
        "launchInfoBody": [
            "en": "Add WinDock.app in System Settings → General → Login Items to launch it automatically when your Mac starts.",
            "ko": "시스템 설정 → 일반 → 로그인 항목에서\nWinDock.app을 추가하시면\nMac 시작 시 자동으로 실행됩니다.",
            "ja": "システム設定 → 一般 → ログイン項目で\nWinDock.app を追加すると\nMac起動時に自動的に実行されます。",
            "zh": "在系统设置 → 通用 → 登录项中\n添加 WinDock.app，\nMac 启动时将自动运行。"],
        "ok": ["en": "OK", "ko": "확인", "ja": "OK", "zh": "确定"],
        "dockSettingTitle": [
            "en": "Dock setting change needed",
            "ko": "Dock 설정 변경이 필요합니다",
            "ja": "Dockの設定変更が必要です",
            "zh": "需要更改 Dock 设置"],
        "dockSettingBody": [
            "en": "For Minimize to behave like the Windows taskbar, macOS's “Minimize windows into application icon” must be on. (Otherwise minimized windows pile up on the right side of the Dock instead of the app icon.)\n\nTurn it on now? The Dock will restart briefly.",
            "ko": "'최소화' 방식이 Windows 작업표시줄처럼 동작하려면 macOS의\n'윈도우를 응용 프로그램 아이콘으로 최소화' 설정이 켜져 있어야 합니다.\n(꺼져 있으면 최소화한 창이 앱 아이콘이 아닌 Dock 오른쪽에 따로 쌓입니다.)\n\n지금 켤까요? Dock이 잠깐 재시작됩니다.",
            "ja": "「最小化」をWindowsのタスクバーのように動作させるには、macOSの\n「ウインドウをアプリケーションアイコンにしまう」設定をオンにする必要があります。\n（オフの場合、最小化したウインドウがアプリアイコンではなくDockの右側に溜まります。）\n\n今すぐオンにしますか？Dockが一時的に再起動します。",
            "zh": "若要让“最小化”像 Windows 任务栏一样工作，需要开启 macOS 的\n“将窗口最小化至应用程序图标”设置。\n（否则最小化的窗口会堆积在 Dock 右侧，而非应用图标处。）\n\n现在开启吗？Dock 将短暂重启。"],
        "turnOn": ["en": "Turn On", "ko": "켜기", "ja": "オンにする", "zh": "开启"],
        "later": ["en": "Later", "ko": "나중에", "ja": "後で", "zh": "稍后"],
        "axTitle": [
            "en": "Accessibility permission needed",
            "ko": "손쉬운 사용 권한이 필요합니다",
            "ja": "アクセシビリティ権限が必要です",
            "zh": "需要辅助功能权限"],
        "axBody": [
            "en": "WinDock needs Accessibility permission to detect Dock clicks and hide or minimize apps. It does not record your screen or read your data.\n\nOpen System Settings → Privacy & Security → Accessibility, and enable WinDock.",
            "ko": "WinDock이 Dock 클릭을 감지하고 앱을 숨기거나 최소화하려면 손쉬운 사용 권한이 필요합니다. 화면을 녹화하거나 데이터를 읽지 않습니다.\n\n시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용에서 WinDock을 켜 주세요.",
            "ja": "WinDockがDockのクリックを検知し、アプリを隠す/最小化するにはアクセシビリティ権限が必要です。画面の録画やデータの読み取りは行いません。\n\nシステム設定 → プライバシーとセキュリティ → アクセシビリティ で WinDock を有効にしてください。",
            "zh": "WinDock 需要辅助功能权限来检测 Dock 点击并隐藏或最小化应用。它不会录制屏幕或读取您的数据。\n\n请在 系统设置 → 隐私与安全性 → 辅助功能 中启用 WinDock。"],
        "openSettings": [
            "en": "Open Settings",
            "ko": "설정 열기",
            "ja": "設定を開く",
            "zh": "打开设置"],
        "settingsMenu": ["en": "Settings…", "ko": "설정…", "ja": "設定…", "zh": "设置…"],
        "settingsTitle": [
            "en": "WinDock Settings", "ko": "WinDock 설정",
            "ja": "WinDock 設定", "zh": "WinDock 设置"],
        "language": ["en": "Language", "ko": "언어", "ja": "言語", "zh": "语言"],
        "languageSystem": [
            "en": "System default", "ko": "시스템 따름",
            "ja": "システムに従う", "zh": "跟随系统"],
    ]
}

class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    private var statusItem: NSStatusItem!
    private var prefsWindow: NSWindow?
    private var isEnabled: Bool = true
    private var hideOnSwitch: Bool = true   // 앱 전환 시 이전 앱 숨김
    private var hideOnReClick: Bool = true  // 같은 앱 재활성화 시 숨김
    private var useMinimize: Bool = false   // 숨김 방식: false=가리기(hide), true=최소화(minimize)

    private var lastActiveApp: NSRunningApplication?
    private var globalMouseMonitor: Any?
    private var logWriteCount = 0

    // 자기 자신과 시스템 앱은 절대 숨기지 않음
    private let excludedBundleIDs: Set<String> = [
        "com.apple.dock",
        "com.apple.systemuiserver",
        "com.apple.controlcenter",
        "com.apple.notificationcenterui",
        "com.apple.WindowManager",
        "com.apple.loginwindow"
    ]

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 메뉴바 전용 앱 (Dock 아이콘 숨김)
        NSApp.setActivationPolicy(.accessory)

        setupStatusItem()
        loadPreferences()
        checkAccessibilityPermission()
        startObserving()
    }

    private func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        log("accessibility trusted: \(trusted)")
        if !trusted {
            showAccessibilityOnboarding()
        }
    }

    // 권한이 없으면 첫 실행 온보딩 — 무엇이 왜 필요한지 설명하고
    // 손쉬운 사용 설정 패널을 직접 열어준다.
    private func showAccessibilityOnboarding() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = L10n.t("axTitle")
        alert.informativeText = L10n.t("axBody")
        alert.addButton(withTitle: L10n.t("openSettings"))
        alert.addButton(withTitle: L10n.t("later"))
        if alert.runModal() == .alertFirstButtonReturn {
            // 시스템 권한 프롬프트도 띄우고(목록에 항목 추가됨), 설정 패널을 연다.
            let opts = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
            _ = AXIsProcessTrustedWithOptions(opts)
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func screenFor(app: NSRunningApplication) -> NSScreen? {
        let element = AXUIElementCreateApplication(app.processIdentifier)
        var winRef: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXFocusedWindowAttribute as CFString, &winRef)
        if winRef == nil {
            AXUIElementCopyAttributeValue(element, kAXMainWindowAttribute as CFString, &winRef)
        }
        if winRef == nil {
            var windowsRef: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXWindowsAttribute as CFString, &windowsRef)
            if let windows = windowsRef as? [AXUIElement], let first = windows.first {
                winRef = first
            }
        }
        guard let raw = winRef else { return nil }
        let window = raw as! AXUIElement

        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &posRef)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        guard let pRaw = posRef, let sRaw = sizeRef else { return nil }
        var p = CGPoint.zero
        var s = CGSize.zero
        AXValueGetValue(pRaw as! AXValue, .cgPoint, &p)
        AXValueGetValue(sRaw as! AXValue, .cgSize, &s)

        // AX(top-left) 윈도우 중심 → Cocoa(bottom-left)
        guard let primary = NSScreen.screens.first(where: { $0.frame.origin == .zero }) else { return nil }
        let cocoaCenter = CGPoint(x: p.x + s.width / 2,
                                  y: primary.frame.maxY - (p.y + s.height / 2))
        return NSScreen.screens.first(where: { $0.frame.contains(cocoaCenter) })
    }

    private func sameScreen(_ a: NSScreen?, _ b: NSScreen?) -> Bool {
        // 모니터가 하나뿐이면 화면 구분이 무의미 — 항상 같은 화면으로 본다.
        if NSScreen.screens.count <= 1 { return true }
        guard let a = a, let b = b else { return false }
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        let idA = (a.deviceDescription[key] as? NSNumber)?.uint32Value
        let idB = (b.deviceDescription[key] as? NSNumber)?.uint32Value
        return idA != nil && idA == idB
    }

    private func hideApp(_ app: NSRunningApplication) -> Bool {
        if useMinimize {
            return minimizeApp(app)
        }
        // 1차: NSRunningApplication.hide() — Apple Events (대부분 거부됨)
        // 2차: Accessibility API kAXHiddenAttribute — 권한 받으면 작동
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        let err = AXUIElementSetAttributeValue(appElement,
                                               kAXHiddenAttribute as CFString,
                                               kCFBooleanTrue)
        if err == .success { return true }
        log("  AX hide err=\(err.rawValue), fallback to NSRunningApplication.hide()")
        return app.hide()
    }

    // Windows 작업표시줄 감성 — 앱의 모든 창을 최소화(Dock으로 내림).
    // 창을 못 찾으면 hide로 폴백한다.
    private func minimizeApp(_ app: NSRunningApplication) -> Bool {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement], !windows.isEmpty else {
            log("  minimize: no windows, fallback to hide")
            return app.hide()
        }
        var anySuccess = false
        for window in windows {
            let err = AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
            if err == .success { anySuccess = true }
        }
        log("  minimize: \(windows.count) window(s), success=\(anySuccess)")
        return anySuccess
    }

    // 앱의 보이는 창이 하나도 없는지(전부 최소화됐는지) 판정.
    // 창 정보를 못 구하면 보수적으로 false(=숨김 진행)를 반환한다.
    private func allWindowsMinimized(_ app: NSRunningApplication) -> Bool {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        var windowsRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef) == .success,
              let windows = windowsRef as? [AXUIElement], !windows.isEmpty else {
            return false
        }
        for window in windows {
            var minRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minRef)
            let isMin = (minRef as? Bool) ?? false
            if !isMin { return false }   // 하나라도 안 내려간 창이 있으면 false
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        savePreferences()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    // MARK: - Status Item (메뉴바 아이콘)

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.font = NSFont.systemFont(ofSize: 15, weight: .medium)
            button.toolTip = "WinDock"
        }
        updateStatusIcon()
        rebuildMenu()
    }

    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        // SF Symbol(벡터) — 레티나·다크모드 자동 대응, 비트맵이 아니라 깨지지 않는다.
        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        if let img = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "WinDock")?
            .withSymbolConfiguration(config) {
            img.isTemplate = true
            button.image = img
            button.title = ""
            button.alphaValue = isEnabled ? 1.0 : 0.4   // OFF는 흐리게
        } else {
            // SF Symbol을 못 쓰는 환경이면 텍스트로 폴백
            button.image = nil
            button.title = isEnabled ? "◐" : "◯"
            button.alphaValue = 1.0
        }
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let title = NSMenuItem(title: isEnabled ? "WinDock: ON" : "WinDock: OFF",
                               action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)
        menu.addItem(NSMenuItem.separator())

        let toggle = NSMenuItem(title: isEnabled ? L10n.t("disable") : L10n.t("enable"),
                                action: #selector(toggleEnabled),
                                keyEquivalent: "")
        toggle.target = self
        menu.addItem(toggle)

        menu.addItem(NSMenuItem.separator())

        let settings = NSMenuItem(title: L10n.t("settingsMenu"),
                                  action: #selector(openSettings),
                                  keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: L10n.t("quit"),
                              action: #selector(quitApp),
                              keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    // MARK: - Observers

    private func startObserving() {
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(self,
                       selector: #selector(appActivated(_:)),
                       name: NSWorkspace.didActivateApplicationNotification,
                       object: nil)

        // Dock 재클릭 감지 — 같은 앱 아이콘 클릭은 didActivate가 안 옴
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown]
        ) { [weak self] _ in
            self?.handleGlobalMouseDown()
        }
    }

    private func handleGlobalMouseDown() {
        guard isEnabled, hideOnReClick else { return }

        let mouseLoc = NSEvent.mouseLocation
        // NSEvent는 주 디스플레이 bottom-left 원점, AX는 주 디스플레이 top-left 원점.
        // 뒤집기 기준은 항상 "주 디스플레이 높이"여야 함 (NSScreen.main은 활성 앱이
        // 있는 화면이라 보조 모니터일 때 변환이 어긋남 → Dock 아이콘 감지 실패).
        guard let primary = NSScreen.screens.first(where: { $0.frame.origin == .zero }) else { return }
        let axPoint = CGPoint(x: mouseLoc.x, y: primary.frame.maxY - mouseLoc.y)

        let systemElement = AXUIElementCreateSystemWide()
        var elementRef: AXUIElement?
        guard AXUIElementCopyElementAtPosition(systemElement,
                                                Float(axPoint.x), Float(axPoint.y),
                                                &elementRef) == .success,
              let element = elementRef else { return }

        // Dock 아이콘인지 subrole로 식별
        var subroleRef: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subroleRef)
        guard let subrole = subroleRef as? String,
              subrole == "AXApplicationDockItem" else { return }

        // 재클릭 판정: "이미 frontmost인 앱의 Dock 아이콘을 눌렀는가"를 클릭 즉시 확정한다.
        // 기존 방식(0.25초 뒤 frontmost가 안 바뀌었는지 비교)은 이미 활성인 앱을 누르면
        // macOS가 didActivate를 다시 쏘면서 frontmost가 잠깐 흔들려 판정이 어긋났다
        // (카카오톡 등에서 재클릭 숨김 누락).
        //
        // 클릭한 Dock 아이콘이 가리키는 앱을 식별해 frontmost와 비교한다. VSCode처럼 Dock
        // 표시 이름("Visual Studio Code")과 localizedName("Code")이 다른 앱이 있어 이름 비교만으로는
        // 빗나가므로, 번들 경로(AXURL)를 우선 쓰고 없으면 이름으로 보조 판정한다.
        var urlRef: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXURLAttribute as CFString, &urlRef)
        let clickedURL = (urlRef as? URL)?.standardizedFileURL

        var titleRef: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef)
        let clickedTitle = titleRef as? String

        guard let front = NSWorkspace.shared.frontmostApplication, shouldHide(front) else { return }

        let urlMatch = clickedURL != nil && clickedURL == front.bundleURL?.standardizedFileURL
        let titleMatch = clickedTitle != nil && clickedTitle == front.localizedName
        guard urlMatch || titleMatch else { return }

        // minimize 방식: 이미 모든 창이 최소화된 앱을 다시 클릭한 건 "복원" 의도다.
        // (minimize는 앱을 비활성화하지 않아 frontmost로 남으므로, 가드 없이 두면
        // 복원되자마자 다시 최소화돼 창을 영영 못 연다.) 복원되도록 그냥 둔다.
        if useMinimize, allWindowsMinimized(front) {
            log("dock click on already-minimized app — let it restore")
            return
        }

        log("dock re-click on active app: \(front.localizedName ?? "?")")
        let frontPid = front.processIdentifier

        // 클릭 이벤트가 앱에 먼저 전달되도록 아주 짧게 지연한 뒤,
        // 여전히 같은 앱이 frontmost면 숨긴다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            guard NSWorkspace.shared.frontmostApplication?.processIdentifier == frontPid else { return }
            let ok = self.hideApp(front)
            self.log("dock re-click hide returned \(ok)")
        }
    }

    @objc private func appActivated(_ notification: Notification) {
        log("activated notif received, isEnabled=\(isEnabled)")
        guard isEnabled else { return }
        guard let newApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication else {
            log("  no NSRunningApplication in userInfo")
            return
        }
        log("  new app: \(newApp.localizedName ?? "?") (\(newApp.bundleIdentifier ?? "?")) pid=\(newApp.processIdentifier)")
        log("  last app: \(lastActiveApp?.localizedName ?? "nil") pid=\(lastActiveApp?.processIdentifier ?? -1)")

        // 같은 앱이 다시 활성화된 경우(=Dock 재클릭 등)는 handleGlobalMouseDown이
        // 전담한다. 두 경로가 같이 hide를 걸면 frontmost가 흔들려 서로 판정을 깨뜨린다.
        if let last = lastActiveApp,
           last.processIdentifier == newApp.processIdentifier {
            return
        }

        // 새로 활성화된 게 실제 사용자 앱이 아니면(알림센터·제어센터 등 시스템 UI)
        // 전환으로 치지 않는다. lastActiveApp(직전 실제 앱)을 유지해야
        // 시스템 UI가 잠깐 끼어도 다음 진짜 전환에서 직전 앱이 정상 숨김된다.
        guard shouldHide(newApp) else {
            log("  newApp not hideable (system UI?) — keep lastActiveApp")
            return
        }

        if hideOnSwitch, let last = lastActiveApp, shouldHide(last) {
            attemptSwitchHide(last: last, newApp: newApp, retry: true)
        }

        lastActiveApp = newApp
    }

    // 전환 시 이전 앱 숨김. 새 앱이 막 떠 화면 판별(screenFor)이 nil이면 한 번
    // 지연 재시도해 윈도우가 준비된 뒤 정확히 판정한다(같은 화면일 때만 숨김).
    private func attemptSwitchHide(last: NSRunningApplication,
                                   newApp: NSRunningApplication,
                                   retry: Bool) {
        guard shouldHide(last) else { return }
        let newScreen = screenFor(app: newApp)
        let lastScreen = screenFor(app: last)

        if (newScreen == nil || lastScreen == nil), retry, NSScreen.screens.count > 1 {
            log("  screen undetermined — retry after 0.2s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.attemptSwitchHide(last: last, newApp: newApp, retry: false)
            }
            return
        }

        let same = sameScreen(newScreen, lastScreen)
        log("  newScreen=\(newScreen?.localizedName ?? "?") lastScreen=\(lastScreen?.localizedName ?? "?") same=\(same)")
        if same {
            let ok = hideApp(last)
            log("  switch hide returned \(ok)")
        } else {
            log("  different screen — skip hide")
        }
    }

    private func log(_ msg: String) {
        let path = "/tmp/windock.log"
        let line = "\(Date()) \(msg)\n"
        if let data = line.data(using: .utf8) {
            if let fh = FileHandle(forWritingAtPath: path) {
                fh.seekToEndOfFile()
                fh.write(data)
                fh.closeFile()
            } else {
                try? data.write(to: URL(fileURLWithPath: path))
            }
        }
        // 100회마다 최근 500줄만 남기고 정리 — 로그 파일 무한 증가 방지
        logWriteCount += 1
        if logWriteCount >= 100 {
            logWriteCount = 0
            trimLog(path: path, keep: 500)
        }
    }

    private func trimLog(path: String, keep: Int) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else { return }
        var lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count > keep else { return }
        lines = Array(lines.suffix(keep))
        try? lines.joined(separator: "\n").write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func shouldHide(_ app: NSRunningApplication) -> Bool {
        // 자기 자신 제외
        if app.processIdentifier == NSRunningApplication.current.processIdentifier {
            return false
        }
        // 시스템 앱 제외
        if let bid = app.bundleIdentifier, excludedBundleIDs.contains(bid) {
            return false
        }
        // 이미 숨겨진 앱은 건너뜀
        if app.isHidden {
            return false
        }
        // 일반 사용자 앱만 (.regular)
        guard app.activationPolicy == .regular else {
            return false
        }
        return true
    }

    // MARK: - Actions

    @objc private func toggleEnabled() {
        isEnabled.toggle()
        if !isEnabled {
            lastActiveApp = nil
        }
        savePreferences()
        rebuildMenu()
        updateStatusIcon()
    }

    // MARK: - Settings Window

    @objc private func openSettings() {
        if prefsWindow == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
                             styleMask: [.titled, .closable],
                             backing: .buffered, defer: false)
            w.isReleasedWhenClosed = false
            prefsWindow = w
        }
        rebuildPrefsContent()
        prefsWindow?.title = L10n.t("settingsTitle")
        prefsWindow?.center()
        NSApp.activate(ignoringOtherApps: true)
        prefsWindow?.makeKeyAndOrderFront(nil)
    }

    // 설정 창 내용을 매번 새로 그린다 — 언어를 바꾸면 라벨이 즉시 갱신되도록.
    private func rebuildPrefsContent() {
        guard let window = prefsWindow else { return }
        let width: CGFloat = 380, pad: CGFloat = 20, rowH: CGFloat = 24, gap: CGFloat = 14
        let rows = 5
        let height = pad * 2 + CGFloat(rows) * rowH + CGFloat(rows - 1) * gap
        let content = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))

        func checkbox(_ key: String, tag: Int, on: Bool, tooltip: String? = nil) -> NSButton {
            let b = NSButton(checkboxWithTitle: L10n.t(key), target: self,
                             action: #selector(prefCheckboxChanged(_:)))
            b.tag = tag
            b.state = on ? .on : .off
            b.toolTip = tooltip
            return b
        }

        var y = height - pad - rowH
        func addRow(_ v: NSView) {
            v.frame = NSRect(x: pad, y: y, width: width - pad * 2, height: rowH)
            content.addSubview(v)
            y -= rowH + gap
        }

        addRow(checkbox("autoHideSwitch", tag: 1, on: hideOnSwitch))
        addRow(checkbox("hideReclick", tag: 2, on: hideOnReClick))
        addRow(checkbox("minimizeMode", tag: 3, on: useMinimize, tooltip: L10n.t("minimizeTooltip")))

        // 언어: 라벨 + 팝업
        let langLabel = NSTextField(labelWithString: L10n.t("language"))
        langLabel.frame = NSRect(x: pad, y: y + 2, width: 70, height: rowH)
        content.addSubview(langLabel)
        let popup = NSPopUpButton(frame: NSRect(x: pad + 76, y: y - 2, width: 184, height: rowH + 2),
                                  pullsDown: false)
        popup.addItems(withTitles: [L10n.t("languageSystem"), "한국어", "English", "日本語", "中文"])
        let cur = UserDefaults.standard.string(forKey: L10n.prefKey) ?? "system"
        popup.selectItem(at: ["system", "ko", "en", "ja", "zh"].firstIndex(of: cur) ?? 0)
        popup.target = self
        popup.action = #selector(prefLanguageChanged(_:))
        content.addSubview(popup)
        y -= rowH + gap

        // 로그인 시 자동 실행 안내 버튼
        let loginBtn = NSButton(title: L10n.t("launchAtLoginMenu"), target: self,
                                action: #selector(showLaunchAtLoginInfo))
        loginBtn.bezelStyle = .rounded
        loginBtn.frame = NSRect(x: pad, y: y - 2, width: width - pad * 2, height: rowH + 4)
        content.addSubview(loginBtn)

        window.contentView = content
        window.setContentSize(NSSize(width: width, height: height))
    }

    @objc private func prefCheckboxChanged(_ sender: NSButton) {
        let on = sender.state == .on
        switch sender.tag {
        case 1: hideOnSwitch = on
        case 2: hideOnReClick = on
        case 3:
            useMinimize = on
            // minimize를 켰는데 시스템 설정이 꺼져 있으면, 켜기를 제안한다.
            if useMinimize && !isMinimizeToAppEnabled() {
                promptEnableMinimizeToApp()
            }
        default: break
        }
        savePreferences()
    }

    @objc private func prefLanguageChanged(_ sender: NSPopUpButton) {
        let codes = ["system", "ko", "en", "ja", "zh"]
        let idx = max(0, min(sender.indexOfSelectedItem, codes.count - 1))
        UserDefaults.standard.set(codes[idx], forKey: L10n.prefKey)
        rebuildMenu()          // 메뉴 라벨 갱신
        rebuildPrefsContent()  // 창 라벨 즉시 갱신
    }

    // macOS '윈도우를 응용 프로그램 아이콘으로 최소화' 설정 여부.
    private func isMinimizeToAppEnabled() -> Bool {
        CFPreferencesAppSynchronize("com.apple.dock" as CFString)
        let val = CFPreferencesCopyAppValue("minimize-to-application" as CFString,
                                            "com.apple.dock" as CFString)
        return (val as? Bool) ?? false
    }

    private func promptEnableMinimizeToApp() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = L10n.t("dockSettingTitle")
        alert.informativeText = L10n.t("dockSettingBody")
        alert.addButton(withTitle: L10n.t("turnOn"))
        alert.addButton(withTitle: L10n.t("later"))
        if alert.runModal() == .alertFirstButtonReturn {
            enableMinimizeToApp()
        }
    }

    private func enableMinimizeToApp() {
        let write = Process()
        write.launchPath = "/usr/bin/defaults"
        write.arguments = ["write", "com.apple.dock", "minimize-to-application", "-bool", "true"]
        try? write.run()
        write.waitUntilExit()

        let restart = Process()
        restart.launchPath = "/usr/bin/killall"
        restart.arguments = ["Dock"]
        try? restart.run()
        log("enabled minimize-to-application, restarted Dock")
    }

    @objc private func showLaunchAtLoginInfo() {
        let alert = NSAlert()
        alert.messageText = L10n.t("launchInfoTitle")
        alert.informativeText = L10n.t("launchInfoBody")
        alert.addButton(withTitle: L10n.t("ok"))
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Preferences

    private func loadPreferences() {
        let d = UserDefaults.standard
        if d.object(forKey: "isEnabled") != nil {
            isEnabled = d.bool(forKey: "isEnabled")
        }
        if d.object(forKey: "hideOnSwitch") != nil {
            hideOnSwitch = d.bool(forKey: "hideOnSwitch")
        }
        if d.object(forKey: "hideOnReClick") != nil {
            hideOnReClick = d.bool(forKey: "hideOnReClick")
        }
        if d.object(forKey: "useMinimize") != nil {
            useMinimize = d.bool(forKey: "useMinimize")
        }
        rebuildMenu()
    }

    private func savePreferences() {
        let d = UserDefaults.standard
        d.set(isEnabled, forKey: "isEnabled")
        d.set(hideOnSwitch, forKey: "hideOnSwitch")
        d.set(hideOnReClick, forKey: "hideOnReClick")
        d.set(useMinimize, forKey: "useMinimize")
    }
}
