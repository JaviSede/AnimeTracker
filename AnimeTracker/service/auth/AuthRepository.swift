//
//  AuthRepository.swift
//  AnimeTracker
//

import Foundation
import SwiftData
import CryptoKit

// Protocolo para el repositorio de autenticación
protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> UserModel
    func register(username: String, email: String, password: String) async throws -> UserModel
    func getCurrentUser() async throws -> UserModel?
    func logout() async throws // Modificado para lanzar errores de Keychain
    func updateProfile(username: String, bio: String, imageData: Data?) async throws -> UserModel
}

class AuthRepository: AuthRepositoryProtocol {
    private let modelContext: ModelContext
    private let keychainService = "com.animetracker.auth"
    private let keychainAccount = "currentUser"
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func login(email: String, password: String) async throws -> UserModel {
        let predicate = #Predicate<UserModel> { $0.email == email }
        let descriptor = FetchDescriptor<UserModel>(predicate: predicate)
        
        let users = try modelContext.fetch(descriptor)
        guard let user = users.first else {
            throw AuthError.invalidCredentials
        }
        
        // Verificar contraseña con hash seguro
        guard try verifyPassword(password, hashedPassword: user.password) else {
            throw AuthError.invalidCredentials
        }
        
        // Guardar ID de usuario en Keychain
        guard let userIDData = user.id.data(using: .utf8) else {
            // Manejar error si no se puede convertir el ID a Data
            throw AuthError.keychainError("Failed to encode user ID")
        }
        do {
            try KeychainManager.save(service: keychainService, account: keychainAccount, password: userIDData)
        } catch KeychainManager.KeychainError.duplicateEntry {
            // Si ya existe, intentar actualizar
            try KeychainManager.update(service: keychainService, account: keychainAccount, password: userIDData)
        } catch {
            throw AuthError.keychainError("Failed to save user ID to Keychain: \(error.localizedDescription)")
        }
        
        return user
    }
    
    func register(username: String, email: String, password: String) async throws -> UserModel {
        // Verificar si el email ya existe
        let predicate = #Predicate<UserModel> { $0.email == email }
        let descriptor = FetchDescriptor<UserModel>(predicate: predicate)
        let existingUsers = try modelContext.fetch(descriptor)
        
        if !existingUsers.isEmpty {
            throw AuthError.emailAlreadyExists
        }
        
        // Crear hash de la contraseña
        let hashedPassword = try hashPassword(password)
        
        // Crear nuevo usuario
        let newUser = UserModel(
            username: username,
            email: email,
            password: hashedPassword
        )
        
        // Crear estadísticas
        let stats = AnimeStats()
        newUser.stats = stats
        stats.owningUser = newUser  // Changed from stats.user to stats.owningUser
        
        // Guardar en la base de datos
        modelContext.insert(newUser)
        modelContext.insert(stats)
        
        do {
            try modelContext.save()
            
            // Guardar ID de usuario en Keychain
            guard let userIDData = newUser.id.data(using: .utf8) else {
                // Manejar error si no se puede convertir el ID a Data
                throw AuthError.keychainError("Failed to encode user ID")
            }
            do {
                try KeychainManager.save(service: keychainService, account: keychainAccount, password: userIDData)
            } catch KeychainManager.KeychainError.duplicateEntry {
                // Si ya existe (poco probable, pero por si acaso), intentar actualizar
                try KeychainManager.update(service: keychainService, account: keychainAccount, password: userIDData)
            } catch {
                // Si falla el guardado en Keychain, podríamos hacer rollback de la BD
                modelContext.rollback()
                throw AuthError.keychainError("Failed to save user ID to Keychain after registration: \(error.localizedDescription)")
            }
            
            return newUser
        } catch {
            modelContext.rollback()
            // Si el error no fue de Keychain, relanzarlo
            if !(error is AuthError && String(describing: error).contains("keychainError")) {
                 throw AuthError.registrationFailed(error.localizedDescription)
            } else {
                // Si fue error de Keychain
                throw error
            }
        }
    }
    
