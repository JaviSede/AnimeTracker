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
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView()
                        .onAppear {
                            // Cargar datos al aparecer la vista Home
                            if animeService.recommendedAnime.isEmpty {
                                animeService.fetchRecommendedAnime()
                            }
                            if animeService.popularAnime.isEmpty {
                                animeService.fetchPopularAnime()
                            }
                        }
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
            .preferredColorScheme(.dark)
            .onAppear {
                setupNotifications()
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // Código para manejar el cambio de pestaña
                print("Tab changed from \(oldValue) to \(newValue)")
            }
        }
    }
    
    private func setupNotifications() {
        // Eliminar observadores anteriores para evitar duplicados
        NotificationCenter.default.removeObserver(self)
        
        // Añadir nuevo observador
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToSearchTab"), object: nil, queue: .main) { _ in
            self.selectedTab = 1
            print("Notification received, switching to Search tab")
        }
    }
}
