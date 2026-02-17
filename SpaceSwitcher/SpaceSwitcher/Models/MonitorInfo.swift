import Foundation
import CoreGraphics

struct SpaceInfo: Hashable {
    let desktopNumber: Int   // Global desktop number (e.g. 5)
    let spaceID: UInt64      // Internal macOS space ID for CGSManagedDisplaySetCurrentSpace
}

struct MonitorInfo: Identifiable, Hashable {
    let id: String
    let displayID: CGDirectDisplayID
    let displayUUID: String  // Display UUID string for CGS APIs
    let frame: CGRect
    let label: String
    var spaces: [SpaceInfo] = []

    var desktopNumbers: [Int] { spaces.map(\.desktopNumber) }
}
