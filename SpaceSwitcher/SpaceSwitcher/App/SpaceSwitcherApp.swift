import SwiftUI
import KeyboardShortcuts

@main
struct SpaceSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private var menuBarIcon: String {
        // Production (Spaces) uses outline, dev (SpaceSwitcher) uses filled
        Bundle.main.bundleIdentifier == "com.spaceswitcher.Spaces"
            ? "rectangle.3.group"
            : "rectangle.3.group.fill"
    }

    var body: some Scene {
        MenuBarExtra("Spaces", systemImage: menuBarIcon) {
            MenuBarView()
                .environment(appDelegate.appState)
        }

        Settings {
            SettingsView()
                .environment(appDelegate.appState)
        }
    }
}
