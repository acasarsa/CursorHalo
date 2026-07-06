import AppKit

struct HaloPreset {
    let name: String
    let color: NSColor
}

enum HaloPresets {
    static let all: [HaloPreset] = [
        .init(name: "Yellow", color: .systemYellow),
        .init(name: "Red",    color: .systemRed),
        .init(name: "Green",  color: .systemGreen),
        .init(name: "Cyan",   color: .systemCyan),
        .init(name: "Magenta", color: .systemPink),
        .init(name: "White",  color: .white),
    ]
}

final class Settings {
    static let shared = Settings()

    private enum Key {
        static let colorHex = "halo.colorHex"
        static let radius = "halo.radius"
        static let thickness = "halo.thickness"
        static let opacity = "halo.opacity"
        static let enabled = "halo.enabled"
    }

    private let defaults = UserDefaults.standard

    var onChange: (() -> Void)?

    init() {
        defaults.register(defaults: [
            Key.colorHex: HaloPresets.all[0].color.hexString,
            Key.radius: 24.0,
            Key.thickness: 3.0,
            Key.opacity: 0.85,
            Key.enabled: true,
        ])
    }

    var color: NSColor {
        get { NSColor(hex: defaults.string(forKey: Key.colorHex) ?? "") ?? .systemYellow }
        set { defaults.set(newValue.hexString, forKey: Key.colorHex); onChange?() }
    }

    var radius: CGFloat {
        get { CGFloat(defaults.double(forKey: Key.radius)) }
        set { defaults.set(Double(newValue), forKey: Key.radius); onChange?() }
    }

    var thickness: CGFloat {
        get { CGFloat(defaults.double(forKey: Key.thickness)) }
        set { defaults.set(Double(newValue), forKey: Key.thickness); onChange?() }
    }

    var opacity: CGFloat {
        get { CGFloat(defaults.double(forKey: Key.opacity)) }
        set { defaults.set(Double(newValue), forKey: Key.opacity); onChange?() }
    }

    var enabled: Bool {
        get { defaults.bool(forKey: Key.enabled) }
        set { defaults.set(newValue, forKey: Key.enabled); onChange?() }
    }
}

extension NSColor {
    var hexString: String {
        guard let rgb = usingColorSpace(.deviceRGB) else { return "#FFFF00" }
        let r = Int(round(rgb.redComponent * 255))
        let g = Int(round(rgb.greenComponent * 255))
        let b = Int(round(rgb.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        self.init(
            red: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
