# NavigationStack Support for Sheets and FullScreenCover

This guide explains how to use the new NavigationStack support in SUICoordinator for presenting sheets and fullScreenCover modals with push navigation capabilities.

## Overview

The SUICoordinator library now supports NavigationStack within modal presentations, allowing you to present sheets or fullScreenCover modals that contain multiple screens with push/pop navigation.

## New Presentation Styles

Two new presentation styles have been added:

- `.navigationSheet` - A sheet presentation with NavigationStack support
- `.navigationFullScreenCover` - A fullScreenCover presentation with NavigationStack support

## Usage

### 1. Using the Router

You can use the new presentation styles with the existing `present` method:

```swift
// Present a NavigationStack-enabled sheet
await router.present(
    yourRoute, 
    presentationStyle: .navigationSheet, 
    animated: true
)

// Present a NavigationStack-enabled fullScreenCover
await router.present(
    yourRoute, 
    presentationStyle: .navigationFullScreenCover, 
    animated: true
)
```

### 2. Using the Convenience Method

A new convenience method `presentWithNavigationStack` is available:

```swift
// Present with NavigationStack support
await router.presentWithNavigationStack(
    yourRoute,
    presentationStyle: .navigationSheet,
    animated: true
)
```

### 3. Defining Routes

In your route enum, you can define routes with NavigationStack presentation styles:

```swift
enum MyRoute: RouteType {
    case navigationSheet(coordinator: MyCoordinator, title: String)
    case navigationFullScreen(coordinator: MyCoordinator, title: String)
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .navigationSheet:
            return .navigationSheet
        case .navigationFullScreen:
            return .navigationFullScreenCover
        }
    }
    
    var body: some View {
        switch self {
        case let .navigationSheet(coordinator, title),
             let .navigationFullScreen(coordinator, title):
            MyDetailView(coordinator: coordinator, title: title)
        }
    }
}
```

### 4. Navigation Within Modals

Once you have a NavigationStack-enabled modal, you can use standard SwiftUI navigation within it:

```swift
struct MyDetailView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Text("This is a modal with NavigationStack!")
                
                NavigationLink("Push to Next Screen", value: "next")
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "next" {
                    NextScreenView()
                }
            }
        }
    }
}
```

## Example Implementation

The example project includes working examples of NavigationStack-enabled sheets and fullScreenCover presentations. You can find them in the action list by tapping:

- "Presents NavigationSheet" - Shows a sheet with NavigationStack support
- "Presents NavigationFullScreen" - Shows a fullScreenCover with NavigationStack support

## Benefits

- **Push Navigation in Modals**: Enable hierarchical navigation within modal presentations
- **Consistent API**: Uses the same familiar SUICoordinator API
- **Backward Compatible**: Existing code continues to work without changes
- **Flexible**: Works with both sheets and fullScreenCover presentations

## Technical Details

The implementation wraps the modal content in a NavigationStack, providing a clean separation between the modal presentation and the internal navigation stack. This allows for complex navigation flows within modals while maintaining the coordinator pattern's benefits.

## Migration

No migration is required for existing code. The new functionality is additive and doesn't affect existing implementations.
