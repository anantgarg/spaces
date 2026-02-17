import CoreGraphics
import AppKit

struct WindowInfo: Identifiable {
    let id: CGWindowID
    let appName: String
    let title: String
    let bounds: CGRect
    let ownerPID: pid_t
    let appIcon: NSImage?
}

enum WindowManager {
    /// List all visible, normal-layer windows (excluding desktop elements and system UI).
    static func listWindows() -> [WindowInfo] {
        guard let windowList = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return []
        }

        return windowList.compactMap { info -> WindowInfo? in
            guard let windowID = info[kCGWindowNumber as String] as? CGWindowID,
                  let ownerName = info[kCGWindowOwnerName as String] as? String,
                  let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                  let boundsDict = info[kCGWindowBounds as String] as? [String: CGFloat],
                  let layer = info[kCGWindowLayer as String] as? Int,
                  layer == 0  // Normal window layer only
            else { return nil }

            let title = info[kCGWindowName as String] as? String ?? ""

            // Skip windows without titles (usually system UI elements)
            if title.isEmpty && ownerName != "Finder" { return nil }

            let bounds = CGRect(
                x: boundsDict["X"] ?? 0,
                y: boundsDict["Y"] ?? 0,
                width: boundsDict["Width"] ?? 0,
                height: boundsDict["Height"] ?? 0
            )

            let app = NSRunningApplication(processIdentifier: ownerPID)

            return WindowInfo(
                id: windowID,
                appName: ownerName,
                title: title,
                bounds: bounds,
                ownerPID: ownerPID,
                appIcon: app?.icon
            )
        }
    }

    /// Move a window to a specific space on a specific monitor.
    /// Uses private CGS APIs to remove from current space and add to target space.
    static func moveWindow(
        _ windowID: CGWindowID,
        toSpaceNumber spaceNumber: Int,
        onMonitor monitorLabel: String,
        monitors: [MonitorInfo]
    ) {
        let conn = CGSMainConnectionID()

        guard let targetSpaceID = resolveSpaceID(
            spaceNumber: spaceNumber,
            monitorLabel: monitorLabel,
            monitors: monitors,
            connection: conn
        ) else {
            return
        }

        let windowIDs = [windowID] as CFArray
        let targetSpaces = [targetSpaceID] as CFArray

        // Remove from current spaces
        if let currentSpaces = currentSpaceIDsForWindow(windowID, connection: conn) {
            CGSRemoveWindowsFromSpaces(conn, windowIDs, currentSpaces as CFArray)
        }

        // Add to target space
        CGSAddWindowsToSpaces(conn, windowIDs, targetSpaces)
    }

    /// Map a user-visible space number (1, 2, 3...) to the internal CGS space ID
    /// needed by the private APIs. Uses CGSCopyManagedDisplaySpaces to enumerate.
    private static func resolveSpaceID(
        spaceNumber: Int,
        monitorLabel: String,
        monitors: [MonitorInfo],
        connection: Int32
    ) -> Int? {
        guard let spacesInfo = CGSCopyManagedDisplaySpaces(connection) as? [[String: Any]] else {
            return nil
        }

        // Find the monitor's display UUID
        guard let monitor = monitors.first(where: { $0.label == monitorLabel }) else {
            return nil
        }

        let displayUUID = CGDisplayCreateUUIDFromDisplayID(monitor.displayID)?.takeRetainedValue()
        let displayUUIDString = displayUUID.map { CFUUIDCreateString(nil, $0) as String }

        for display in spacesInfo {
            let displayID = display["Display Identifier"] as? String

            // Match by display identifier or fall back to index-based matching
            let isMatch: Bool
            if let displayUUIDString, let displayID {
                isMatch = displayID == displayUUIDString
            } else {
                // Fallback: match by position in the array
                isMatch = true
            }

            if isMatch, let spaces = display["Spaces"] as? [[String: Any]] {
                // Filter to only user spaces (type 0), not fullscreen spaces
                let userSpaces = spaces.filter { space in
                    let type = space["type"] as? Int ?? 0
                    return type == 0
                }

                if spaceNumber >= 1, spaceNumber <= userSpaces.count {
                    let space = userSpaces[spaceNumber - 1]
                    return space["id64"] as? Int ?? space["ManagedSpaceID"] as? Int
                }
            }
        }

        return nil
    }

    private static func currentSpaceIDsForWindow(
        _ windowID: CGWindowID,
        connection: Int32
    ) -> [Int]? {
        let activeSpace = CGSGetActiveSpace(connection)
        return activeSpace > 0 ? [activeSpace] : nil
    }
}
