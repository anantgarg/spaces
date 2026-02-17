import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        ForEach(appState.groups) { group in
            Button {
                appState.switchToGroup(group)
            } label: {
                HStack {
                    Text(group.name)
                    if appState.activeGroupID == group.id {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }

        if !appState.groups.isEmpty {
            Divider()
        }

        SettingsLink {
            Text("Settings\u{2026}")
        }

        Divider()

        Button("Quit SpaceSwitcher") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
