import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleOverlay = Self("toggleOverlay", default: .init(.space, modifiers: .option))
}

extension Notification.Name {
    static let showOverlay = Notification.Name("showOverlay")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    private var overlayManager: OverlayManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prompt for accessibility access only if not already granted
        AccessibilityManager.checkAndPrompt()

        // Set up overlay manager
        overlayManager = OverlayManager(appState: appState)

        // Register global hotkey
        KeyboardShortcuts.onKeyUp(for: .toggleOverlay) { [weak self] in
            Task { @MainActor in
                self?.overlayManager?.toggle()
            }
        }

        // Listen for "Show Switcher" from menu bar
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showOverlay),
            name: .showOverlay,
            object: nil
        )

        // Monitor display configuration changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        appState.refreshMonitors()

        // Ensure the settings window appears on the current space
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeVisible(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )

        // First run: open settings if no groups are configured
        if appState.groups.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
    }

    @objc private func windowDidBecomeVisible(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              !(window is OverlayPanel) else { return }
        window.collectionBehavior.insert(.moveToActiveSpace)
    }

    @objc private func showOverlay() {
        let manager = overlayManager
        Task { @MainActor in
            manager?.show()
        }
    }

    @objc private func screensChanged() {
        appState.refreshMonitors()
    }
}
