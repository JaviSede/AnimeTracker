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
    @StateObject private var animeService = AnimeService()
    @StateObject private var userLibrary = UserLibrary()
    @StateObject private var authService = AuthService()
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            if !authService.isAuthenticated {
                LoginView()
                    .environmentObject(animeService)
                    .environmentObject(userLibrary)
                    .environmentObject(authService)
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                    
                    NavigationStack {
                        SearchView()
                    }
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                    
                    NavigationStack {
                        LibraryView()
                    }
                    .tabItem {
                        Label("Library", systemImage: "books.vertical.fill")
                    }
                    .tag(2)
                    
                    NavigationStack {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(3)
                }
                .environmentObject(animeService)
                .environmentObject(userLibrary)
                .environmentObject(authService)
                .preferredColorScheme(.dark)
                .onAppear {
                    setupNotifications()
                }
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToSearchTab"), object: nil, queue: .main) { _ in
            selectedTab = 1
        }
    }
}
