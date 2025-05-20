//
//  AuthService.swift
//  AnimeTracker
//

import Foundation
import SwiftUI
import SwiftData
import Combine

class AuthService: ObservableObject {
    // Estado publicado
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentUser: UserModel?

    // Dependencias
    private var repository: AuthRepositoryProtocol?
    private var cancellables = Set<AnyCancellable>()

    // Validadores
    private let credentialsValidator = CredentialsValidator()
    private let registrationValidator = RegistrationValidator()


    init() {}

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
                    self.error = error.localizedDescription
                    self.currentUser = nil
                    self.isAuthenticated = false
                    self.isLoading = false
                }
            }
        }
    }

    func logout() {
        guard let repository = repository else {
            print("AuthService: Repository not available for logout.")
            return
        }

        isLoading = true
        error = nil

        Task {
            do {
                try await repository.logout()
                await MainActor.run {
                    self.currentUser = nil
                    self.isAuthenticated = false
                    self.isLoading = false
                    self.error = nil
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
                    // Force logout state for consistency:
                    self.currentUser = nil
                    self.isAuthenticated = false
                    print("AuthService: Forced logout state due to error.") // Debug log
                }
            }
        }
    }
    
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
            throw error
        }
    }
}

