import AppKit
import SwiftUI

@Observable
final class AppState {
    var groups: [DesktopGroup] = []
    var monitors: [MonitorInfo] = []
    var activeGroupID: UUID?
    var pendingSelectGroupID: UUID?

    private let persistence = PersistenceManager()
    private var previousSpaceIDs: [String: [UInt64]] = [:]  // monitorID → ordered space IDs

    init() {
        groups = persistence.loadGroups()
        refreshMonitors()
        persistence.migrateToPerMonitorIndicesIfNeeded(monitors: monitors)
        groups = persistence.loadGroups()  // reload after potential migration
        previousSpaceIDs = buildSpaceIDSnapshot(monitors)
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
        reconcileSpaceIndices()
    }

    /// Compare current space IDs with previous snapshot; if spaces were added/removed/reordered
    /// on a monitor, update all group mappings for that monitor so they still point to the same space.
    private func reconcileSpaceIndices() {
        var anyChanged = false

        for monitor in monitors {
            let oldIDs = previousSpaceIDs[monitor.id] ?? []
            let newIDs = monitor.spaces.map(\.spaceID)

            guard oldIDs != newIDs, !oldIDs.isEmpty else { continue }

            // Build oldIndex (1-based) → newIndex (1-based) mapping
            var oldToNew: [Int: Int] = [:]
            for (oldArrayIdx, spaceID) in oldIDs.enumerated() {
                if let newArrayIdx = newIDs.firstIndex(of: spaceID) {
                    oldToNew[oldArrayIdx + 1] = newArrayIdx + 1
                }
            }

            for i in groups.indices {
                guard let oldIndex = groups[i].monitorSpaces[monitor.id] else { continue }
                if let newIndex = oldToNew[oldIndex] {
                    if newIndex != oldIndex {
                        groups[i].monitorSpaces[monitor.id] = newIndex
                        anyChanged = true
                    }
                } else {
                    // Space was removed — reset to 1
                    groups[i].monitorSpaces[monitor.id] = 1
                    anyChanged = true
                }
            }
        }

        if anyChanged {
            saveGroups()
        }
        previousSpaceIDs = buildSpaceIDSnapshot(monitors)
    }

    private func buildSpaceIDSnapshot(_ monitors: [MonitorInfo]) -> [String: [UInt64]] {
        var snapshot: [String: [UInt64]] = [:]
        for monitor in monitors {
            snapshot[monitor.id] = monitor.spaces.map(\.spaceID)
        }
        return snapshot
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
                guard let spaceIndex = group.monitorSpaces[monitor.id],
                      !monitor.displayUUID.isEmpty,
                      let currentSpaceID = currentSpaces[monitor.displayUUID],
                      let spaceInfo = monitor.spaceInfo(forIndex: spaceIndex)
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
