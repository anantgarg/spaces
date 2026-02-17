import AppKit

extension NSScreen {
    /// The CGDirectDisplayID for this screen.
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        return deviceDescription[key] as? CGDirectDisplayID ?? 0
    }

    /// Frame in CoreGraphics coordinate system (top-left origin).
    /// NSScreen uses bottom-left origin; CG uses top-left origin.
    var cgFrame: CGRect {
        guard let mainScreen = NSScreen.screens.first else { return frame }
        let mainHeight = mainScreen.frame.height
        return CGRect(
            x: frame.origin.x,
            y: mainHeight - frame.origin.y - frame.height,
            width: frame.width,
            height: frame.height
        )
    }
}
