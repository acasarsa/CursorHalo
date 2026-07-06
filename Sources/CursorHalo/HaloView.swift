import AppKit

final class HaloView: NSView {
    private let ringLayer = CAShapeLayer()

    var ringColor: NSColor = .systemYellow { didSet { applyStyle() } }
    var ringRadius: CGFloat = 24 { didSet { rebuildPath() } }
    var ringThickness: CGFloat = 3 { didSet { applyStyle() } }
    var ringOpacity: CGFloat = 0.85 { didSet { applyStyle() } }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.addSublayer(ringLayer)
        ringLayer.fillColor = NSColor.clear.cgColor
        // Soft glow reads better on video than a bare stroke.
        ringLayer.shadowRadius = 6
        ringLayer.shadowOpacity = 0.6
        applyStyle()
        rebuildPath()
        moveRing(to: NSPoint(x: bounds.midX, y: bounds.midY))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not used") }

    func moveRing(to point: NSPoint) {
        let size = ringRadius * 2 + ringThickness
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
        ringLayer.strokeColor = ringColor.withAlphaComponent(ringOpacity).cgColor
        ringLayer.shadowColor = ringColor.cgColor
        ringLayer.lineWidth = ringThickness
    }

    private func rebuildPath() {
        let size = ringRadius * 2 + ringThickness
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
            .insetBy(dx: ringThickness / 2, dy: ringThickness / 2)
        ringLayer.path = CGPath(ellipseIn: rect, transform: nil)
    }
}
