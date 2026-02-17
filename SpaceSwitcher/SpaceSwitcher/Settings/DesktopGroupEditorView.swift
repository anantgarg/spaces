import SwiftUI

struct DesktopGroupEditorView: View {
    @Environment(AppState.self) var appState
    let group: DesktopGroup

    @State private var name: String = ""
    @State private var icon: String = "Labtop"
    @State private var monitorSpaces: [String: Int] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                LabeledContent("Group Name:") {
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                LabeledContent("Icon:") {
                    IconPicker(selectedIcon: $icon)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Monitor \u{2192} Space Mapping")
                    .font(.headline)

                ForEach(appState.monitors) { monitor in
                    MonitorMappingView(
                        monitor: monitor,
                        spaceNumber: Binding(
                            get: { monitorSpaces[monitor.id] ?? monitor.desktopNumbers.first ?? 1 },
                            set: { monitorSpaces[monitor.id] = $0 }
                        )
                    )
                }

                if appState.monitors.isEmpty {
                    Text("No monitors detected")
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Spacer()
                Button("Apply") {
                    var updated = group
                    updated.name = name
                    updated.icon = icon
                    updated.monitorSpaces = monitorSpaces
                    appState.updateGroup(updated)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            name = group.name
            icon = group.icon
            monitorSpaces = group.monitorSpaces
        }
        .onChange(of: group.id) {
            name = group.name
            icon = group.icon
            monitorSpaces = group.monitorSpaces
        }
    }
}
