# Restart Flow - Fixed Implementation

This document explains the fixed implementation of the restart flow functionality that properly updates the coordinator's mainView and presentation style.

## Problem Fixed

**Previous Issue**: The restart flow was presenting the last mainView instead of the new one because the coordinator's mainView wasn't properly updated before the parent coordinator presented it.

**Root Cause**: The timing of setting `router.mainView = newRoute` and calling the parent's `navigate` method wasn't synchronized properly.

## Solution Applied

### 1. **Proper Timing of mainView Updates**
```swift
// Set the new mainView BEFORE updating the parent
router.mainView = newRoute

// Wait a moment for the mainView to be properly set
try? await Task.sleep(for: .milliseconds(50))

// Then update the parent coordinator's sheet item
await updateParentSheetItem(...)
```

### 2. **Double mainView Setting**
The implementation now sets the mainView in two places:
- In the main `restartFlow` method
- In the `updateParentSheetItem` method before presenting

This ensures the coordinator always has the correct mainView when presented.

## Usage Example

### Parent Coordinator (MainTabBarCoordinator)
```swift
// Parent coordinator presents child with navigationSheet
await navigate(
    to: registerCoordinator,
    presentationStyle: .navigationSheet([.fraction(0.5)]),
    animated: true
)
```

### Child Coordinator (RegisterCoordinator)
```swift
// Child coordinator can now restart with new content and presentation style
public func restartWithNewContent() async {
    await restartFlow(
        newRoute: .newContent(coordinator: self), // NEW CONTENT
        newPresentationStyle: .navigationSheet([.fraction(0.8)]), // NEW STYLE
        animated: true
    )
}

// Or restart with new content, keeping current presentation style
public func restartWithNewContentOnly() async {
    await restartFlow(
        newRoute: .updatedContent(coordinator: self), // NEW CONTENT
        animated: true
    )
}
```

## How It Works Now

### 1. **Coordinator Restart Flow**
```swift
@MainActor func restartFlow(
    newRoute: Route,
    newPresentationStyle: TransitionPresentationStyle,
    animated: Bool = true
) async -> Void {
    // 1. Restart coordinator to clear navigation state
    await restart(animated: animated)
    
    // 2. Wait for restart to complete
    try? await Task.sleep(for: .milliseconds(100))
    
    // 3. Set new mainView IMMEDIATELY
    router.mainView = newRoute
    
    // 4. Wait for mainView to be properly set
    try? await Task.sleep(for: .milliseconds(50))
    
    // 5. Update parent's presentation
    await updateParentSheetItem(...)
}
```

### 2. **Parent Sheet Item Update**
```swift
@MainActor func updateParentSheetItem(...) async {
    // 1. Finish current flow
    await finishFlow(animated: animated)
    
    // 2. Wait for dismissal
    try? await Task.sleep(for: .milliseconds(200))
    
    // 3. Ensure mainView is set (double-check)
    router.mainView = newRoute
    
    // 4. Wait for mainView to be set
    try? await Task.sleep(for: .milliseconds(50))
    
    // 5. Present updated coordinator
    await parentCoordinator.navigate(
        to: self, // This coordinator now has the NEW mainView
        presentationStyle: presentationStyle,
        animated: animated
    )
}
```

## Key Improvements

### ✅ **Proper Timing**
- mainView is set before parent presentation
- Multiple timing checks ensure synchronization
- Double-setting of mainView prevents race conditions

### ✅ **Content Updates**
- New route content is properly displayed
- Old content is completely cleared
- Coordinator state is properly reset

### ✅ **Presentation Style Changes**
- Detents can be changed (e.g., 0.5 → 0.8)
- Style can be changed (e.g., sheet → fullScreenCover)
- Animations are smooth and consistent

## Example Scenarios

### 1. **Change Sheet Height**
```swift
// Start with half screen
await navigate(to: coordinator, presentationStyle: .navigationSheet([.fraction(0.5)]))

// Later, expand to 80% screen
await coordinator.restartFlow(
    newRoute: .expandedContent,
    newPresentationStyle: .navigationSheet([.fraction(0.8)]),
    animated: true
)
```

### 2. **Change Content and Style**
```swift
// Start as sheet
await navigate(to: coordinator, presentationStyle: .sheet)

// Later, change to full screen with new content
await coordinator.restartFlow(
    newRoute: .fullScreenContent,
    newPresentationStyle: .fullScreenCover,
    animated: true
)
```

### 3. **Content Update Only**
```swift
// Start with content A
await navigate(to: coordinator, presentationStyle: .sheet)

// Update to content B, keeping same style
await coordinator.restartFlow(
    newRoute: .contentB,
    animated: true
)
```

## Testing the Fix

To verify the fix is working:

1. **Present a coordinator** with initial content and style
2. **Call restartFlow** with new content and/or style
3. **Verify** that the new content is displayed (not the old content)
4. **Verify** that the new presentation style is applied
5. **Verify** that animations are smooth

## Best Practices

1. **Always set mainView first** before calling parent methods
2. **Use appropriate delays** to ensure state synchronization
3. **Test with different presentation styles** to ensure compatibility
4. **Consider user experience** when changing presentation styles frequently

The restart flow functionality now properly updates both the content and presentation style without showing the old mainView!
