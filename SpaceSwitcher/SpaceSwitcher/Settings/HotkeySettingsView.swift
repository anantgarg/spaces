import SwiftUI
import KeyboardShortcuts

struct HotkeySettingsView: View {
    var body: some View {
        LabeledContent("Overlay Hotkey:") {
            KeyboardShortcuts.Recorder(for: .toggleOverlay)
        }
    }
}
