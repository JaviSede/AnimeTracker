//
//  AuthService.swift
//  AnimeTracker
//

import Foundation
import SwiftUI
import SwiftData
import Combine

// Assuming UserModel is defined elsewhere, likely in the Models group
// If not, this needs to be defined or imported.
// For now, I'll assume it exists.

class AuthService: ObservableObject {
    // Estado publicado
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentUser: UserModel? // <-- Added missing property

    // Dependencias
    private var repository: AuthRepositoryProtocol?
    private var cancellables = Set<AnyCancellable>()

    // Validadores - Assuming these exist and are correctly implemented
    private let credentialsValidator = CredentialsValidator()
    private let registrationValidator = RegistrationValidator()


    init() {}

    // Need to ensure UserModel is available in this scope.
    // It might require an import or definition.
    // Let's assume it's available via SwiftData import or similar.

    func setModelContext(_ context: ModelContext) {
        self.repository = AuthRepository(modelContext: context)
        loadCurrentUser() // Load user when context is set
    }

    func loadCurrentUser() {
        guard let repository = repository else {
            print("AuthService: Repository not available yet for loading user.")
            return
        }
    
        isLoading = true
        error = nil
    
        Task {
            do {
                // Intenta obtener el usuario actual
                let user = try await repository.getCurrentUser()
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = (user != nil)
                    self.isLoading = false
                    self.error = nil
                    print("AuthService: Current user loaded: \(user?.email ?? "None")")
                }
            } catch {
                await MainActor.run {
                    // Registra el error para depuración
                    print("AuthService: Failed to load current user - Error: \(error)")
                    
                    // Importante: No mostrar el error de Keychain al usuario cuando es la primera vez
                    // que abre la app o no hay usuario conectado
                    if error.localizedDescription.contains("keychain") || 
                       error.localizedDescription.contains("Keychain") {
                        // Silenciar este error específico - es normal cuando no hay usuario
                        self.error = nil
                    } else {
                        self.error = "Error al cargar usuario: \(error.localizedDescription)"
                    }
                    
                    self.currentUser = nil
                    self.isAuthenticated = false
                    self.isLoading = false
                }
            }
        }
    }

    func login(email: String, password: String) {
        guard let repository = repository else {
            self.error = "Servicio no disponible. Intenta más tarde."
            return
        }

        // Assuming Credentials and CredentialsValidator exist and work
        let credentials = Credentials(email: email, password: password)
        let validationResult = credentialsValidator.validate(credentials)

        if !validationResult.isValid {
            // Use the first validation error message
            self.error = validationResult.errors.first?.localizedDescription ?? "Datos inválidos."
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                let user = try await repository.login(email: email, password: password)
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                    self.error = nil // Clear error on success
                    print("AuthService: Login successful for user: \(user.email)") // Debug log
                }
            } catch {
                await MainActor.run {
                    print("AuthService: Login failed - Error: \(error)") // Debug log
                    // Use localized description from AuthError enum
                    self.error = error.localizedDescription
                    self.currentUser = nil // Ensure user is nil on error
                    self.isAuthenticated = false
                    self.isLoading = false
                }
            }
        }
    }

    func register(username: String, email: String, password: String, confirmPassword: String = "") {
         guard let repository = repository else {
            self.error = "Servicio no disponible. Intenta más tarde."
            return
        }

        // Assuming RegistrationData and RegistrationValidator exist and work
        let registrationData = RegistrationData(
            username: username,
            email: email,
            password: password,
            // Use confirmPassword if provided, otherwise assume password is confirmed
            confirmPassword: confirmPassword.isEmpty ? password : confirmPassword
        )

        let validationResult = registrationValidator.validate(registrationData)

        if !validationResult.isValid {
             // Use the first validation error message
            self.error = validationResult.errors.first?.localizedDescription ?? "Datos de registro inválidos."
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                let user = try await repository.register(
                    username: username,
                    email: email,
                    password: password
                )

                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                    self.error = nil // Clear error on success
                    print("AuthService: Registration successful for user: \(user.email)") // Debug log
                }
            } catch {
                await MainActor.run {
                    print("AuthService: Registration failed - Error: \(error)") // Debug log
                     // Use localized description from AuthError enum
                    self.error = error.localizedDescription
                    self.currentUser = nil // Ensure user is nil on error
                    self.isAuthenticated = false // Should remain false on registration failure
                    self.isLoading = false
                }
            }
        }
    }

    func logout() {
        guard let repository = repository else {
            // Maybe set an error if repository is nil?
            print("AuthService: Repository not available for logout.")
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                try await repository.logout()
                await MainActor.run {
                    self.currentUser = nil // Clear current user on logout
                    self.isAuthenticated = false
                    self.isLoading = false
                    self.error = nil // Clear error on successful logout
                    print("AuthService: Logout successful.") // Debug log
                }
            } catch {
                await MainActor.run {
                    print("AuthService: Logout failed - Error: \(error)") // Debug log
                    // Display specific Keychain error if available
                    if let authError = error as? AuthError, case .keychainError(let reason) = authError {
                        self.error = "Error de Keychain al cerrar sesión: \(reason)"
                    } else {
                        self.error = "Error al cerrar sesión: \(error.localizedDescription)"
                    }
                    // Keep isLoading false, but indicate the error.
                    self.isLoading = false
                    // Decide if isAuthenticated should change on logout failure.
                    // Current logic keeps the user potentially logged in (isAuthenticated might stay true).
                    // It might be safer to force logout state:
                    // self.currentUser = nil
                    // self.isAuthenticated = false
                    // Let's force logout state for consistency:
                    self.currentUser = nil
                    self.isAuthenticated = false
                    print("AuthService: Forced logout state due to error.") // Debug log
                }
            }
        }
    }

    // Placeholder for other methods if needed
    // func updateProfile(...) { ... }
    
    func updateProfile(username: String, bio: String, imageData: Data? = nil) async throws {
        guard let repository = repository else {
            throw NSError(domain: "AuthService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Repository not available"])
        }
        
        isLoading = true
        error = nil
        
        do {
            // Assuming repository has an updateProfile method
            let updatedUser = try await repository.updateProfile(username: username, bio: bio, imageData: imageData)
            
            await MainActor.run {
                self.currentUser = updatedUser
                self.isLoading = false
                print("AuthService: Profile updated successfully for user: \(updatedUser.email)")
            }
        } catch {
            await MainActor.run {
                print("AuthService: Profile update failed - Error: \(error)")
                self.error = "Failed to update profile: \(error.localizedDescription)"
                self.isLoading = false
            }
            throw error // Re-throw outside the MainActor.run block
        }
    }
}

