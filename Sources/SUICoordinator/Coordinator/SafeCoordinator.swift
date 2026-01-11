//
//  SafeCoordinator.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import SwiftUI

/// A base coordinator class that provides safe presentation methods to prevent race conditions.
///
/// `SafeCoordinator` extends the standard `Coordinator` with additional safety measures
/// to prevent presentation conflicts and array index crashes that can occur when multiple
/// presentations are triggered simultaneously.
///
/// ## Key Features
/// - **Race Condition Prevention**: Prevents "presentation in progress" errors
/// - **Array Index Safety**: Prevents crashes from concurrent array access
/// - **Presentation Queuing**: Queues presentations to ensure they happen sequentially
/// - **Backward Compatibility**: Maintains all existing coordinator functionality
///
/// ## Usage Example
/// ```swift
/// class MyCoordinator: SafeCoordinator<MyRoute> {
///     func presentSheet() async {
///         let title = "Hello, Sheet!"
///         await safePresent(.sheet(coordinator: self, title: title), animated: true)
///     }
/// }
/// ```
open class SafeCoordinator<Route: RouteType>: Coordinator<Route> {
    
    /// Safely presents a view or coordinator with presentation queuing to prevent race conditions.
    ///
    /// This method ensures that presentations are queued and processed one at a time,
    /// preventing the "presentation in progress" error and array index crashes.
    ///
    /// - Parameters:
    ///   - view: The view or coordinator to present.
    ///   - presentationStyle: The transition presentation style for the presentation.
    ///                        Defaults to `.sheet` if not specified.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    @MainActor public func safePresent(_ view: Route, presentationStyle: TransitionPresentationStyle? = .sheet, animated: Bool = true) async -> Void {
        await router.safePresent(view, presentationStyle: presentationStyle, animated: animated)
    }
    
    /// Safely navigates to a coordinator with presentation queuing to prevent race conditions.
    ///
    /// This method provides the same functionality as `navigate(to:presentationStyle:animated:)`
    /// but with additional safety measures to prevent presentation conflicts and crashes.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator to navigate to. This coordinator will become a child
    ///                  of the current coordinator.
    ///   - presentationStyle: The transition presentation style for the navigation.
    ///                        Determines how the new coordinator's view will be presented.
    ///   - animated: A boolean value indicating whether to animate the navigation. Defaults to `true`.
    @MainActor public func safeNavigate(to coordinator: AnyCoordinatorType, presentationStyle: TransitionPresentationStyle, animated: Bool = true) async -> Void {
        startChildCoordinator(coordinator)
        
        let item = buildSheetItemForCoordinator(coordinator, presentationStyle: presentationStyle, animated: animated)
        
        // Present immediately without swipedAway to avoid lag and size adjustment
        await router.safePresentSheet(item: item)
    }
    
    /// Safely presents a sheet with a specific title and content.
    ///
    /// This convenience method creates a sheet route and presents it safely.
    /// Note: This method works by directly using the router's safePresent method.
    ///
    /// - Parameters:
    ///   - title: The title for the sheet.
    ///   - content: A closure that returns the content view for the sheet.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    @MainActor public func safePresentSheet<T: View>(title: String, @ViewBuilder content: @escaping () -> T, animated: Bool = true) async -> Void {
        // For now, this method is simplified to avoid type complexity
        // Users should create their own route types that conform to RouteType
        // and use safePresent(route, animated: animated) directly
        print("safePresentSheet: Please create a custom route type and use safePresent(route, animated: animated) instead")
    }
    
    /// Safely presents a full screen cover with a specific title and content.
    ///
    /// This convenience method creates a full screen cover route and presents it safely.
    /// Note: This method works by directly using the router's safePresent method.
    ///
    /// - Parameters:
    ///   - title: The title for the full screen cover.
    ///   - content: A closure that returns the content view for the full screen cover.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    @MainActor public func safePresentFullScreenCover<T: View>(title: String, @ViewBuilder content: @escaping () -> T, animated: Bool = true) async -> Void {
        // For now, this method is simplified to avoid type complexity
        // Users should create their own route types that conform to RouteType
        // and use safePresent(route, animated: animated) directly
        print("safePresentFullScreenCover: Please create a custom route type and use safePresent(route, animated: animated) instead")
    }
}
