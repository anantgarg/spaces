import Foundation

final class PersistenceManager {
    private let groupsKey = "desktopGroups"
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
}
