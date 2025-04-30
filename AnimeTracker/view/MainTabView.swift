//
//  MainTabView.swift
//  AnimeTracker
//
//  Created by Manus on 29/4/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService // Access AuthService from environment
    @EnvironmentObject var animeService: AnimeService // Access AnimeService from environment
    @EnvironmentObject var userLibrary: UserLibrary // Access UserLibrary from environment
    @AppStorage("isDarkMode") private var isDarkMode = true // Access dark mode setting
    
    @State private var selectedTab = 0 // State for the currently selected tab
    @State private var showingSettings = false // State to control settings sheet presentation

    var body: some View {
        // TabView provides the main navigation structure with tabs at the bottom
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView(showSettings: $showingSettings, switchToProfileTab: {
                    selectedTab = 3 // Switch to profile tab when requested
                })
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0) // Tag identifies this tab
            
            // Search Tab
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            // Library Tab
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical.fill")
            }
            .tag(2)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        // Present the SettingsView as a sheet when showingSettings is true
        .sheet(isPresented: $showingSettings) {
            SettingsView(isDarkMode: $isDarkMode)
        }
        // Apply the preferred color scheme based on user settings
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // Set up notification observers when the view appears
        .onAppear {
            setupNotifications()
        }
        // Inject environment objects needed by the child views within the TabView
        // Note: These are already injected by ContentView, but explicitly stating them here
        // can sometimes help with clarity or specific scenarios, though often redundant.
        // .environmentObject(animeService)
        // .environmentObject(userLibrary)
        // .environmentObject(authService)
    }
    
    // Function to set up notification observers
    private func setupNotifications() {
        // Observe notification to switch to the search tab
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToSearchTab"), object: nil, queue: .main) { _ in
            selectedTab = 1
        }
        // Add other notification observers if needed
    }
}

