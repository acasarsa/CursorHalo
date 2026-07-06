import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlay: OverlayWindow?
    private let tracker = CursorTracker()
    private var statusItem: NSStatusItem!
    private var enabled = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildStatusItem()
        startOverlay()
    }

    private func startOverlay() {
        guard overlay == nil, let screen = NSScreen.main else { return }
        let window = OverlayWindow(screen: screen)
        window.orderFrontRegardless()
        overlay = window

        tracker.onTick = { [weak self] globalPoint in
            guard let window = self?.overlay, let halo = window.halo else { return }
            let local = NSPoint(
                x: globalPoint.x - window.frame.origin.x,
                y: globalPoint.y - window.frame.origin.y
            )
            halo.moveRing(to: local)
        }
        tracker.start()
    }

    private func stopOverlay() {
        tracker.stop()
        overlay?.orderOut(nil)
        overlay = nil
    }

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "cursorarrow.rays",
                accessibilityDescription: "CursorHalo"
            )
        }

        let menu = NSMenu()
        let toggle = NSMenuItem(
            title: "Halo Enabled",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        toggle.target = self
        toggle.state = .on
        menu.addItem(toggle)
        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc private func toggleEnabled(_ sender: NSMenuItem) {
        enabled.toggle()
        sender.state = enabled ? .on : .off
        if enabled { startOverlay() } else { stopOverlay() }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