// Need definitions for UserModel, Credentials, CredentialsValidator, RegistrationData, RegistrationValidator
// Assuming they exist in the project structure. For example:
/*
 struct Credentials {
     let email: String
     let password: String
 }

 struct RegistrationData {
     let username: String
     let email: String
     let password: String
     let confirmPassword: String
 }

 struct ValidationResult {
     let isValid: Bool
     let errors: [Error] // Or specific validation error types
 }

 protocol Validator {
     associatedtype InputType
     func validate(_ input: InputType) -> ValidationResult
 }

 class CredentialsValidator: Validator {
     typealias InputType = Credentials
     func validate(_ input: Credentials) -> ValidationResult {
         // Basic validation logic (e.g., non-empty, email format)
         var errors: [Error] = []
         if input.email.isEmpty || !input.email.contains("@") { // Very basic email check
             errors.append(AuthError.invalidCredentials) // Or a specific validation error
         }
         if input.password.isEmpty {
              errors.append(AuthError.invalidCredentials) // Or a specific validation error
         }
         return ValidationResult(isValid: errors.isEmpty, errors: errors)
     }
 }

 class RegistrationValidator: Validator {
      typealias InputType = RegistrationData
      func validate(_ input: RegistrationData) -> ValidationResult {
          // Basic validation logic (e.g., non-empty, email format, password match)
          var errors: [Error] = []
          if input.username.isEmpty { errors.append(AuthError.registrationFailed("Username required")) }
          if input.email.isEmpty || !input.email.contains("@") { errors.append(AuthError.registrationFailed("Invalid email")) }
          if input.password.isEmpty { errors.append(AuthError.registrationFailed("Password required")) }
          if input.password != input.confirmPassword { errors.append(AuthError.registrationFailed("Passwords do not match")) }
          // Add password complexity rules if needed
          return ValidationResult(isValid: errors.isEmpty, errors: errors)
      }
 }
 */
// Also need UserModel definition, likely a SwiftData @Model class.
/*
 @Model
 final class UserModel {
     @Attribute(.unique) var id: String
     var username: String
     var email: String
     var password: String // Hashed password
     // ... other properties like profileImageUrl, bio, joinDate
     @Relationship(deleteRule: .cascade, inverse: \AnimeStats.user) var stats: AnimeStats?

     init(id: String = UUID().uuidString, username: String, email: String, password: String, /* other params */ stats: AnimeStats? = nil) {
         self.id = id
         self.username = username
         self.email = email
         self.password = password
         // ... initialize other properties
         self.stats = stats
     }
 }

 @Model
 final class AnimeStats {
     // ... stats properties
     var user: UserModel? // Inverse relationship
     init() { /* ... */ }
 }
 */

// AuthError enum should also be accessible, likely defined in AuthRepository.swift or a shared file.

