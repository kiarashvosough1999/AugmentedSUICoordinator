# TabCoordinator Presentation Guide

## Overview

This guide explains how to use the new centralized presentation system in SUICoordinator to prevent "Attempt to present while a presentation is in progress" errors when presenting views from child coordinators within a TabCoordinator.

## The Problem

When child coordinators within a TabCoordinator try to present sheets or other views, they can conflict with the TabCoordinator's own presentation process, causing SwiftUI to throw "presentation in progress" errors.

## The Solution

The new `TabChildPresentable` protocol allows child coordinators to route their presentations through the parent TabCoordinator's router, ensuring all presentations are properly serialized.

## How to Use

### 1. Make Your Child Coordinator Conform to TabChildPresentable

```swift
import SUICoordinator

public final class HomeTabCoordinatorImpl: Coordinator<HomeTabRoutes>, TabChildPresentable {
    
    // This property will be automatically set by the TabCoordinator
    public var parentTabCoordinator: (any TabCoordinatable)?
    
    // Your existing coordinator implementation...
    
    public func openAboutUs() async {
        // Instead of using router.safePresent directly, use the parent's router
        await presentThroughParent(
            .aboutUs(coordinator: self),
            presentationStyle: .sheet
        )
    }
    
    public func openContactUs() async {
        await presentThroughParent(
            .contactUs(coordinator: self),
            presentationStyle: .sheet
        )
    }
}
```

### 2. The TabCoordinator Automatically Sets Up the Relationship

The TabCoordinator automatically sets up the parent-child relationship when child coordinators are added:

```swift
// This happens automatically in setupPages()
if var presentable = item as? TabChildPresentable {
    presentable.parentTabCoordinator = self as? (any TabCoordinatable)
}
```

### 3. Available Methods

The `TabChildPresentable` protocol provides these methods:

- `presentThroughParent(_:presentationStyle:animated:)` - Present a route through the parent's router
- `presentSheetThroughParent(_:)` - Present a sheet through the parent's router

## Benefits

1. **No More Presentation Conflicts**: All presentations are routed through the TabCoordinator's router
2. **Automatic Serialization**: The TabCoordinator's router handles presentation queuing
3. **Easy Migration**: Just change `router.safePresent` to `presentThroughParent`
4. **Backward Compatibility**: Existing code continues to work

## Example Migration

### Before (Problematic)
```swift
public func openAboutUs() async {
    await router.safePresent(
        .aboutUs(coordinator: self),
        presentationStyle: .sheet
    )
}
```

### After (Fixed)
```swift
public func openAboutUs() async {
    await presentThroughParent(
        .aboutUs(coordinator: self),
        presentationStyle: .sheet
    )
}
```

## Technical Details

- The TabCoordinator waits 200ms after presenting its view before starting child coordinators
- All presentations are queued through the TabCoordinator's `safePresent` method
- The system automatically detects when a sheet is fully presented before allowing the next presentation
- This prevents the "presentation in progress" error that occurs when multiple presentations happen simultaneously

## Troubleshooting

If you still get presentation errors:

1. Make sure your child coordinator conforms to `TabChildPresentable`
2. Use `presentThroughParent` instead of `router.safePresent`
3. Check that the TabCoordinator is properly set up as the parent
4. Ensure you're not calling presentation methods before the TabCoordinator is fully started
