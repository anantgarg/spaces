import SwiftUI

struct OverlayView: View {
    @Environment(AppState.self) var appState
    @Environment(OverlayState.self) var overlayState
    var onGroupSelected: (DesktopGroup) -> Void

    var body: some View {
        let focusedIndex = overlayState.focusedIndex

        VStack(spacing: 8) {
            // Horizontal icon strip
            HStack(spacing: 8) {
                ForEach(Array(appState.groups.enumerated()), id: \.element.id) { index, group in
                    SwitcherIcon(
                        group: group,
                        isFocused: index == focusedIndex
                    ) {
                        onGroupSelected(group)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Single centered label for selected item only
            if !appState.groups.isEmpty {
                Text(appState.groups[focusedIndex].name)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
        .padding(.bottom, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(white: 0.12))
        )
        .animation(.easeInOut(duration: 0.15), value: focusedIndex)
    }
}

// MARK: - Switcher Icon

private struct SwitcherIcon: View {
    let group: DesktopGroup
    let isFocused: Bool
    let action: () -> Void

    private let iconSize: CGFloat = 64
    private let frameSize: CGFloat = 80

    var body: some View {
        Button(action: action) {
            ZStack {
                // Selection highlight — only for focused item
                if isFocused {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: frameSize, height: frameSize)
                }

                // Icon
                Image(group.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
            }
            .frame(width: frameSize, height: frameSize)
        }
        .buttonStyle(.plain)
    }
}
