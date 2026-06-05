import Cocoa

// raw swiftc 빌드에서는 @main이 AppKit을 자동 부트스트랩하지 않아
// applicationDidFinishLaunching이 호출되지 않음. NSApplication.run()을 명시.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
