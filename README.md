# CursorHalo

A tiny macOS menu bar app that draws a colored ring around the mouse cursor so it shows up clearly in gameplay recordings.

## Why

The macOS system cursor is small and easy to lose in a screen recording. CursorHalo sits above every window (including most fullscreen games) and paints a configurable halo that follows the cursor, so external recorders like OBS or QuickTime capture the ring along with the game footage.

## Status

Early scaffold. See `git log` for progress — each commit ships one small, working piece.

## Requirements

- macOS 13+
- Swift 5.9+ / Xcode command-line tools

## Build & run (dev)

```sh
swift run
```

That's it for now. A packaged `.app` build comes later.

## Fullscreen caveat

macOS "true fullscreen" apps live in their own Space. CursorHalo works around this by joining all Spaces and running at the screen-saver window level, which is above native fullscreen. A minority of games that call `CGDisplayCapture` to seize the display exclusively will still hide the overlay — there's no user-space fix for those.
