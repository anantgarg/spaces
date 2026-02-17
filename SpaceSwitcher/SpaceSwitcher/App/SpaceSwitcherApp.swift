import SwiftUI
import KeyboardShortcuts

@main
struct SpaceSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Spaces", systemImage: "rectangle.3.group.fill") {
            MenuBarView()
                .environment(appDelegate.appState)
        }

        Settings {
            SettingsView()
                .environment(appDelegate.appState)
        }
    }
}
