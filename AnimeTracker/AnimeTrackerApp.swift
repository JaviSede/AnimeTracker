//
//  AnimeTrackerApp.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI
import SwiftData

@main
struct AnimeTrackerApp: App {
    // Removed StateObject initializations here as they are now managed within ContentView
    // or passed down via environment objects initialized there.

    var body: some Scene {
        WindowGroup {
            // Use the new ContentView as the root view of the application.
            // ContentView will handle setting up the model container, environment objects,
            // and determining whether to show LoginView or MainTabView based on auth state.
            ContentView()
            // The .modelContainer modifier is now applied within ContentView,
            // ensuring proper context injection and handling.
        }
    }
    
    // Removed setupNotifications() as it's now handled within MainTabView
}

