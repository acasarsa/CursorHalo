import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlay: OverlayWindow?
    private let tracker = CursorTracker()
    private var statusItem: NSStatusItem!
    private let settings = Settings.shared

    private var enabledItem: NSMenuItem?
    private var colorMenuItems: [NSMenuItem] = []
    private var radiusItem: NSMenuItem?
    private var thicknessItem: NSMenuItem?
    private var opacityItem: NSMenuItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildStatusItem()
        settings.onChange = { [weak self] in self?.applySettings() }
        if settings.enabled { startOverlay() }
        applySettings()
    }

    // MARK: overlay lifecycle

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

    private func applySettings() {
        guard let halo = overlay?.halo else { return }
        halo.ringColor = settings.color
        halo.ringRadius = settings.radius
        halo.ringThickness = settings.thickness
        halo.ringOpacity = settings.opacity
    }

    // MARK: menu

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "cursorarrow.rays",
                accessibilityDescription: "CursorHalo"
            )
        }

        let menu = NSMenu()
        menu.autoenablesItems = false

        let toggle = NSMenuItem(
            title: "Halo Enabled",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        toggle.target = self
        toggle.state = settings.enabled ? .on : .off
        enabledItem = toggle
        menu.addItem(toggle)
        menu.addItem(NSMenuItem.separator())

        let colorParent = NSMenuItem(title: "Color", action: nil, keyEquivalent: "")
        let colorSubmenu = NSMenu()
        for preset in HaloPresets.all {
            let item = NSMenuItem(
                title: preset.name,
                action: #selector(selectColor(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = preset.color
            colorSubmenu.addItem(item)
            colorMenuItems.append(item)
        }
        colorParent.submenu = colorSubmenu
        menu.addItem(colorParent)

        radiusItem = addSliderRow(
            to: menu,
            title: "Size",
            value: settings.radius,
            range: 8...80,
            action: #selector(sliderRadiusChanged(_:))
        )
        thicknessItem = addSliderRow(
            to: menu,
            title: "Thickness",
            value: settings.thickness,
            range: 1...12,
            action: #selector(sliderThicknessChanged(_:))
        )
        opacityItem = addSliderRow(
            to: menu,
            title: "Opacity",
            value: settings.opacity,
            range: 0.1...1.0,
            action: #selector(sliderOpacityChanged(_:))
        )

        menu.addItem(NSMenuItem.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
        refreshColorChecks()
    }

    private func addSliderRow(
        to menu: NSMenu,
        title: String,
        value: CGFloat,
        range: ClosedRange<CGFloat>,
        action: Selector
    ) -> NSMenuItem {
        let header = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        let slider = NSSlider(frame: NSRect(x: 16, y: 2, width: 176, height: 20))
        slider.minValue = Double(range.lowerBound)
        slider.maxValue = Double(range.upperBound)
        slider.doubleValue = Double(value)
        slider.target = self
        slider.action = action
        slider.isContinuous = true
        container.addSubview(slider)

        let item = NSMenuItem()
        item.view = container
        menu.addItem(item)
        return item
    }

    private func refreshColorChecks() {
        let current = settings.color.hexString
        for item in colorMenuItems {
            let itemHex = (item.representedObject as? NSColor)?.hexString ?? ""
            item.state = (itemHex == current) ? .on : .off
        }
    }

    // MARK: actions

    @objc private func toggleEnabled(_ sender: NSMenuItem) {
        let newValue = !settings.enabled
        settings.enabled = newValue
        sender.state = newValue ? .on : .off
        if newValue { startOverlay(); applySettings() } else { stopOverlay() }
    }

    @objc private func selectColor(_ sender: NSMenuItem) {
        guard let color = sender.representedObject as? NSColor else { return }
        settings.color = color
        refreshColorChecks()
    }

    @objc private func sliderRadiusChanged(_ sender: NSSlider) {
        settings.radius = CGFloat(sender.doubleValue)
    }

    @objc private func sliderThicknessChanged(_ sender: NSSlider) {
        settings.thickness = CGFloat(sender.doubleValue)
    }

    @objc private func sliderOpacityChanged(_ sender: NSSlider) {
        settings.opacity = CGFloat(sender.doubleValue)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
