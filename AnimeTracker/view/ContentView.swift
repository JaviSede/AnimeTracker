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
        // Crear la instancia de AuthService
        let auth = AuthService()
        // Luego inicializar los StateObjects
        _authService = StateObject(wrappedValue: auth)
        _userLibrary = StateObject(wrappedValue: UserLibrary(authService: auth))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if authService.isAuthenticated {
                    // If authenticated, show the main tab view
                    MainTabView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    // If not authenticated, show the login view
                    LoginView()
                        .navigationBarBackButtonHidden(true)
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
            print("Dark mode is currently \(isDarkMode ? "enabled" : "disabled")")
        }
                .onChange(of: isDarkMode) { oldValue, newValue in
            // Este bloque se ejecuta cada vez que cambia isDarkMode
            print("Dark mode changed from \(oldValue) to \(newValue)")
            
            // Notificar a otras vistas sobre el cambio
            NotificationCenter.default.post(name: Notification.Name("DarkModeChanged"), object: nil)
            
            // Forzar actualización de la interfaz usando el método moderno
            DispatchQueue.main.async {
                // Actualizar apariencia de barras inmediatamente
                updateAppearance(isDarkMode: isDarkMode)
                
                // Usar el método moderno para acceder a las escenas de la aplicación
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    // Aplicar el estilo de interfaz
                    window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                    
                    // Forzar actualización de la interfaz
                    if let rootVC = window.rootViewController {
                        // Actualizar la vista raíz
                        updateUserInterfaceStyle(rootVC, isDarkMode: isDarkMode)
                        
                        // Forzar reconstrucción de la interfaz
                        let snapshot = rootVC.view.snapshotView(afterScreenUpdates: false)
                        if let snapshot = snapshot {
                            window.addSubview(snapshot)
                            rootVC.view.isHidden = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                rootVC.view.isHidden = false
                                snapshot.removeFromSuperview()
                                
                                // Actualizar apariencia de barras nuevamente después de la reconstrucción
                                updateAppearance(isDarkMode: isDarkMode)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateAppearance(isDarkMode: Bool) {
        // Configurar la apariencia de la barra de pestañas
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // Configurar la apariencia de la barra de navegación
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        if isDarkMode {
            // Modo oscuro
            tabBarAppearance.backgroundColor = UIColor.black
            navBarAppearance.backgroundColor = UIColor.black
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            // Modo claro
            tabBarAppearance.backgroundColor = UIColor.white
            navBarAppearance.backgroundColor = UIColor.white
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
        
        // Configurar colores de elementos de la barra de pestañas
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.gray]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.purple
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        
        // Aplicar apariencia a las barras
        UINavigationBar.appearance().tintColor = UIColor.purple
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Forzar actualización de todas las barras de navegación en todas las ventanas
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene {
                for window in windowScene.windows {
                    for view in window.subviews {
                        view.setNeedsLayout()
                        view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    // Función recursiva para actualizar el estilo de interfaz en todos los controladores
    private func updateUserInterfaceStyle(_ viewController: UIViewController, isDarkMode: Bool) {
        // Aplicar estilo al controlador actual
        viewController.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // Aplicar a controladores presentados
        if let presented = viewController.presentedViewController {
            updateUserInterfaceStyle(presented, isDarkMode: isDarkMode)
        }
        
        // Aplicar a controladores hijos
        for child in viewController.children {
            updateUserInterfaceStyle(child, isDarkMode: isDarkMode)
        }
        
        // Aplicar a controladores en navegación
        if let navController = viewController as? UINavigationController {
            for viewController in navController.viewControllers {
                updateUserInterfaceStyle(viewController, isDarkMode: isDarkMode)
            }
        }
        
        // Aplicar a controladores en pestañas
        if let tabController = viewController as? UITabBarController {
            for viewController in tabController.viewControllers ?? [] {
                updateUserInterfaceStyle(viewController, isDarkMode: isDarkMode)
            }
        }
    }
}
