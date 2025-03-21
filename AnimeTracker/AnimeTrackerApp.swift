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
    // Create a shared instance of the AnimeService
    let animeService = AnimeService()
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}
