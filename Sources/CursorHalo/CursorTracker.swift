import AppKit
import CoreVideo

final class CursorTracker {
    var onTick: ((NSPoint) -> Void)?

    private var displayLink: CVDisplayLink?

    func start() {
        guard displayLink == nil else { return }
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link else { return }

        CVDisplayLinkSetOutputCallback(link, { _, _, _, _, _, userInfo -> CVReturn in
            guard let userInfo else { return kCVReturnSuccess }
            let tracker = Unmanaged<CursorTracker>.fromOpaque(userInfo).takeUnretainedValue()
            tracker.tick()
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        CVDisplayLinkStart(link)
        displayLink = link
    }

    func stop() {
        guard let link = displayLink else { return }
        CVDisplayLinkStop(link)
        displayLink = nil
    }

    private func tick() {
        let location = NSEvent.mouseLocation
        DispatchQueue.main.async { [weak self] in
            self?.onTick?(location)
        }
    }

    deinit { stop() }
}
