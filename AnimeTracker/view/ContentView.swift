//
//  ContentView.swift
//  AnimeTracker
//
//  Created by Manus on 29/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authService: AuthService
    @StateObject private var animeService = AnimeService()
    @StateObject private var userLibrary: UserLibrary
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    init() {
        // Crear primero la instancia de AuthService
        let auth = AuthService()
        // Luego inicializar los StateObjects
        _authService = StateObject(wrappedValue: auth)
        _userLibrary = StateObject(wrappedValue: UserLibrary(authService: auth))
    }
    
    var body: some View {
        // Use a Group to conditionally present views based on authentication
        NavigationStack {  // Añadir un único NavigationStack aquí
            Group {
                if authService.isAuthenticated {
                    // If authenticated, show the main tab view
                    MainTabView()
                        .navigationBarBackButtonHidden(true)  // Ocultar botón de retroceso
                } else {
                    // If not authenticated, show the login view
                    LoginView()
                        .navigationBarBackButtonHidden(true)  // Ocultar botón de retroceso
                }
            }
        }
        // Inject environment objects into the view hierarchy
        .environmentObject(authService)
        .environmentObject(animeService)
        .environmentObject(userLibrary)
        // Apply the preferred color scheme based on user settings
        .preferredColorScheme(isDarkMode ? .dark : .light)
        // Set up the SwiftData model container for the entire app
        // This ensures all views have access to the same data context
        .modelContainer(for: [UserModel.self, AnimeStats.self, SavedAnimeModel.self]) { result in
            // Handle the result of container creation
            switch result {
            case .success(let container):
                // If successful, set the main context in AuthService
                // This is crucial for AuthService to interact with the database
                authService.setModelContext(container.mainContext)
                // Also set the context for UserLibrary
                userLibrary.setModelContext(container.mainContext)
                // Attempt to load the current user if one was saved previously
                authService.loadCurrentUser()
            case .failure(let error):
                // Log an error if the container fails to initialize
                print("Failed to create ModelContainer: \(error.localizedDescription)")
            }
        }
        .onAppear {
            // No es necesario observar cambios manualmente ya que @AppStorage
            // actualizará automáticamente la vista cuando cambie el valor
            print("Dark mode is currently \(isDarkMode ? "enabled" : "disabled")")
            
            // Escuchar cambios en el modo oscuro
            NotificationCenter.default.addObserver(forName: Notification.Name("DarkModeChanged"), object: nil, queue: .main) { _ in
                // Forzar actualización de la vista actualizando el valor de isDarkMode
                let currentValue = isDarkMode
                isDarkMode = !currentValue
                isDarkMode = currentValue
            }
        }
    }
}
