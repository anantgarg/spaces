import AppKit

final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        appearance = NSAppearance(named: .vibrantDark)
        acceptsMouseMovedEvents = true
    }

    // Ensure the panel receives key events even as a non-activating panel
    override func keyDown(with event: NSEvent) {
        // Let SwiftUI handle it — don't call super which would beep
    }
}
