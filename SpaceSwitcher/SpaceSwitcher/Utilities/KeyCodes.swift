import Carbon

enum KeyCodes {
    struct SpaceKeyMapping {
        let keyCode: UInt16
        let flags: CGEventFlags
    }

    /// Map user-facing space numbers (1-16) to Carbon virtual keycodes and modifier flags.
    /// 1-9: Ctrl+1-9, 10: Ctrl+0, 11-16: Ctrl+Option+1-6
    static func keyMapping(for number: Int) -> SpaceKeyMapping? {
        switch number {
        case 1:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_1), flags: .maskControl)
        case 2:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_2), flags: .maskControl)
        case 3:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_3), flags: .maskControl)
        case 4:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_4), flags: .maskControl)
        case 5:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_5), flags: .maskControl)
        case 6:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_6), flags: .maskControl)
        case 7:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_7), flags: .maskControl)
        case 8:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_8), flags: .maskControl)
        case 9:  return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_9), flags: .maskControl)
        case 10: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_0), flags: .maskControl)
        case 11: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_1), flags: [.maskControl, .maskAlternate])
        case 12: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_2), flags: [.maskControl, .maskAlternate])
        case 13: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_3), flags: [.maskControl, .maskAlternate])
        case 14: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_4), flags: [.maskControl, .maskAlternate])
        case 15: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_5), flags: [.maskControl, .maskAlternate])
        case 16: return SpaceKeyMapping(keyCode: UInt16(kVK_ANSI_6), flags: [.maskControl, .maskAlternate])
        default: return nil
        }
    }
}
