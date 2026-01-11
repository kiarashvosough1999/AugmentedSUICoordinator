# SUICoordinator Presentation Race Condition Fixes

This document describes the fixes applied to resolve presentation race conditions and crashes in the SUICoordinator package.

## Issues Fixed

### 1. Presentation Race Condition
**Problem**: "Attempt to present while a presentation is in progress" error when multiple presentations are triggered simultaneously.

**Solution**: Added presentation queuing mechanism with `NSLock` and `DispatchQueue` to ensure presentations are processed sequentially.

### 2. Array Index Out of Bounds Crash
**Problem**: `Swift/ContiguousArrayBuffer.swift:703: Fatal error: Index out of range` when accessing array indices during concurrent operations.

**Solution**: Added safe array access methods with bounds checking in `ItemManager` and `SheetCoordinator`.

### 3. Concurrent Sheet Presentations
**Problem**: Multiple sheet presentations could interfere with each other, causing UI inconsistencies.

**Solution**: Implemented presentation state tracking and queuing to prevent concurrent presentations.

## Files Modified

### 1. `Sources/SUICoordinator/Shared/Actors/ItemManager.swift`
- Added `safeTotalItems` property with bounds checking
- Added `safeGetItem(at:)` and `safeRemoveItem(at:)` methods
- Added `safeMakeItemsNil(at:)` method for optional types
- Added processing state tracking

### 2. `Sources/SUICoordinator/Router/Router.swift`
- Added presentation queuing with `DispatchQueue`
- Added `isPresenting` flag and `presentationLock` for thread safety
- Added `safePresent()` method with queuing
- Added `safePresentSheet()` method with queuing
- Added proper timing delays to ensure presentation completion

### 3. `Sources/SUICoordinator/SheetCoordinator/SheetCoordinator.swift`
- Updated `presentSheet()` to use `safeTotalItems`
- Updated `removeLastSheet()` to use safe array access methods
- Updated `removeSheet(at:animated:)` to use safe methods

### 4. `Sources/SUICoordinator/CoordinatorType/CoordinatorType+Navigation.swift`
- Added `safeNavigate()` method with presentation queuing

### 5. `Sources/SUICoordinator/Coordinator/SafeCoordinator.swift` (New File)
- Created base coordinator class with safe presentation methods
- Provides `safePresent()`, `safeNavigate()`, `safePresentSheet()`, and `safePresentFullScreenCover()`
- Maintains backward compatibility with existing code

## How to Use the Fixes

### Option 1: Use SafeCoordinator (Recommended)
Replace your existing coordinator base class:

```swift
// Before (problematic):
class MyCoordinator: Coordinator<MyRoute> {
    func presentSheet() async {
        await router.present(.sheet(title: "Hello"), animated: true)
    }
}

// After (safe):
class MyCoordinator: SafeCoordinator<MyRoute> {
    func presentSheet() async {
        await safePresent(.sheet(title: "Hello"), animated: true)
    }
}
```

### Option 2: Use Safe Methods Directly
Use the new safe methods on existing coordinators:

```swift
class MyCoordinator: Coordinator<MyRoute> {
    func presentSheet() async {
        await router.safePresent(.sheet(title: "Hello"), animated: true)
    }
    
    func navigateToCoordinator() async {
        let coordinator = AnotherCoordinator()
        await safeNavigate(to: coordinator, presentationStyle: .sheet, animated: true)
    }
}
```

### Option 3: For TabCoordinator Child Coordinators
Use SafeCoordinator as the base class for child coordinators:

```swift
class TabChildCoordinator: SafeCoordinator<ChildRoute> {
    func presentFromTab() async {
        // This will now work safely without crashes
        await safePresent(.sheet(title: "From Tab"), animated: true)
    }
}
```

## Key Benefits

1. **Race Condition Prevention**: Eliminates "presentation in progress" errors
2. **Crash Prevention**: Prevents array index out of bounds crashes
3. **Thread Safety**: Proper concurrency protection for all presentation operations
4. **Backward Compatibility**: Existing code continues to work unchanged
5. **Easy Migration**: Simple base class change for immediate benefits

## Testing

The fixes have been designed to:
- Maintain all existing functionality
- Add safety without breaking changes
- Provide clear migration path
- Handle edge cases gracefully

## Performance Impact

The fixes add minimal overhead:
- Small delays (50-100ms) to ensure presentation completion
- Thread-safe operations with minimal locking
- Queuing only when necessary (when presentations are already in progress)

## Migration Guide

1. **Immediate Fix**: Change base class from `Coordinator` to `SafeCoordinator`
2. **Method Updates**: Replace `router.present()` with `safePresent()`
3. **Navigation Updates**: Replace `navigate()` with `safeNavigate()`
4. **Testing**: Verify that rapid presentation calls no longer cause crashes

## Example Usage

See `Examples/SafePresentationExample.swift` for a complete working example demonstrating the safe presentation methods.
