import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        TabView {
            GroupsSettingsView()
                .tabItem { Label("Groups", systemImage: "rectangle.3.group") }

            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }
        }
        .frame(width: 580, height: 400)
    }
}

// MARK: - Groups Tab

struct GroupsSettingsView: View {
    @Environment(AppState.self) var appState
    @State private var selectedGroupID: UUID?

    var body: some View {
        HStack(spacing: 0) {
            // Group list
            VStack(spacing: 0) {
                List(selection: $selectedGroupID) {
                    ForEach(appState.groups) { group in
                        Text(group.name)
                            .tag(group.id)
                    }
                }
                .listStyle(.bordered)

                HStack(spacing: 4) {
                    Button(action: addGroup) {
                        Image(systemName: "plus")
                    }
                    Button(action: removeSelected) {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedGroupID == nil)
                }
                .padding(8)
            }
            .frame(width: 180)

            Divider()

            // Editor panel
            if let groupID = selectedGroupID,
               let group = appState.groups.first(where: { $0.id == groupID }) {
                DesktopGroupEditorView(group: group)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                Text("Select or add a group")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }

    private func addGroup() {
        let newGroup = DesktopGroup(
            name: "New Group",
            monitorSpaces: Dictionary(
                uniqueKeysWithValues: appState.monitors.map { ($0.id, $0.desktopNumbers.first ?? 1) }
            )
        )
        appState.addGroup(newGroup)
        selectedGroupID = newGroup.id
    }

    private func removeSelected() {
        guard let id = selectedGroupID,
              let group = appState.groups.first(where: { $0.id == id }) else { return }
        appState.deleteGroup(group)
        selectedGroupID = nil
    }
}

// MARK: - General Tab

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            HotkeySettingsView()
            LaunchAtLogin.Toggle("Launch at login")
        }
        .padding()
    }
}
