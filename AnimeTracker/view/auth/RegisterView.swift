//
//  RegisterView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    
    var body: some View {
        ZStack {
            // Fondo con gradiente adaptado al modo claro/oscuro
            LinearGradient(
                gradient: Gradient(colors: isDarkMode ? 
                                  [Color.black, Color(red: 0.1, green: 0.0, blue: 0.2)] : 
                                  [Color.white, Color(red: 0.9, green: 0.9, blue: 1.0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Logo
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
                            
                            // Círculo interior
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            // Texto "AT"
                            Text("AT")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                        
                        // Título
                        Text("Crear Cuenta")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                    
                    // Campos de texto
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            TextField("Nombre de usuario", text: $username)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            TextField("Correo electrónico", text: $email)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
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
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                        )
                        
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.purple)
                                .frame(width: 30)
                            
                            SecureField("Confirmar Contraseña", text: $confirmPassword)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .onChange(of: confirmPassword) { _, newValue in
                                    passwordsMatch = password == newValue || newValue.isEmpty
                                }
                        }
                        .padding()
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(passwordsMatch ? Color.purple.opacity(0.5) : Color.red.opacity(0.7), lineWidth: 1)
                        )
                        
                        if !passwordsMatch {
                            Text("Las contraseñas no coinciden")
                                .foregroundColor(.red.opacity(0.8))
                                .font(.system(size: 14))
                                .padding(.top, -10)
                        }
                        
                        if let error = authService.error {
                            Text(error)
                                .foregroundColor(.red.opacity(0.8))
                                .font(.system(size: 14))
                                .padding(.top, -10)
                        }
                        
                        // Botón de registro
                        Button(action: {
                            if password == confirmPassword {
                                authService.register(username: username, email: email, password: password)
                            } else {
                                passwordsMatch = false
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
                                Text("Registrarse")
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
                        .disabled(authService.isLoading || username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || !passwordsMatch)
                        
                        // Enlace para volver a iniciar sesión
                        Button(action: {
                            dismiss()
                        }) {
                            Text("¿Ya tienes una cuenta? Inicia sesión")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(isDarkMode ? .purple.opacity(0.9) : .purple)
                                .underline()
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.purple)
                        .font(.system(size: 16, weight: .bold))
                        .padding(8)
                        .background(isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }
        }
    }
}

#Preview {
    RegisterView().environmentObject(AuthService())
}