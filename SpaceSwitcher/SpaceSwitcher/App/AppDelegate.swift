import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleOverlay = Self("toggleOverlay", default: .init(.space, modifiers: .option))
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

        // Monitor display configuration changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        appState.refreshMonitors()

        // First run: open settings if no groups are configured
        if appState.groups.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
    }

    @objc private func screensChanged() {
        appState.refreshMonitors()
    }
}
