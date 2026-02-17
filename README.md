# Spaces

A macOS menu bar app that links Spaces across multiple monitors into named project groups, so you can switch your entire workspace with a single click or hotkey.

![Spaces overlay switcher](screenshot.png)

## The problem

Mission Control and macOS Spaces are powerful, but they fall apart on a multi-monitor setup:

1. **Spaces have no names.** In Mission Control they all look the same, so it's hard to remember which Space is for which project.
2. **Spaces switch independently per monitor.** Even if you set up a nice workspace across both screens, switching on one display doesn't switch the other. You end up manually moving both monitors just to stay in the same context.

## The solution

Spaces lets you link one Space on Monitor A with one Space on Monitor B and treat them as a single named group. Once linked, you can switch both together — your workspace stays aligned and you can jump between projects without losing your setup.

- **Define groups** like "Work", "Music", "Chat" — each group maps every monitor to a specific desktop
- **Switch instantly** — click a group in the menu bar or press the hotkey, and all monitors jump to the right desktops simultaneously
- **Overlay switcher** — press Option+Space to get a visual overlay showing all your groups, navigate with arrow keys or number keys
- **Move windows** — right-click in the overlay to move the frontmost window to another group's space
- **Auto-detect** — the active group updates automatically when you switch spaces via Mission Control

## Requirements

- macOS 15.0 (Sequoia) or later
- [Xcode](https://developer.apple.com/xcode/) 16.0 or later (to build from source)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (to regenerate the Xcode project if needed)
- Keyboard shortcuts for switching desktops must be enabled in **System Settings > Keyboard > Keyboard Shortcuts > Mission Control** (Ctrl+1 through Ctrl+10, and optionally Ctrl+Option+1 through Ctrl+Option+6 for desktops 11-16)

## Installation

### Build and install

```bash
git clone https://github.com/anantgarg/spaces.git
cd spaces/SpaceSwitcher
./install.sh
```

This builds the app, installs it to `/Applications/Spaces.app`, and launches it.

### Grant Accessibility access

On first launch, macOS will prompt you to grant Accessibility access in **System Settings > Privacy & Security > Accessibility**. This is required for simulating the keyboard shortcuts that switch desktops.

## Usage

### Menu bar

Click the menu bar icon to:
- Switch to any group
- Create a new group (captures your current desktops)
- Open Settings

### Overlay (Option+Space)

Press **Option+Space** to show the overlay switcher:
- **Left/Right arrows** — navigate between groups
- **Enter** — switch to the focused group
- **1-9** — switch to a group by number
- **Right-click** — move the frontmost window to the focused group's space
- **Escape** — dismiss

### Settings

- **Groups tab** — add, remove, reorder, rename groups; pick an icon; map each monitor to a desktop
- **General tab** — configure the hotkey, enable launch at login

## How it works

- Uses macOS private CGS APIs to detect spaces and their IDs per display
- Switches desktops by simulating Ctrl+Number keyboard shortcuts (the same ones you'd press manually)
- Groups store per-monitor 1-based indices that automatically reconcile when spaces are added or removed
- Runs as a menu bar app (`LSUIElement`) with no dock icon

## Project structure

```
SpaceSwitcher/
├── App/                  # App entry point, AppDelegate, AppState, MenuBarView
├── Models/               # DesktopGroup, MonitorInfo, SpaceInfo
├── Services/             # SpaceSwitcherService, MonitorManager, PersistenceManager
├── Settings/             # Settings window views
├── Overlay/              # Overlay switcher panel and views
├── Utilities/            # KeyCodes, CGS private API declarations
└── Resources/            # Assets, Info.plist, entitlements
```

## Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — global hotkey recording and handling
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin-Modern) — launch at login toggle

## License

MIT
