import AppKit
import SwiftUI

@Observable
@MainActor
final class OverlayState {
    var focusedIndex: Int = 0
}

@MainActor
final class OverlayManager {
    private var panels: [OverlayPanel] = []
    private var appState: AppState
    private var overlayState = OverlayState()
    private var clickMonitor: Any?
    private var keyMonitor: Any?

    var isVisible: Bool { panels.contains { $0.isVisible } }

    init(appState: AppState) {
        self.appState = appState
    }

    func toggle() {
        if isVisible {
            dismiss()
        } else {
            show()
        }
    }

    func show() {
        dismiss()

        appState.refreshMonitors()
        appState.detectActiveGroup()

        guard !appState.groups.isEmpty else { return }

        // Start focused on the active group
        if let activeID = appState.activeGroupID,
           let idx = appState.groups.firstIndex(where: { $0.id == activeID }) {
            overlayState.focusedIndex = idx
        } else {
            overlayState.focusedIndex = 0
        }

        buildPanels()

        // Keyboard handling via local monitor (reliable for non-activating panels)
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return self.handleKeyDown(event) ? nil : event
        }

        // Click-outside dismissal
        clickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.dismiss()
        }
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        let groups = appState.groups
        guard !groups.isEmpty else { return false }

        switch Int(event.keyCode) {
        case 53: // Escape
            dismiss()
            return true
        case 36: // Return
            dismissThenSwitch(groups[overlayState.focusedIndex])
            return true
        case 123: // Left arrow
            overlayState.focusedIndex = (overlayState.focusedIndex - 1 + groups.count) % groups.count
            return true
        case 124: // Right arrow
            overlayState.focusedIndex = (overlayState.focusedIndex + 1) % groups.count
            return true
        default:
            // Number keys 1-9
            if let chars = event.characters, let digit = Int(chars), digit >= 1, digit <= groups.count {
                dismissThenSwitch(groups[digit - 1])
                return true
            }
            return false
        }
    }

    private func buildPanels() {
        for screen in NSScreen.screens {
            let panel = OverlayPanel(contentRect: NSRect(x: 0, y: 0, width: 520, height: 500))

            let overlayView = OverlayView(
                onGroupSelected: { [weak self] group in
                    self?.dismissThenSwitch(group)
                }
            )
            .environment(appState)
            .environment(overlayState)

            let hostingView = NSHostingView(rootView: overlayView)
            panel.contentView = hostingView

            hostingView.layoutSubtreeIfNeeded()
            let fittingSize = hostingView.fittingSize
            panel.setContentSize(fittingSize)

            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - fittingSize.width / 2
            let y = screenFrame.midY - fittingSize.height / 2
            panel.setFrameOrigin(NSPoint(x: x, y: y))

            panel.makeKeyAndOrderFront(nil)
            panels.append(panel)
        }
    }

    /// Dismiss the overlay, then switch spaces after a brief delay to avoid flashing.
    private func dismissThenSwitch(_ group: DesktopGroup) {
        dismiss()
        let state = appState
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            state.switchToGroup(group)
        }
    }

    func dismiss() {
        for panel in panels {
            panel.alphaValue = 0
            panel.orderOut(nil)
        }
        panels.removeAll()

        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
}
