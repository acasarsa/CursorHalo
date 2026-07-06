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

        let content = NSView(frame: screen.frame)
        content.wantsLayer = true
        content.layer?.backgroundColor = NSColor.clear.cgColor
        contentView = content
    }
}
