import SwiftUI

struct MonitorMappingView: View {
    let monitor: MonitorInfo
    @Binding var spaceNumber: Int

    var body: some View {
        HStack {
            Text(monitor.label)
                .frame(width: 80, alignment: .leading)

            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)

            Picker("", selection: $spaceNumber) {
                ForEach(monitor.desktopNumbers, id: \.self) { n in
                    Text("Desktop \(n)").tag(n)
                }
            }
            .labelsHidden()
            .frame(width: 140)
        }
    }
}
