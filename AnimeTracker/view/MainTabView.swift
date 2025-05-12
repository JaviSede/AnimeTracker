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
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(0) // Tag identifies this tab
            
            // Search Tab
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Label("Buscar", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            // Library Tab
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label("Biblioteca", systemImage: "books.vertical.fill")
            }
            .tag(2)
            
            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .tag(3)
        }
        // Present the SettingsView as a sheet when showingSettings is true
        .sheet(isPresented: $showingSettings) {
            SettingsView(isDarkMode: $isDarkMode)
        }
        // Apply the preferred color scheme based on user settings
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // Set up notification observers and configure TabBar appearance when the view appears
        // En la función onAppear
        .onAppear {
            // Configurar la apariencia de la barra de pestañas
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            
            // Ajustar colores según el modo
            if isDarkMode {
                tabBarAppearance.backgroundColor = UIColor.black
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
            } else {
                tabBarAppearance.backgroundColor = UIColor.white
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
            }
            
            // Aplicar la apariencia a la barra de pestañas
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // Configurar notificaciones
            setupNotifications()
        }
    }
    
    // Function to set up notification observers
    private func setupNotifications() {
        // Observe notification to switch to the search tab
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToSearchTab"), object: nil, queue: .main) { _ in
            selectedTab = 1
        }
        
        // Observar cambios en el modo oscuro
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DarkModeChanged"), object: nil, queue: .main) { _ in
            // Actualizar la apariencia de la barra de pestañas
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            
            // Ajustar colores según el modo
            if self.isDarkMode {
                tabBarAppearance.backgroundColor = UIColor.black
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
            } else {
                tabBarAppearance.backgroundColor = UIColor.white
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
            }
            
            // Aplicar la apariencia a la barra de pestañas
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        // Add other notification observers if needed
    }
}

