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
    
    @State private var selectedTab = 0 
    @State private var showingSettings = false

    var body: some View {
        // TabView provides the main navigation structure with tabs at the bottom
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                HomeView(showSettings: $showingSettings, switchToProfileTab: {
                    selectedTab = 3
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
        // Presentar la vista de ajustes si showingSettings es verdadero
        .sheet(isPresented: $showingSettings) {
            SettingsView(isDarkMode: $isDarkMode)
        }
        // Aplicar el modo oscuro o claro según isDarkMode
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
            
            // Configurar la apariencia de la barra de navegación
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            
            // Ajustar colores según el modo
            if isDarkMode {
                navBarAppearance.backgroundColor = UIColor.black
                navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                UINavigationBar.appearance().tintColor = UIColor.purple
            } else {
                navBarAppearance.backgroundColor = UIColor.white
                navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor.purple
            }
            
            // Aplicar la apariencia a la barra de navegación
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
            // Configurar notificaciones
            setupNotifications()
        }
    }
    
    private func setupNotifications() {
        // Observar cambios en la selección de pestañas
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SwitchToSearchTab"), object: nil, queue: .main) { _ in
            selectedTab = 1
        }
        
        // Observar cambios en el modo oscuro
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DarkModeChanged"), object: nil, queue: .main) { _ in
            // Actualizar la apariencia de la barra de pestañas
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            
            // Actualizar la apariencia de la barra de navegación
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            
            // Ajustar colores según el modo
            if self.isDarkMode {
                // Configuración para TabBar en modo oscuro
                tabBarAppearance.backgroundColor = UIColor.black
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
                
                // Configuración para NavigationBar en modo oscuro
                navBarAppearance.backgroundColor = UIColor.black
                navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                UINavigationBar.appearance().tintColor = UIColor.purple
            } else {
                // Configuración para TabBar en modo claro
                tabBarAppearance.backgroundColor = UIColor.white
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
                
                // Configuración para NavigationBar en modo claro
                navBarAppearance.backgroundColor = UIColor.white
                navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
                UINavigationBar.appearance().tintColor = UIColor.purple
            }
            
            // Aplicar la apariencia a las barras
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            
            // Forzar actualización de la interfaz
            DispatchQueue.main.async {
                // Esto fuerza a que las vistas se actualicen
                UIApplication.shared.windows.first?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                
                // Actualizar preferencias de color para todas las vistas
                for window in UIApplication.shared.windows {
                    window.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
                }
            }
        }
    }
}

