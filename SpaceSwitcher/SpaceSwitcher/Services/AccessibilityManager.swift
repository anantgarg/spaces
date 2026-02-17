import AppKit

enum AccessibilityManager {
    static var isTrusted: Bool {
        AXIsProcessTrusted()
    }

    /// Prompt for accessibility access only if not already trusted.
    static func checkAndPrompt() {
        if AXIsProcessTrusted() { return }

        let key = "AXTrustedCheckOptionPrompt" as CFString
        let options = [key: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }
}
