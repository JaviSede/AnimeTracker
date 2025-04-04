//
//  AuthService.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation
import SwiftUI
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let userDefaults = UserDefaults.standard
    private let currentUserKey = "currentUser"
    
    init() {
        loadUser()
    }
    
    private func loadUser() {
        if let userData = userDefaults.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulación de login - En una app real, esto sería una llamada a API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulamos un login exitoso
            if email == "test@example.com" && password == "password" {
                let user = User(
                    id: UUID().uuidString,
                    username: "AnimeUser",
                    email: email,
                    profileImageUrl: nil,
                    bio: "Anime enthusiast",
                    joinDate: Date(),
                    animeStats: User.AnimeStats()
                )
                
                self.currentUser = user
                self.isAuthenticated = true
                
                // Guardar usuario en UserDefaults
                if let encoded = try? JSONEncoder().encode(user) {
                    self.userDefaults.set(encoded, forKey: self.currentUserKey)
                }
            } else {
                self.error = "Invalid email or password"
            }
            
            self.isLoading = false
        }
    }
    
    func register(username: String, email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulación de registro - En una app real, esto sería una llamada a API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulamos un registro exitoso
            let user = User(
                id: UUID().uuidString,
                username: username,
                email: email,
                profileImageUrl: nil,
                bio: nil,
                joinDate: Date(),
                animeStats: User.AnimeStats()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            
            // Guardar usuario en UserDefaults
            if let encoded = try? JSONEncoder().encode(user) {
                self.userDefaults.set(encoded, forKey: self.currentUserKey)
            }
            
            self.isLoading = false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: currentUserKey)
    }
    
    func updateProfile(username: String, bio: String, profileImage: UIImage?) {
        guard var user = currentUser else { return }
        
        user.username = username
        user.bio = bio
        
        // En una app real, aquí subirías la imagen a un servidor
        // y actualizarías la URL de la imagen de perfil
        
        self.currentUser = user
        
        // Guardar usuario actualizado en UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            self.userDefaults.set(encoded, forKey: self.currentUserKey)
        }
    }
    
    func updateAnimeStats() {
        guard var user = currentUser else { return }
        
        // Actualizar estadísticas basadas en la biblioteca del usuario
        // Esto se conectaría con tu UserLibrary
        
        self.currentUser = user
        
        // Guardar usuario actualizado en UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            self.userDefaults.set(encoded, forKey: self.currentUserKey)
        }
    }
}