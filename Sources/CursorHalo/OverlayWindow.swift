import AppKit

final class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        setFrame(screen.frame, display: false)

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        isReleasedWhenClosed = false

        // Sit above native fullscreen apps.
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))

        // Follow the cursor across Spaces and float above fullscreen apps.
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        let halo = HaloView(frame: CGRect(origin: .zero, size: screen.frame.size))
        halo.wantsLayer = true
        contentView = halo
    }

    var halo: HaloView? { contentView as? HaloView }
}
