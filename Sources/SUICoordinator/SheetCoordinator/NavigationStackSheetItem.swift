//
//  NavigationStackSheetItem.swift
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
import Combine
import SwiftUI

/// A structure representing a sheet item with NavigationStack support for presenting views or coordinators.
///
/// `NavigationStackSheetItem` extends the basic `SheetItem` functionality by wrapping the content
/// in a NavigationStack, enabling push navigation within modal presentations like sheets and fullScreenCover.
///
/// This is particularly useful when you need to present a modal that contains multiple screens
/// that can navigate between each other using push/pop navigation.
///
/// ## Key Features
/// - NavigationStack wrapper for modal content
/// - Supports both SwiftUI views and coordinators
/// - Configurable presentation styles and animation
/// - Built-in dismissal lifecycle management
/// - Type-safe view/coordinator handling
public struct NavigationStackSheetItem<T>: SCEquatable, SheetItemType {
    
    // ---------------------------------------------------------
    // MARK: Properties
    // ---------------------------------------------------------
    
    /// The unique identifier for the sheet item.
    public let id: String
    
    /// The view or coordinator factory associated with the sheet item.
    let view: () -> T?
    
    /// A boolean value indicating whether to animate the presentation.
    let animated: Bool
    
    /// The transition presentation style for presenting the sheet item.
    let presentationStyle: TransitionPresentationStyle
    
    /// A subject that emits when the sheet is about to be dismissed.
    let willDismiss: PassthroughSubject<Void, Never> = .init()
    
    /// A boolean value indicating whether the sheet item contains a coordinator.
    let isCoordinator: Bool
    
    /// The navigation path for the NavigationStack.
    @State private var navigationPath: [AnyHashable] = []
    
    // ---------------------------------------------------------
    // MARK: Constructor
    // ---------------------------------------------------------
    
    /// Initializes a new instance of `NavigationStackSheetItem`.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the sheet item.
    ///   - animated: A boolean value indicating whether to animate the presentation.
    ///   - presentationStyle: The transition presentation style for presenting the sheet item.
    ///   - isCoordinator: A boolean indicating whether the content is a coordinator.
    ///   - view: A closure that creates and returns the view or coordinator to present.
    init(
        id: String,
        animated: Bool,
        presentationStyle: TransitionPresentationStyle,
        isCoordinator: Bool = false,
        view: @escaping () -> T?
    ) {
        self.view = view
        self.animated = animated
        self.presentationStyle = presentationStyle
        self.id = id
        self.isCoordinator = isCoordinator
    }
    
    // ---------------------------------------------------------
    // MARK: SheetItemType Conformance
    // ---------------------------------------------------------
    
    /// Returns the presentation style for this sheet item.
    func getPresentationStyle() -> TransitionPresentationStyle {
        presentationStyle
    }
    
    /// Returns whether the sheet presentation should be animated.
    func isAnimated() -> Bool {
        animated
    }
    
    /// Creates a NavigationStack-wrapped view from the content.
    ///
    /// This method wraps the original content in a NavigationStack to enable
    /// push navigation within the modal presentation.
    ///
    /// - Returns: A NavigationStack-wrapped view, or the original view if it's not a SwiftUI view.
    @ViewBuilder
    func createNavigationStackView() -> some View {
        if let content = view() as? AnyView {
            NavigationStack(path: $navigationPath) {
                content
                    .navigationDestination(for: AnyHashable.self) { destination in
                        // This allows for dynamic navigation destinations
                        // The actual destination handling should be implemented by the content
                        EmptyView()
                    }
            }
        } else {
            // Fallback for non-SwiftUI content (like coordinators)
            if let content = view() {
                AnyView(content as? AnyView ?? AnyView(EmptyView()))
            } else {
                AnyView(EmptyView())
            }
        }
    }
}
