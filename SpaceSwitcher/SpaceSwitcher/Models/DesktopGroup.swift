import Foundation
import SwiftUI

struct DesktopGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String       // Icon asset name
    var colorName: String  // Unused legacy field, kept for decoding compatibility
    var monitorSpaces: [String: Int]  // "Left" → 3 means "3rd space on Left monitor" (1-based per-monitor index)

    init(id: UUID = UUID(), name: String, icon: String = "Labtop",
         colorName: String = "blue", monitorSpaces: [String: Int] = [:]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorName = colorName
        self.monitorSpaces = monitorSpaces
    }

    /// Pick a random icon.
    static func randomAppearance() -> (icon: String, color: String) {
        let icon = availableIcons.randomElement() ?? "Labtop"
        return (icon, "blue")
    }

    // MARK: - Available Icons

    static let availableIcons = [
        "3d",
        "Add-Device",
        "Airport-Railroad",
        "Android-Setting",
        "App-Window",
        "Astrology-Study",
        "Baby",
        "Baby-Cart-Quality",
        "Backpack",
        "Balloon-Tour",
        "Bigben",
        "Bluetooth",
        "Boarding-Pass",
        "Book-Library",
        "Bug",
        "Bus-Route-Info",
        "Cancel-2",
        "Candy-Cane",
        "Checking-Order",
        "Cloud-Data-Transfer",
        "Coding",
        "Compass-1",
        "Construction-Area",
        "Control",
        "Cursor",
        "Dangerous-Chemical-Lab",
        "Date-Time-Setting",
        "Drawer-Inbox",
        "Drone",
        "Earpod-Connected",
        "Easter-Egg",
        "Education-Degree",
        "Eiffel-Tower",
        "Elevator-Lift",
        "Face-Id-1",
        "Filming-Movie",
        "Ghost",
        "Gift-Reciept",
        "Globe-1",
        "Graph-Bar",
        "Graph-Pie",
        "Guitar-Amplifier",
        "Help",
        "Information-Toilet-Location",
        "Instruments-Piano",
        "Key",
        "Keyboard-Direction",
        "Lab-Tools",
        "Labtop",
        "Library-Research",
        "Love",
        "Mail",
        "Mailbox-2",
        "Medal",
        "Mobile-Phone",
        "Money-Briefcase",
        "Money-Coin-2",
        "Muslim",
        "Nuclear-2",
        "On-Off-1",
        "Online-Information",
        "Passport",
        "Pen",
        "Photography",
        "Picture",
        "Pile-Of-Money",
        "Plant-1",
        "Product-Cloth",
        "Programming",
        "Qr-Code",
        "Reciept-1",
        "Recycle",
        "Refund-Product-Reciept",
        "Reward",
        "Rocket-Launch-Chart",
        "Sad-Song",
        "Safety",
        "School",
        "Science-Lab",
        "Search",
        "Sent-From-Computer",
        "Server-Network",
        "Shop-Store",
        "Slate",
        "Smart-Tv",
        "Snowman",
        "Solar-Power-Battery",
        "Star",
        "Sun",
        "Sun-Clound-Weather",
        "Taxi",
        "Telescope",
        "Time",
        "Validation-1",
        "View-Mail",
        "Vr-Goggle",
        "Wand",
        "Winter-Day-Activities",
        "World-Nature",
        "Wrench",
    ]
}
