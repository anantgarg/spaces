import SwiftUI

struct IconPicker: View {
    @Binding var selectedIcon: String
    @State private var showPopover = false

    var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            Image(selectedIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPopover) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 6), count: 8), spacing: 6) {
                    ForEach(DesktopGroup.availableIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            showPopover = false
                        } label: {
                            Image(icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .strokeBorder(selectedIcon == icon ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)
            }
            .frame(width: 420, height: 300)
        }
    }
}
