import AppKit

final class HaloView: NSView {
    private let ringLayer = CAShapeLayer()

    var ringColor: NSColor = .systemPink { didSet { applyStyle() } }
    var ringRadius: CGFloat = 24 { didSet { rebuildPath() } }
    var ringOpacity: CGFloat = 0.55 { didSet { applyStyle() } }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.addSublayer(ringLayer)
        ringLayer.strokeColor = NSColor.clear.cgColor
        ringLayer.lineWidth = 0
        // Soft glow helps the disc pop on busy backgrounds.
        ringLayer.shadowRadius = 8
        ringLayer.shadowOpacity = 0.7
        applyStyle()
        rebuildPath()
        moveRing(to: NSPoint(x: bounds.midX, y: bounds.midY))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    func moveRing(to point: NSPoint) {
        let size = ringRadius * 2
        let frame = CGRect(
            x: point.x - size / 2,
            y: point.y - size / 2,
            width: size,
            height: size
        )
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ringLayer.frame = frame
        CATransaction.commit()
    }

    private func applyStyle() {
        ringLayer.fillColor = ringColor.withAlphaComponent(ringOpacity).cgColor
        ringLayer.shadowColor = ringColor.cgColor
    }

    private func rebuildPath() {
        let size = ringRadius * 2
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        ringLayer.path = CGPath(ellipseIn: rect, transform: nil)
    }
}
