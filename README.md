# CursorHalo

A tiny macOS menu bar app that draws a colored ring around the mouse cursor so it shows up clearly in gameplay recordings.

## Why

The macOS system cursor is small and easy to lose in a screen recording. CursorHalo sits above every window (including most fullscreen games) and paints a configurable halo that follows the cursor, so external recorders like OBS or QuickTime capture the ring along with the game footage.

## Requirements

- macOS 13+
- Swift 5.9+ / Xcode command-line tools

## Build

```sh
./build-app.sh
```

Produces `CursorHalo.app` in the project root. Double-click it, or:

```sh
open CursorHalo.app
```

A menu bar icon (rays around a cursor) appears; there is no Dock icon (`LSUIElement`). Left-click the icon for the settings menu:

- **Halo Enabled** — turn the ring on/off
- **Color** — pick from six presets
- **Size / Thickness / Opacity** — sliders for the ring
- **Quit**

All settings persist in `UserDefaults` and take effect immediately.

## Dev loop

```sh
swift run
```

Runs the executable directly out of `.build/`. Note: without the `.app` bundle's Info.plist, the process still shows up in the Dock during dev; the bundled build hides it.

## Fullscreen caveat

macOS "true fullscreen" apps live in their own Space. CursorHalo works around this by joining all Spaces and running at the screen-saver window level, which is above native fullscreen. A minority of games that call `CGDisplayCapture` to seize the display exclusively will still hide the overlay — there is no user-space fix for those.

## Permissions

None required. CursorHalo only reads `NSEvent.mouseLocation` (unprivileged) and draws its own window — no Accessibility, no Screen Recording, no entitlements.

## Project layout

```
Package.swift               SwiftPM executable manifest (macOS 13+)
Sources/CursorHalo/
  main.swift                NSApplication bootstrap
  AppDelegate.swift         Menu bar, wiring, screen switching
  OverlayWindow.swift       Transparent click-through NSWindow
  HaloView.swift            CAShapeLayer ring
  CursorTracker.swift       CVDisplayLink + mouse polling
  Settings.swift            UserDefaults-backed knobs
build-app.sh                Bundles CursorHalo.app with Info.plist
```

## License

Personal project — no license declared yet.
