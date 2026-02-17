import CoreGraphics

// MARK: - Private CoreGraphics SPI for Space Management
// These functions are not in public headers but are stable across macOS versions.
// Required for programmatic window-to-space movement.

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ connection: Int32) -> CFArray

@_silgen_name("CGSAddWindowsToSpaces")
func CGSAddWindowsToSpaces(_ connection: Int32, _ windowIDs: CFArray, _ spaceIDs: CFArray)

@_silgen_name("CGSRemoveWindowsFromSpaces")
func CGSRemoveWindowsFromSpaces(_ connection: Int32, _ windowIDs: CFArray, _ spaceIDs: CFArray)

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ connection: Int32) -> Int

@_silgen_name("CGSManagedDisplaySetCurrentSpace")
func CGSManagedDisplaySetCurrentSpace(_ connection: Int32, _ displayUUID: CFString, _ spaceID: UInt64)

@_silgen_name("CGSHideSpaces")
func CGSHideSpaces(_ connection: Int32, _ spaces: CFArray)

@_silgen_name("CGSShowSpaces")
func CGSShowSpaces(_ connection: Int32, _ spaces: CFArray)
