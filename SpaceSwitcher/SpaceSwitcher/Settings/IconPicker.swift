import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: String
    @State private var showPopover = false

    private var color: Color {
        DesktopGroup.colorMap[selectedColor] ?? .blue
    }

    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            Image(systemName: selectedIcon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover) {
            VStack(alignment: .leading, spacing: 12) {
                // Color picker
                Text("Color")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(DesktopGroup.availableColors, id: \.name) { namedColor in
                        Button {
                            selectedColor = namedColor.name
                        } label: {
                            Circle()
                                .fill(namedColor.color)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: selectedColor == namedColor.name ? 2 : 0)
                                )
                                .shadow(color: namedColor.color.opacity(0.5), radius: selectedColor == namedColor.name ? 3 : 0)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()

                // Icon grid
                Text("Icon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: 6), count: 6), spacing: 6) {
                    ForEach(DesktopGroup.availableIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            showPopover = false
                        } label: {
                            Image(systemName: icon)
                                .font(.system(size: 18))
                                .foregroundStyle(color)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? color.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(selectedIcon == icon ? color : Color.clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(14)
        }
    }
}
