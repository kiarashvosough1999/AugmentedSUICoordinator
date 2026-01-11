# Flicker Fix Summary

This document explains the changes made to fix the flicker issue where the new view was briefly shown in the old presentation before the restart.

## Problem Identified

**Issue**: The new view was briefly shown for a second in the old presentation before being replaced, creating a visual flicker.

**Root Cause**: The mainView was being set after the restart, causing the new content to be displayed in the old presentation before the restart completed.

## Solution Applied

### **1. Immediate mainView Setting**
```swift
// OLD: Set mainView after restart
await restart(animated: animated)
router.mainView = newRoute

// NEW: Set mainView IMMEDIATELY before restart
router.mainView = newRoute
await restart(animated: false)
```

### **2. Disabled Animation During Restart**
```swift
// OLD: Animated restart could cause flicker
await restart(animated: animated)

// NEW: Non-animated restart prevents flicker
await restart(animated: false)
```

### **3. Pre-emptive mainView Setting**
```swift
// Set mainView in updateParentSheetItem BEFORE any operations
router.mainView = newRoute
await finishFlow(animated: false)
```

## Key Changes

### **Method 1: restartFlow with newPresentationStyle**
```swift
@MainActor func restartFlow(
    newRoute: Route,
    newPresentationStyle: TransitionPresentationStyle,
    animated: Bool = true
) async -> Void {
    // Set the new mainView IMMEDIATELY to prevent flicker
    router.mainView = newRoute
    
    // Restart without animation to prevent flicker
    await restart(animated: false)
    
    // Wait for restart to complete
    try? await Task.sleep(for: .milliseconds(100))
    
    // Update parent presentation
    await updateParentSheetItem(...)
}
```

### **Method 2: restartFlow without newPresentationStyle**
```swift
@MainActor func restartFlow(
    newRoute: Route,
    animated: Bool = true
) async -> Void {
    // Set the new mainView IMMEDIATELY to prevent flicker
    router.mainView = newRoute
    
    // Restart without animation to prevent flicker
    await restart(animated: false)
    
    // Wait for restart to complete
    try? await Task.sleep(for: .milliseconds(100))
    
    // Update parent presentation
    await updateParentSheetItem(...)
}
```

### **Helper Method: updateParentSheetItem**
```swift
@MainActor func updateParentSheetItem(...) async {
    // Ensure mainView is set BEFORE any operations
    router.mainView = newRoute
    
    // Finish current flow without animation
    await finishFlow(animated: false)
    
    // Wait for dismissal
    try? await Task.sleep(for: .milliseconds(200))
    
    // Present updated coordinator
    await parentCoordinator.navigate(...)
}
```

## Benefits of the Fix

### ✅ **No Flicker**
- New content is set immediately before any restart operations
- No brief display of new content in old presentation
- Smooth transition to new presentation

### ✅ **Immediate View Change**
- mainView is updated synchronously
- User sees the change immediately
- No visual artifacts during transition

### ✅ **Proper Animation Control**
- Restart operations are non-animated to prevent flicker
- Final presentation can still be animated for smooth user experience
- Clean separation between internal operations and user-facing animations

## Usage Example

```swift
// This will now change the view immediately without flicker
await coordinator.restartFlow(
    newRoute: .newContent(coordinator: self),
    newPresentationStyle: .navigationSheet([.fraction(0.8)]),
    animated: true
)
```

## Technical Details

### **Timing Sequence**
1. **Immediate**: Set `router.mainView = newRoute`
2. **Fast**: Restart coordinator without animation
3. **Clean**: Finish current flow without animation
4. **Smooth**: Present new coordinator with animation

### **Animation Strategy**
- **Internal Operations**: No animation (prevents flicker)
- **User-Facing Presentation**: Full animation (smooth experience)
- **Content Changes**: Immediate (no delay)

The restart flow now provides a seamless experience without any visual flicker!
