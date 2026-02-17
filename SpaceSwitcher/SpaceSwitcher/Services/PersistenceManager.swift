import Foundation

final class PersistenceManager {
    private let groupsKey = "desktopGroups"
    private let migrationKey = "didMigrateToPerMonitorIndices"
    private let defaults = UserDefaults.standard

    func loadGroups() -> [DesktopGroup] {
        guard let data = defaults.data(forKey: groupsKey) else { return [] }
        return (try? JSONDecoder().decode([DesktopGroup].self, from: data)) ?? []
    }

    func saveGroups(_ groups: [DesktopGroup]) {
        if let data = try? JSONEncoder().encode(groups) {
            defaults.set(data, forKey: groupsKey)
        }
    }

    /// One-time migration: convert monitorSpaces values from global desktop numbers
    /// to per-monitor 1-based indices.
    func migrateToPerMonitorIndicesIfNeeded(monitors: [MonitorInfo]) {
        guard !defaults.bool(forKey: migrationKey) else { return }
        defer { defaults.set(true, forKey: migrationKey) }

        var groups = loadGroups()
        guard !groups.isEmpty else { return }

        // Build globalDesktopNumber → perMonitorIndex map for each monitor label
        var globalToIndex: [String: [Int: Int]] = [:]  // monitorID → (globalDesktop → 1-based index)
        for monitor in monitors {
            var mapping: [Int: Int] = [:]
            for (arrayIndex, space) in monitor.spaces.enumerated() {
                mapping[space.desktopNumber] = arrayIndex + 1
            }
            globalToIndex[monitor.id] = mapping
        }

        var changed = false
        for i in groups.indices {
            for (monitorID, globalDesktop) in groups[i].monitorSpaces {
                if let mapping = globalToIndex[monitorID],
                   let perMonitorIdx = mapping[globalDesktop] {
                    groups[i].monitorSpaces[monitorID] = perMonitorIdx
                    changed = true
                }
                // If monitor not connected, keep old value as-is
            }
        }

        if changed {
            saveGroups(groups)
        }
    }
}
