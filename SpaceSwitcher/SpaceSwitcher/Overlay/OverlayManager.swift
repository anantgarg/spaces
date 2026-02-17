import AppKit
import SwiftUI

@MainActor
final class OverlayManager {
    private var panels: [OverlayPanel] = []
    private var appState: AppState
    private var clickMonitor: Any?
    private var keyMonitor: Any?
    private var focusedIndex: Int = 0

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
            focusedIndex = idx
        } else {
            focusedIndex = 0
        }

        rebuildPanels()

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
            appState.switchToGroup(groups[focusedIndex])
            dismiss()
            return true
        case 123: // Left arrow
            focusedIndex = (focusedIndex - 1 + groups.count) % groups.count
            rebuildPanels()
            return true
        case 124: // Right arrow
            focusedIndex = (focusedIndex + 1) % groups.count
            rebuildPanels()
            return true
        default:
            // Number keys 1-9
            if let chars = event.characters, let digit = Int(chars), digit >= 1, digit <= groups.count {
                appState.switchToGroup(groups[digit - 1])
                dismiss()
                return true
            }
            return false
        }
    }

    private func rebuildPanels() {
        // Remove old panels
        for panel in panels {
            panel.orderOut(nil)
        }
        panels.removeAll()

        for screen in NSScreen.screens {
            let panel = OverlayPanel(contentRect: NSRect(x: 0, y: 0, width: 520, height: 500))

            let overlayView = OverlayView(
                focusedIndex: focusedIndex,
                onGroupSelected: { [weak self] group in
                    self?.appState.switchToGroup(group)
                    self?.dismiss()
                }
            )
            .environment(appState)

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

    func dismiss() {
        for panel in panels {
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
