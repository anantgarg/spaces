import SwiftUI

struct MonitorMappingView: View {
    let monitor: MonitorInfo
    @Binding var spaceNumber: Int
    let currentGroupID: UUID
    let allGroups: [DesktopGroup]

    var body: some View {
        HStack {
            Text(monitor.label)
                .frame(width: 80, alignment: .leading)

            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)

            Picker("", selection: $spaceNumber) {
                ForEach(monitor.desktopNumbers, id: \.self) { n in
                    Text(labelForDesktop(n)).tag(n)
                }
            }
            .labelsHidden()
            .frame(width: 220)
        }
    }

    private func labelForDesktop(_ desktopNumber: Int) -> String {
        let usedBy = allGroups.filter { $0.id != currentGroupID && $0.monitorSpaces[monitor.id] == desktopNumber }
        if let group = usedBy.first {
            return "Desktop \(desktopNumber) (used by \(group.name))"
        }
        return "Desktop \(desktopNumber)"
    }
}
