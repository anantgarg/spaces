import AppKit
import SwiftUI

@MainActor
final class OverlayManager {
    private var panels: [OverlayPanel] = []
    private var appState: AppState
    private var globalMonitor: Any?

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
        dismiss()  // Clean up any existing panels

        // Refresh detection so the overlay highlights the current group
        appState.refreshMonitors()
        appState.detectActiveGroup()

        // Create one panel per screen
        for screen in NSScreen.screens {
            let panel = OverlayPanel(contentRect: NSRect(x: 0, y: 0, width: 520, height: 500))

            let overlayView = OverlayView(
                onGroupSelected: { [weak self] group in
                    self?.appState.switchToGroup(group)
                    self?.dismiss()
                },
                onMoveWindow: { [weak self] windowID, group in
                    guard let self else { return }
                    for (monitorLabel, spaceNumber) in group.monitorSpaces {
                        WindowManager.moveWindow(
                            windowID,
                            toSpaceNumber: spaceNumber,
                            onMonitor: monitorLabel,
                            monitors: self.appState.monitors
                        )
                        break
                    }
                },
                onDismiss: { [weak self] in
                    self?.dismiss()
                }
            )
            .environment(appState)

            let hostingView = NSHostingView(rootView: overlayView)
            panel.contentView = hostingView

            // Size to fit content
            hostingView.layoutSubtreeIfNeeded()
            let fittingSize = hostingView.fittingSize
            panel.setContentSize(fittingSize)

            // Center on this screen
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - fittingSize.width / 2
            let y = screenFrame.midY - fittingSize.height / 2
            panel.setFrameOrigin(NSPoint(x: x, y: y))

            panel.makeKeyAndOrderFront(nil)
            panels.append(panel)
        }

        // Click-outside dismissal
        globalMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.dismiss()
        }
    }

    func dismiss() {
        for panel in panels {
            panel.orderOut(nil)
        }
        panels.removeAll()

        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
    }
}
