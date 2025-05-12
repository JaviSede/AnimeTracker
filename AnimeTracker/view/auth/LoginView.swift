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
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.0, blue: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo mejorado
                    VStack(spacing: 15) {
                        ZStack {
                            // Círculo exterior
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.7)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            // Círculo interior con efecto de brillo
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            // Texto "AT" con estilo mejorado
                            Text("AT")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                        
                        // Título con estilo mejorado
                        Text("AnimeTracker")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        
                        Text("Seguimiento de tu anime")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // Campos de texto con diseño mejorado
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            TextField("Correo electrónico", text: $email)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )

                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            SecureField("Contraseña", text: $password)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 30)

                    // Botón de inicio de sesión con efecto de sombra
                    Button(action: {
                        if email.isEmpty || password.isEmpty {
                            alertMessage = "Por favor, introduce correo y contraseña"
                            showAlert = true
                        } else {
                            authService.login(email: email, password: password)
                        }
                    }) {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity, minHeight: 55)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: Color.purple.opacity(0.5), radius: 5, x: 0, y: 3)
                        } else {
                            Text("Iniciar Sesión")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 55)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .shadow(color: Color.purple.opacity(0.5), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 30)
                    .disabled(authService.isLoading)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                    // Mensaje de error con estilo mejorado
                    if let errorMessage = authService.error {
                        Text(errorMessage)
                            .foregroundColor(.red.opacity(0.8))
                            .font(.system(size: 14))
                            .padding(.horizontal, 30)
                            .padding(.top, -10)
                    }

                    // Enlaces para crear cuenta y recuperar contraseña con diseño mejorado
                    HStack {
                        Button(action: {
                            showingRegistration = true
                        }) {
                            Text("Crear Cuenta")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Acción para recuperar contraseña
                            alertMessage = "¡Recuperación de contraseña próximamente!"
                            showAlert = true
                        }) {
                            Text("¿Olvidaste tu Contraseña?")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.purple.opacity(0.9))
                                .underline()
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
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