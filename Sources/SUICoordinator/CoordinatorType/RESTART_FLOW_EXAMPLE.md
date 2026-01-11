# Restart Flow Example

This example demonstrates how to use the new restart flow functionality to update a coordinator's presentation style and mainView without creating duplicate presentations.

## Problem Solved

Previously, when calling `restartFlow`, it would show the last presentation and present it again, creating duplicate sheets. The new implementation properly updates the existing sheet item in the parent coordinator's sheet coordinator, providing a smooth transition.

## Usage Example

### Parent Coordinator (MainTabBarCoordinator)

```swift
// Parent coordinator presents a child coordinator with navigationSheet
await navigate(
    to: registerCoordinator,
    presentationStyle: .navigationSheet([.fraction(0.5)]),
    animated: true
)
```

### Child Coordinator (RegisterCoordinator)

```swift
// Child coordinator can now restart its flow with new presentation style
public func restartWithNewPresentationStyle() async {
    // Restart with new route and presentation style
    await restartFlow(
        newRoute: .newContent(coordinator: self),
        newPresentationStyle: .navigationSheet([.fraction(0.8)]), // Changed from 0.5 to 0.8
        animated: true
    )
}

// Or restart with new coordinator
public func restartWithNewCoordinator() async {
    @Injected var newCoordinator: any NewCoordinatorProtocol
    
    await restartFlow(
        newCoordinator: newCoordinator,
        newPresentationStyle: .fullScreenCover, // Changed from sheet to fullScreenCover
        animated: true
    )
}

// Or restart with new route, keeping current presentation style
public func restartWithNewContent() async {
    await restartFlow(
        newRoute: .updatedContent(coordinator: self),
        animated: true
    )
}
```

## Key Benefits

1. **No Duplicate Presentations**: The existing sheet item is updated instead of creating new ones
2. **Smooth Transitions**: Content and presentation style changes are animated smoothly
3. **Proper State Management**: The parent coordinator's sheet coordinator is properly updated
4. **Flexible Presentation Styles**: Can change from sheet to fullScreenCover, adjust detents, etc.

## Supported Presentation Styles

- `.push` - Navigation stack
- `.sheet` - Standard sheet
- `.fullScreenCover` - Full screen cover
- `.navigationSheet([.fraction(0.5)])` - Sheet with custom detents
- `.navigationFullScreenCover` - Full screen with navigation stack

## Technical Implementation

The restart flow functionality:

1. **Finds the Parent Coordinator**: Locates the parent coordinator that presented the current coordinator
2. **Locates the Sheet Item**: Finds the specific sheet item in the parent's sheet coordinator
3. **Updates the Sheet Item**: Replaces the existing sheet item with new content and presentation style
4. **Maintains State**: Preserves the coordinator hierarchy and relationships

## Example Use Cases

### 1. Dynamic Sheet Height Changes
```swift
// Start with half screen
await navigate(to: coordinator, presentationStyle: .navigationSheet([.fraction(0.5)]))

// Later, expand to full screen
await coordinator.restartFlow(
    newRoute: .expandedContent,
    newPresentationStyle: .navigationSheet([.fraction(1.0)]),
    animated: true
)
```

### 2. Content Updates with Style Changes
```swift
// Start as sheet
await navigate(to: coordinator, presentationStyle: .sheet)

// Later, change to full screen cover
await coordinator.restartFlow(
    newRoute: .fullScreenContent,
    newPresentationStyle: .fullScreenCover,
    animated: true
)
```

### 3. Coordinator Replacement
```swift
// Start with one coordinator
await navigate(to: coordinatorA, presentationStyle: .sheet)

// Replace with different coordinator
await coordinatorA.restartFlow(
    newCoordinator: coordinatorB,
    newPresentationStyle: .fullScreenCover,
    animated: true
)
```

## Best Practices

1. **Use Appropriate Animation**: Set `animated: true` for smooth transitions
2. **Consider User Experience**: Don't change presentation styles too frequently
3. **Test Different Styles**: Ensure your content works well with different presentation styles
4. **Handle Edge Cases**: Consider what happens if the parent coordinator is not available

## Troubleshooting

### Issue: "No parent coordinator found"
- **Cause**: The coordinator is not presented as a sheet by a parent coordinator
- **Solution**: Ensure the coordinator is presented using `navigate(to:presentationStyle:)` from a parent coordinator

### Issue: "Sheet item not found"
- **Cause**: The coordinator's sheet item is not found in the parent's sheet coordinator
- **Solution**: Ensure the coordinator was properly presented and is still active

### Issue: "Presentation style not changing"
- **Cause**: The new presentation style is the same as the current one
- **Solution**: Use a different presentation style or check that the style is being applied correctly
