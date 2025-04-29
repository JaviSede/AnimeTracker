//
//  AuthService.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation
import SwiftUI
import SwiftData

class AuthService: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        checkSavedUser()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    private func checkSavedUser() {
        // Verificar si hay un usuario guardado en UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let userId = try? JSONDecoder().decode(String.self, from: userData) {
            fetchUser(id: userId)
        }
    }
    
    func login(email: String, password: String) {
        guard let modelContext = modelContext else {
            self.error = "Error de base de datos"
            return
        }
        
        isLoading = true
        error = nil
        
        // Buscar usuario por email
        let predicate = #Predicate<UserModel> { user in
            user.email == email
        }
        
        do {
            let users = try modelContext.fetch(FetchDescriptor<UserModel>(predicate: predicate))
            
            if let user = users.first, user.password == password {
                self.currentUser = user
                self.isAuthenticated = true
                
                // Guardar ID de usuario en UserDefaults
                if let encoded = try? JSONEncoder().encode(user.id) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
            } else {
                self.error = "Email o contraseña incorrectos"
            }
        } catch {
            self.error = "Error al iniciar sesión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func register(username: String, email: String, password: String) {
        guard let modelContext = modelContext else {
            self.error = "Error de base de datos"
            return
        }
        
        isLoading = true
        error = nil
        
        // Verificar si el email ya existe
        let predicate = #Predicate<UserModel> { user in
            user.email == email
        }
        
        do {
            let existingUsers = try modelContext.fetch(FetchDescriptor<UserModel>(predicate: predicate))
            
            if !existingUsers.isEmpty {
                self.error = "El email ya está registrado"
                isLoading = false
                return
            }
            
            // Crear nuevo usuario
            let newUser = UserModel(
                username: username,
                email: email,
                password: password
            )
            
            // Crear estadísticas para el usuario
            let stats = AnimeStats()
            stats.user = newUser
            newUser.stats = stats
            
            // Guardar en la base de datos
            modelContext.insert(newUser)
            try modelContext.save()
            
            // Iniciar sesión automáticamente
            self.currentUser = newUser
            self.isAuthenticated = true
            
            // Guardar ID de usuario en UserDefaults
            if let encoded = try? JSONEncoder().encode(newUser.id) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
        } catch {
            self.error = "Error al registrar: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func updateProfile(username: String, bio: String, profileImage: UIImage?) {
        guard let modelContext = modelContext, let user = currentUser else {
            self.error = "Usuario no encontrado"
            return
        }
        
        isLoading = true
        
        // Actualizar datos del usuario
        user.username = username
        user.bio = bio
        
        // Aquí iría la lógica para subir la imagen a un servidor
        // y obtener la URL para guardarla en profileImageUrl
        
        do {
            try modelContext.save()
        } catch {
            self.error = "Error al actualizar perfil: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchUser(id: String) {
        guard let modelContext = modelContext else {
            self.error = "Error de base de datos"
            return
        }
        
        let predicate = #Predicate<UserModel> { user in
            user.id == id
        }
        
        do {
            let users = try modelContext.fetch(FetchDescriptor<UserModel>(predicate: predicate))
            
            if let user = users.first {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("Error al recuperar usuario: \(error.localizedDescription)")
        }
    }
}