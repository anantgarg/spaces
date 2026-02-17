import SwiftUI

struct OverlayView: View {
    @Environment(AppState.self) var appState
    var onGroupSelected: (DesktopGroup) -> Void
    var onMoveWindow: (CGWindowID, DesktopGroup) -> Void
    var onDismiss: () -> Void

    @State private var windows: [WindowInfo] = []

    var body: some View {
        VStack(spacing: 0) {
            // Desktop group tabs
            groupTabs
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()

            // Window list with move buttons
            windowList
        }
        .frame(width: 520)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .onAppear {
            windows = WindowManager.listWindows()
        }
        .onKeyPress(.escape) {
            onDismiss()
            return .handled
        }
        .onKeyPress(characters: .decimalDigits) { press in
            guard let digit = Int(press.characters),
                  digit >= 1,
                  digit <= appState.groups.count else {
                return .ignored
            }
            onGroupSelected(appState.groups[digit - 1])
            return .handled
        }
    }

    // MARK: - Group Tabs

    private var groupTabs: some View {
        HStack(spacing: 8) {
            ForEach(Array(appState.groups.enumerated()), id: \.element.id) { index, group in
                GroupTabButton(
                    group: group,
                    isActive: appState.activeGroupID == group.id,
                    shortcutNumber: index + 1
                ) {
                    onGroupSelected(group)
                }
            }
        }
    }

    // MARK: - Window List

    @ViewBuilder
    private var windowList: some View {
        if windows.isEmpty {
            Text("No windows found")
                .foregroundStyle(.secondary)
                .padding(24)
        } else {
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(windows) { window in
                        WindowRow(
                            window: window,
                            groups: appState.groups,
                            onMove: { group in
                                onMoveWindow(window.id, group)
                            }
                        )
                    }
                }
                .padding(12)
            }
            .frame(maxHeight: 400)
        }
    }
}

// MARK: - Group Tab Button

private struct GroupTabButton: View {
    let group: DesktopGroup
    let isActive: Bool
    let shortcutNumber: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("\(shortcutNumber)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: 16)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 3))

                Text(group.name)
                    .fontWeight(isActive ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color.accentColor.opacity(0.2) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isActive ? Color.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Window Row

private struct WindowRow: View {
    let window: WindowInfo
    let groups: [DesktopGroup]
    let onMove: (DesktopGroup) -> Void

    var body: some View {
        HStack(spacing: 8) {
            // App icon
            if let icon = window.appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app.fill")
                    .frame(width: 20, height: 20)
            }

            // Window info
            VStack(alignment: .leading, spacing: 1) {
                Text(window.appName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !window.title.isEmpty {
                    Text(window.title)
                        .font(.body)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Move-to-group buttons
            HStack(spacing: 4) {
                ForEach(groups) { group in
                    Button {
                        onMove(group)
                    } label: {
                        Text(group.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(.quaternary)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                    .help("Move to \(group.name)")
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
