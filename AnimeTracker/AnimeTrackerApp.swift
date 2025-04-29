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
    @State private var showingSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            if !authService.isAuthenticated {
                LoginView()
                    .environmentObject(animeService)
                    .environmentObject(userLibrary)
                    .environmentObject(authService)
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .modelContainer(for: [UserModel.self, AnimeStats.self, SavedAnimeModel.self])
                    .onAppear {
                        if let modelContext = try? ModelContainer(for: UserModel.self, AnimeStats.self, SavedAnimeModel.self).mainContext {
                            authService.setModelContext(modelContext)
                        }
                    }
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        HomeView(showSettings: $showingSettings, switchToProfileTab: {
                            selectedTab = 3
                        })
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
                .sheet(isPresented: $showingSettings) {
                    SettingsView(isDarkMode: $isDarkMode)
                }
                .environmentObject(animeService)
                .environmentObject(userLibrary)
                .environmentObject(authService)
                .preferredColorScheme(isDarkMode ? .dark : .light)
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
