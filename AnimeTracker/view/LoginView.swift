//
//  LoginView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
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
                        appState.login(email: email, password: password)
                    }
                }) {
                    if appState.isLoading {
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
                .disabled(appState.isLoading)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                // Show error message from AppState if present
                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 40)
                }

                // Debug button - only for development
            
                Button(action: {
                    // Force login for debugging
                    let user = User(id: UUID().uuidString, email: "test@example.com", username: "TestUser")
                    appState.currentUser = user
                    appState.isLoggedIn = true
                    appState.isLoading = false
                }) {
                    Text("Debug: Force Login")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.top, 20)
            

                // Enlaces para crear cuenta y recuperar contraseña
                HStack {
                    Button(action: {
                        // Acción para crear cuenta
                        alertMessage = "Create Account feature coming soon!"
                        showAlert = true
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
        }
    }
}
#Preview {
    LoginView().environmentObject(AppState())
}
