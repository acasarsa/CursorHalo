import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlay: OverlayWindow?
    private let tracker = CursorTracker()

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = NSScreen.main else { return }
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
}
