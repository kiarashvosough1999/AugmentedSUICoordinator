//
//  CoordinatorType+RestartFlow.swift
//  SUICoordinator
//
//  Created by Kiarash Vosough on 08.10.25.
//

import SwiftUI

/// Extension to provide restart flow functionality with new presentation style and mainView
public extension CoordinatorType {
    
    /// Restarts the coordinator flow with a new presentation style and mainView.
    ///
    /// This method provides a way to restart a coordinator's flow with a completely new
    /// presentation style and mainView, effectively replacing the current flow entirely.
    /// It properly dismisses the current presentation and presents a new one with updated content.
    ///
    /// - Parameters:
    ///   - newRoute: The new route to set as the mainView for the coordinator.
    ///   - newPresentationStyle: The new presentation style for the flow.
    ///   - animated: A boolean value indicating whether to animate the restart action.
    ///               Defaults to `true`.
    ///
    /// ## Usage Notes
    /// - This method will clear all navigation history and modal presentations
    /// - The coordinator will be reset to its initial state with the new route
    /// - The new presentation style will be applied to the new mainView
    /// - Dismisses current presentation and presents new one to prevent duplicates
    /// - Useful for major state changes or flow replacements
    ///
    /// ## Example Usage
    /// ```swift
    /// await coordinator.restartFlow(
    ///     newRoute: .homeTab(coordinator: newCoordinator),
    ///     newPresentationStyle: .fullScreenCover,
    ///     animated: true
    /// )
    /// ```
    @MainActor func restartFlow(
        newRoute: Route,
        newPresentationStyle: TransitionPresentationStyle,
        animated: Bool = true
    ) async -> Void {
        // First, restart the coordinator to clear all navigation state
        await restart(animated: animated)
        
        // Wait a brief moment to ensure the restart is complete
        try? await Task.sleep(for: .milliseconds(100))
        
        // Set the new mainView BEFORE updating the parent
        router.mainView = newRoute
        
        // Wait a moment for the mainView to be properly set
        try? await Task.sleep(for: .milliseconds(50))
        
        // Update the parent coordinator's sheet item with new content and style
        await updateParentSheetItem(
            newRoute: newRoute,
            newPresentationStyle: newPresentationStyle,
            animated: animated
        )
    }
    
    /// Restarts the coordinator flow with a new coordinator and presentation style.
    ///
    /// This method provides a way to restart a coordinator's flow by navigating to
    /// a new coordinator with a specific presentation style.
    ///
    /// - Parameters:
    ///   - newCoordinator: The new coordinator to navigate to.
    ///   - newPresentationStyle: The new presentation style for the navigation.
    ///   - animated: A boolean value indicating whether to animate the restart action.
    ///               Defaults to `true`.
    ///
    /// ## Usage Notes
    /// - This method will clear all navigation history and modal presentations
    /// - The new coordinator will be added as a child of the current coordinator
    /// - The new presentation style will be applied to the new coordinator
    /// - Useful for switching between different coordinator flows
    ///
    /// ## Example Usage
    /// ```swift
    /// await coordinator.restartFlow(
    ///     newCoordinator: homeTabCoordinator,
    ///     newPresentationStyle: .fullScreenCover,
    ///     animated: true
    /// )
    /// ```
    @MainActor func restartFlow(
        newCoordinator: AnyCoordinatorType,
        newPresentationStyle: TransitionPresentationStyle,
        animated: Bool = true
    ) async -> Void {
        // First, restart the coordinator to clear all navigation state
        await restart(animated: animated)
        
        // Wait a brief moment to ensure the restart is complete
        try? await Task.sleep(for: .milliseconds(100))
        
        // Navigate to the new coordinator with the new presentation style
        await navigate(
            to: newCoordinator,
            presentationStyle: newPresentationStyle,
            animated: animated
        )
    }
    
    /// Restarts the coordinator flow with a new route, maintaining the current presentation style.
    ///
    /// This method provides a way to restart a coordinator's flow with a new route
    /// while keeping the current presentation style.
    ///
    /// - Parameters:
    ///   - newRoute: The new route to set as the mainView for the coordinator.
    ///   - animated: A boolean value indicating whether to animate the restart action.
    ///               Defaults to `true`.
    ///
    /// ## Usage Notes
    /// - This method will clear all navigation history and modal presentations
    /// - The coordinator will be reset to its initial state with the new route
    /// - The current presentation style will be maintained
    /// - Useful for content changes while maintaining presentation style
    ///
    /// ## Example Usage
    /// ```swift
    /// await coordinator.restartFlow(
    ///     newRoute: .homeTab(coordinator: newCoordinator),
    ///     animated: true
    /// )
    /// ```
    @MainActor func restartFlow(
        newRoute: Route,
        animated: Bool = true
    ) async -> Void {
        // First, restart the coordinator to clear all navigation state
        await restart(animated: animated)
        
        // Wait a brief moment to ensure the restart is complete
        try? await Task.sleep(for: .milliseconds(100))
        
        // Set the new mainView BEFORE updating the parent
        router.mainView = newRoute
        
        // Wait a moment for the mainView to be properly set
        try? await Task.sleep(for: .milliseconds(50))
        
        // Update the parent coordinator's sheet item with new content
        await updateParentSheetItem(
            newRoute: newRoute,
            newPresentationStyle: nil, // Keep current style
            animated: animated
        )
    }
}

// MARK: - Private Helper Methods

private extension CoordinatorType {
    
    /// Updates the parent coordinator's sheet item with new content and presentation style.
    ///
    /// This method uses a simpler approach by dismissing the current presentation
    /// and presenting a new one with the updated content and presentation style.
    ///
    /// - Parameters:
    ///   - newRoute: The new route to set in the sheet item.
    ///   - newPresentationStyle: The new presentation style, or nil to keep current style.
    ///   - animated: Whether to animate the update.
    @MainActor func updateParentSheetItem(
        newRoute: Route,
        newPresentationStyle: TransitionPresentationStyle?,
        animated: Bool
    ) async {
        // Check if we're presented as a sheet by looking at the parent coordinator
        guard let parentCoordinator = parent else { return }
        
        // Get the presentation style to use
        let presentationStyle = newPresentationStyle ?? newRoute.presentationStyle
        
        // First, finish the current flow to clean up
        await finishFlow(animated: animated)
        
        // Wait a moment for the dismissal to complete
        try? await Task.sleep(for: .milliseconds(200))
        
        // Ensure our mainView is set to the new route before presenting
        router.mainView = newRoute
        
        // Wait a moment for the mainView to be properly set
        try? await Task.sleep(for: .milliseconds(50))
        
        // Use the parent coordinator's navigate method to present the updated coordinator
        // The coordinator now has the new mainView set, so it will present the new content
        await parentCoordinator.navigate(
            to: self,
            presentationStyle: presentationStyle,
            animated: animated
        )
    }
}
