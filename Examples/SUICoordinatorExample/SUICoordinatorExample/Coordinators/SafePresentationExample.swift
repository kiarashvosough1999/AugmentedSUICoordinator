//
//  SafePresentationExample.swift
//
//  This example demonstrates how to use the fixed SUICoordinator package
//  to prevent presentation race conditions and crashes.
//

import SwiftUI
import SUICoordinator

// Example route enum
enum ExampleRoute: RouteType {
    case home
    case sheet(title: String)
    case fullScreen(title: String)
    
    var id: String {
        switch self {
        case .home: return "home"
        case .sheet(let title): return "sheet-\(title)"
        case .fullScreen(let title): return "fullscreen-\(title)"
        }
    }
    
    var presentationStyle: TransitionPresentationStyle {
        switch self {
        case .home: return .push
        case .sheet: return .sheet
        case .fullScreen: return .fullScreenCover
        }
    }
    
    @ViewBuilder
    var content: AnyView {
        switch self {
        case .home:
            AnyView(HomeView())
        case .sheet(let title):
            AnyView(SheetView(title: title))
        case .fullScreen(let title):
            AnyView(FullScreenView(title: title))
        }
    }
}

// Example coordinator using the safe presentation methods
class ExampleSafeCoordinator: SafeCoordinator<ExampleRoute> {
    
    override func start() async {
        await startFlow(route: .home)
    }
    
    // Safe presentation methods that prevent race conditions
    func presentSheetSafely() async {
        let title = "Safe Sheet - \(Date().timeIntervalSince1970)"
        await safePresent(.sheet(title: title), animated: true)
    }
    
    func presentFullScreenSafely() async {
        let title = "Safe FullScreen - \(Date().timeIntervalSince1970)"
        await safePresent(.fullScreen(title: title), animated: true)
    }
    
    func presentCustomSheet() async {
        await safePresentSheet(title: "Custom Sheet") {
            VStack {
                Text("This is a custom sheet")
                    .font(.title)
                Text("Presented safely without race conditions")
                    .font(.body)
                Button("Dismiss") {
                    Task { @MainActor in
                        await self.router.dismiss()
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

// Example views
struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Safe Presentation Example")
                .font(.largeTitle)
                .padding()
            
            Text("This example demonstrates safe presentation methods that prevent race conditions and crashes.")
                .multilineTextAlignment(.center)
                .padding()
            
            // Note: In a real app, you would inject the coordinator
            // For this example, we'll just show the concept
            Text("Use SafeCoordinator in your coordinators to prevent presentation issues.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SheetView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
            
            Text("This sheet was presented safely using the fixed SUICoordinator package.")
                .multilineTextAlignment(.center)
            
            Button("Present Another Sheet") {
                // This would be called from the coordinator
                // Task { await coordinator.presentSheetSafely() }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct FullScreenView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
            
            Text("This full screen cover was presented safely.")
                .multilineTextAlignment(.center)
            
            Button("Dismiss") {
                // This would be called from the coordinator
                // Task { await coordinator.router.dismiss() }
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

// Usage instructions
/*
 
 HOW TO USE THE FIXED SUICOORDINATOR PACKAGE:
 
 1. Replace your existing coordinator base class with SafeCoordinator:
 
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
 
 2. Use safe presentation methods:
    - safePresent() - for presenting routes safely
    - safeNavigate() - for navigating to coordinators safely
    - safePresentSheet() - for presenting custom sheets safely
    - safePresentFullScreenCover() - for presenting full screen covers safely
 
 3. The package now includes:
    - Presentation queuing to prevent race conditions
    - Safe array access to prevent index out of bounds crashes
    - Proper concurrency protection
    - Backward compatibility with existing code
 
 4. For TabCoordinator child coordinators, use SafeCoordinator as the base class:
 
    class TabChildCoordinator: SafeCoordinator<ChildRoute> {
        func presentFromTab() async {
            // This will now work safely without crashes
            await safePresent(.sheet(title: "From Tab"), animated: true)
        }
    }
 
 */
