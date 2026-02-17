import SwiftUI
import KeyboardShortcuts

@main
struct SpaceSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("SpaceSwitcher", systemImage: "rectangle.3.group") {
            MenuBarView()
                .environment(appDelegate.appState)
        }

        Settings {
            SettingsView()
                .environment(appDelegate.appState)
        }
    }
}
