import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) var appState
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        ForEach(appState.groups) { group in
            Button {
                appState.switchToGroup(group)
            } label: {
                HStack {
                    Image(group.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
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

        Button("New Group\u{2026}") {
            addGroupFromMenu()
        }

        SettingsLink {
            Text("Settings\u{2026}")
        }

        Divider()

        Button("Quit Spaces") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func addGroupFromMenu() {
        let currentSpaces = SpaceSwitcherService.getCurrentSpacePerDisplay()
        let monitorSpaces = Dictionary(uniqueKeysWithValues: appState.monitors.map { monitor -> (String, Int) in
            if let currentSpaceID = currentSpaces[monitor.displayUUID],
               let spaceInfo = monitor.spaces.first(where: { $0.spaceID == currentSpaceID }) {
                return (monitor.id, spaceInfo.desktopNumber)
            }
            return (monitor.id, monitor.desktopNumbers.first ?? 1)
        })

        let appearance = DesktopGroup.randomAppearance()
        let newGroup = DesktopGroup(name: "New Group", icon: appearance.icon,
                                    colorName: appearance.color, monitorSpaces: monitorSpaces)
        appState.addGroup(newGroup)
        appState.pendingSelectGroupID = newGroup.id

        openSettings()
    }
}
