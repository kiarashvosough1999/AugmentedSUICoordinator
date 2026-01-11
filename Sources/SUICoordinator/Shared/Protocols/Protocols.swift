//
//  Protocol.swift
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

/// Protocol for coordinators that can present views through a parent TabCoordinator
public protocol TabChildPresentable: AnyObject {
    /// The parent TabCoordinator that handles presentations
    @MainActor var parentTabCoordinator: (any TabCoordinatable)? { get set }
    
    /// Presents a route through the parent TabCoordinator's router
    func presentThroughParent<Route: RouteType>(_ route: Route, presentationStyle: TransitionPresentationStyle?, animated: Bool) async
    
    /// Presents a sheet through the parent TabCoordinator's router
    func presentSheetThroughParent(_ item: SheetItem<AnyViewAlias>) async
    
    /// Dismisses the current presentation through the parent TabCoordinator's router
    func dismissThroughParent(animated: Bool) async
    
    /// Navigates to a coordinator through the parent TabCoordinator's router
    func navigateThroughParent(to coordinator: AnyCoordinatorType, presentationStyle: TransitionPresentationStyle, animated: Bool) async
}

/// Default implementation for TabChildPresentable
public extension TabChildPresentable {
    func presentThroughParent<Route: RouteType>(_ route: Route, presentationStyle: TransitionPresentationStyle? = .sheet, animated: Bool = true) async {
        if let tabCoordinator = await parentTabCoordinator as? (any TabCoordinatable) {
            await tabCoordinator.presentFromChild(route, presentationStyle: presentationStyle, animated: animated)
        }
    }
    
    func presentSheetThroughParent(_ item: SheetItem<AnyViewAlias>) async {
        if let tabCoordinator = await parentTabCoordinator as? (any TabCoordinatable) {
            await tabCoordinator.presentSheetFromChild(item)
        }
    }
    
    func dismissThroughParent(animated: Bool = true) async {
        if let tabCoordinator = await parentTabCoordinator as? (any TabCoordinatable) {
            await tabCoordinator.dismissFromChild(animated: animated)
        }
    }
    
    func navigateThroughParent(
        to coordinator: AnyCoordinatorType,
        presentationStyle: TransitionPresentationStyle,
        animated: Bool = true
    ) async {
        if let tabCoordinator = await parentTabCoordinator as? (any TabCoordinatable) {
            await tabCoordinator.navigateFromChild(to: coordinator, presentationStyle: presentationStyle, animated: animated)
        }
    }
}

// ---------------------------------------------------------
// MARK: RCEquatable
// ---------------------------------------------------------

/// A protocol that extends `RCIdentifiable` and `Equatable`, providing default implementation for equality based on identifier.
/// Conforming types must implement `RCIdentifiable`.
/// - SeeAlso: `RCIdentifiable`
public protocol SCEquatable: SCIdentifiable, Equatable {}

public extension SCEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}


// ---------------------------------------------------------
// MARK: RCIdentifiable
// ---------------------------------------------------------

/// A protocol that inherits from `Identifiable`, providing a default identifier implementation based on the type's name.
/// Conforming types automatically get an identifier based on their type name.
/// - Important: The identifier is based on the type name using `String(describing: self.self)`.
/// - SeeAlso: `Identifiable`
public protocol SCIdentifiable: Identifiable {
    var id: String { get }
}

extension SCIdentifiable {
    /// The default identifier based on the type's name.
    public var id: String {
        String(describing: self.self)
    }
}


// ---------------------------------------------------------
// MARK: CRHashable
// ---------------------------------------------------------

/// A protocol that extends `RCIdentifiable` and `Hashable`, providing default implementation for hashing based on identifier.
/// Conforming types must implement `RCIdentifiable`.
/// - SeeAlso: `RCIdentifiable`, `Hashable`
public protocol SCHashable: SCIdentifiable, Hashable {}

extension SCHashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
