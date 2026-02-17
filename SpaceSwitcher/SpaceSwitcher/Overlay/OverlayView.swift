import SwiftUI

struct OverlayView: View {
    @Environment(AppState.self) var appState
    @Environment(OverlayState.self) var overlayState
    var onGroupSelected: (DesktopGroup) -> Void

    var body: some View {
        let focusedIndex = overlayState.focusedIndex

        VStack(spacing: 0) {
            // Focused group name at top
            if !appState.groups.isEmpty {
                Text(appState.groups[focusedIndex].name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
            }

            // Horizontal icon strip
            HStack(spacing: 24) {
                ForEach(Array(appState.groups.enumerated()), id: \.element.id) { index, group in
                    SwitcherIcon(
                        group: group,
                        isFocused: index == focusedIndex,
                        shortcutNumber: index + 1
                    ) {
                        onGroupSelected(group)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 22)
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(white: 0.12))
        )
        .animation(.easeInOut(duration: 0.15), value: focusedIndex)
    }
}

// MARK: - Switcher Icon

private struct SwitcherIcon: View {
    let group: DesktopGroup
    let isFocused: Bool
    let shortcutNumber: Int
    let action: () -> Void

    private let tileSize: CGFloat = 100

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Icon tile background - brighter when focused
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(isFocused ? 0.25 : 0.1))
                        .frame(width: tileSize, height: tileSize)

                    // Colorful icon
                    Image(systemName: group.icon)
                        .font(.system(size: 46, weight: .medium))
                        .foregroundStyle(group.color)
                        .frame(width: tileSize, height: tileSize)
                }

                // Group name
                Text(group.name)
                    .font(.system(size: 13, weight: isFocused ? .bold : .medium))
                    .foregroundStyle(.white.opacity(isFocused ? 0.95 : 0.6))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: tileSize + 12)

                // Keyboard shortcut hint
                Text("\u{2303}\(shortcutNumber)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .buttonStyle(.plain)
    }
}
