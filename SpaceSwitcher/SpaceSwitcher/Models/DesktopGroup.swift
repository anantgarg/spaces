import Foundation

struct DesktopGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var monitorSpaces: [String: Int]  // "Left" → 2, "Right" → 3

    init(id: UUID = UUID(), name: String, monitorSpaces: [String: Int] = [:]) {
        self.id = id
        self.name = name
        self.monitorSpaces = monitorSpaces
    }
}
