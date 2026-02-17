import AppKit
import SwiftUI

@Observable
final class AppState {
    var groups: [DesktopGroup] = []
    var monitors: [MonitorInfo] = []
    var activeGroupID: UUID?
    var pendingSelectGroupID: UUID?

    private let persistence = PersistenceManager()

    init() {
        groups = persistence.loadGroups()
        refreshMonitors()
        detectActiveGroup()

        // Re-detect active group whenever the user switches spaces (e.g. via Mission Control)
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(spaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    @objc private func spaceDidChange() {
        refreshMonitors()
        detectActiveGroup()
    }

    func refreshMonitors() {
        monitors = MonitorManager.detectMonitors()
    }

    func saveGroups() {
        persistence.saveGroups(groups)
    }

    func addGroup(_ group: DesktopGroup) {
        groups.append(group)
        saveGroups()
    }

    func deleteGroup(_ group: DesktopGroup) {
        groups.removeAll { $0.id == group.id }
        saveGroups()
    }

    func updateGroup(_ group: DesktopGroup) {
        if let idx = groups.firstIndex(where: { $0.id == group.id }) {
            groups[idx] = group
            saveGroups()
        }
    }

    func switchToGroup(_ group: DesktopGroup) {
        activeGroupID = group.id
        let groupCopy = group
        let monitorsCopy = monitors
        Task { @MainActor in
            await SpaceSwitcherService.switchToGroup(groupCopy, monitors: monitorsCopy)
        }
    }

    /// Detect which group (if any) matches the currently active spaces on all monitors.
    func detectActiveGroup() {
        let currentSpaces = SpaceSwitcherService.getCurrentSpacePerDisplay()

        for group in groups {
            let allMatch = monitors.allSatisfy { monitor in
                guard let expectedDesktop = group.monitorSpaces[monitor.id],
                      !monitor.displayUUID.isEmpty,
                      let currentSpaceID = currentSpaces[monitor.displayUUID],
                      let spaceInfo = monitor.spaces.first(where: { $0.desktopNumber == expectedDesktop })
                else {
                    // If the group doesn't define a space for this monitor, skip it
                    return group.monitorSpaces[monitor.id] == nil
                }
                return spaceInfo.spaceID == currentSpaceID
            }

            if allMatch {
                activeGroupID = group.id
                return
            }
        }

        activeGroupID = nil
    }
}
