import Foundation
import SwiftUI

struct DesktopGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String       // SF Symbol name
    var colorName: String  // Color identifier
    var monitorSpaces: [String: Int]  // "Left" → 2, "Right" → 3

    init(id: UUID = UUID(), name: String, icon: String = "desktopcomputer",
         colorName: String = "blue", monitorSpaces: [String: Int] = [:]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.monitorSpaces = monitorSpaces
    }

    var color: Color {
        Self.colorMap[colorName] ?? .blue
    }

    /// Pick a random icon + color combo.
    static func randomAppearance() -> (icon: String, color: String) {
        let icon = availableIcons.randomElement() ?? "desktopcomputer"
        let color = availableColors.randomElement()?.name ?? "blue"
        return (icon, color)
    }

    // MARK: - Available Icons

    static let availableIcons = [
        "desktopcomputer",
        "laptopcomputer",
        "display",
        "terminal.fill",
        "globe",
        "envelope.fill",
        "bubble.left.and.bubble.right.fill",
        "video.fill",
        "music.note",
        "paintbrush.fill",
        "photo.fill",
        "doc.text.fill",
        "folder.fill",
        "gear",
        "wrench.and.screwdriver.fill",
        "gamecontroller.fill",
        "cart.fill",
        "creditcard.fill",
        "chart.bar.fill",
        "books.vertical.fill",
        "graduationcap.fill",
        "briefcase.fill",
        "hammer.fill",
        "star.fill",
        "heart.fill",
        "bolt.fill",
        "flame.fill",
        "leaf.fill",
        "camera.fill",
        "headphones",
    ]

    // MARK: - Available Colors

    struct NamedColor: Hashable {
        let name: String
        let color: Color
    }

    static let availableColors: [NamedColor] = [
        NamedColor(name: "blue",    color: .blue),
        NamedColor(name: "purple",  color: .purple),
        NamedColor(name: "pink",    color: .pink),
        NamedColor(name: "red",     color: .red),
        NamedColor(name: "orange",  color: .orange),
        NamedColor(name: "yellow",  color: .yellow),
        NamedColor(name: "green",   color: .green),
        NamedColor(name: "mint",    color: .mint),
        NamedColor(name: "teal",    color: .teal),
        NamedColor(name: "cyan",    color: .cyan),
        NamedColor(name: "indigo",  color: .indigo),
        NamedColor(name: "brown",   color: .brown),
    ]

    static let colorMap: [String: Color] = Dictionary(
        uniqueKeysWithValues: availableColors.map { ($0.name, $0.color) }
    )
}
