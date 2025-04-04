//
//  LoginView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo negro
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Icono circular con texto "AT"
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("AT")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    // Título "AnimeTracker"
                    Text("AnimeTracker")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your anime journey")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Campos de texto para email y contraseña
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 40)

                    // Botón de inicio de sesión
                    Button(action: {
                        if email.isEmpty || password.isEmpty {
                            alertMessage = "Please enter both email and password"
                            showAlert = true
                        } else {
                            authService.login(email: email, password: password)
                        }
                    }) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            Text("Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 40)
                    .disabled(authService.isLoading)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                    // Show error message from AuthService if present
                    if let errorMessage = authService.error {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal, 40)
                    }

                    #if DEBUG
                    // Debug button - only for development
                    Button(action: {
                        // Force login for debugging
                        let user = User(
                            id: UUID().uuidString,
                            username: "TestUser",
                            email: "test@example.com",
                            profileImageUrl: nil,
                            bio: "Test bio",
                            joinDate: Date(),
                            animeStats: User.AnimeStats()
                        )
                        authService.currentUser = user
                        authService.isAuthenticated = true
                        authService.isLoading = false
                    }) {
                        Text("Debug: Force Login")
                            .font(.caption)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.top, 20)
                    #endif

                    // Enlaces para crear cuenta y recuperar contraseña
                    HStack {
                        Button(action: {
                            showingRegistration = true
                        }) {
                            Text("Create Account")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Acción para recuperar contraseña
                            alertMessage = "Password recovery feature coming soon!"
                            showAlert = true
                        }) {
                            Text("Forgot Password?")
                                .font(.footnote)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.vertical, 30)
            }
            .navigationDestination(isPresented: $showingRegistration) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthService())
}