    func getCurrentUser() async throws -> UserModel? {
        var userIDData: Data
        do {
            userIDData = try KeychainManager.get(service: keychainService, account: keychainAccount)
        } catch KeychainManager.KeychainError.notFound {
            return nil // No hay usuario logueado - esto no es un error
        } catch {
            throw AuthError.keychainError("Failed to get user ID from Keychain: \(error.localizedDescription)")
        }
        
        guard let userID = String(data: userIDData, encoding: .utf8) else {
            // Manejar error si no se puede decodificar el ID
            try? KeychainManager.delete(service: keychainService, account: keychainAccount)
            throw AuthError.keychainError("Failed to decode user ID from Keychain data")
        }
        
        let predicate = #Predicate<UserModel> { $0.id == userID }
        let descriptor = FetchDescriptor<UserModel>(predicate: predicate)
        
        let users = try modelContext.fetch(descriptor)
        guard let user = users.first else {
            // El ID estaba en Keychain pero no en la BD. Limpiar Keychain.
            try? KeychainManager.delete(service: keychainService, account: keychainAccount)
            return nil
        }
        return user
    }
    
    func logout() async throws {
        do {
            try KeychainManager.delete(service: keychainService, account: keychainAccount)
        } catch KeychainManager.KeychainError.notFound {
            // No hacer nada si no se encuentra, ya está deslogueado
        } catch {
            throw AuthError.keychainError("Failed to delete user ID from Keychain: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Métodos de seguridad para contraseñas (sin cambios)
    
    private func hashPassword(_ password: String) throws -> String {
        let salt = generateSalt()
        let saltedPassword = password + salt
        
        guard let data = saltedPassword.data(using: .utf8) else {
            throw AuthError.hashingFailed
        }
        
        let hashed = SHA256.hash(data: data)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        // Formato: hash:salt
        return "\(hashString):\(salt)"
    }
    
    private func verifyPassword(_ password: String, hashedPassword: String) throws -> Bool {
        let components = hashedPassword.split(separator: ":")
        guard components.count == 2 else {
            throw AuthError.invalidPasswordFormat
        }
        
        let salt = String(components[1])
        let saltedPassword = password + salt
        
        guard let data = saltedPassword.data(using: .utf8) else {
            throw AuthError.hashingFailed
        }
        
        let hashed = SHA256.hash(data: data)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString == String(components[0])
    }
    
    private func generateSalt(length: Int = 16) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    func updateProfile(username: String, bio: String, imageData: Data? = nil) async throws -> UserModel {
        // Get the current user first
        guard let user = try await getCurrentUser() else {
            throw AuthError.notAuthenticated
        }
        
        // Update user properties
        user.username = username
        user.bio = bio
        
        // Handle profile image if provided
        if let imageData = imageData {   
            // For now, let's assume we're just storing the image locally
            let fileName = "\(user.id)_profile.jpg"
            let fileURL = try await saveImageLocally(imageData: imageData, fileName: fileName)
            user.profileImageUrl = fileURL.absoluteString
        }
        
        // Save changes to the database
        do {
            try modelContext.save()
            return user
        } catch {
            throw AuthError.updateFailed(error.localizedDescription)
        }
    }
    
    private func saveImageLocally(imageData: Data, fileName: String) async throws -> URL {
        // Get the documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Write the image data to the file
        try imageData.write(to: fileURL)
        return fileURL
    }
}

// Errores específicos de autenticación
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case registrationFailed(String)
    case userNotFound
    case hashingFailed
    case invalidPasswordFormat
    case keychainError(String)
    case notAuthenticated
    case updateFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .emailAlreadyExists:
            return "Este email ya está registrado"
        case .registrationFailed(let reason):
            return "Error al registrar: \(reason)"
        case .userNotFound:
            return "Usuario no encontrado"
        case .hashingFailed:
            return "Error al procesar la contraseña"
        case .invalidPasswordFormat:
            return "Formato de contraseña inválido"
        case .keychainError(let reason):
            return "Error de Keychain: \(reason)"
        case .notAuthenticated:
            return "User not authenticated"
        case .updateFailed(let reason):
            return "Failed to update profile: \(reason)"
        }
    }
}
