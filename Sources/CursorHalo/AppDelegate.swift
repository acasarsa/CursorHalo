import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlay: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else { return }
        let window = OverlayWindow(screen: screen)
        window.orderFrontRegardless()
        overlay = window
    }
}
