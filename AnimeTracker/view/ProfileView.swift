//
//  ProfileView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var userLibrary: UserLibrary
    @State private var showingEditProfile = false
    @State private var showingLoginView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if authService.isAuthenticated, let user = authService.currentUser {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Cabecera de perfil
                            VStack(spacing: 15) {
                                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 100, height: 100)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        case .failure:
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 100, height: 100)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 40))
                                                )
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 40))
                                        )
                                }
                                
                                Text(user.username)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if let bio = user.bio {
                                    Text(bio)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                
                                Text("Member since \(formattedDate(user.joinDate))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            
                            // Estadísticas de anime
                            VStack(spacing: 15) {
                                Text("Anime Stats")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 20) {
                                    statView(title: "Total", value: String(userLibrary.savedAnimes.count))
                                    statView(title: "Watching", value: String(userLibrary.savedAnimes.filter { $0.status == .watching }.count))
                                    statView(title: "Completed", value: String(userLibrary.savedAnimes.filter { $0.status == .completed }.count))
                                }
                                
                                HStack(spacing: 20) {
                                    statView(title: "Plan to Watch", value: String(userLibrary.savedAnimes.filter { $0.status == .planToWatch }.count))
                                    statView(title: "On Hold", value: String(userLibrary.savedAnimes.filter { $0.status == .onHold }.count))
                                    statView(title: "Dropped", value: String(userLibrary.savedAnimes.filter { $0.status == .dropped }.count))
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.vertical, 10)
                                
                                HStack(spacing: 20) {
                                    statView(title: "Episodes", value: String(calculateTotalEpisodes()))
                                    statView(title: "Days Watched", value: String(format: "%.1f", calculateDaysWatched()))
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Opciones de perfil
                            VStack(spacing: 5) {
                                Button(action: {
                                    showingEditProfile = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Profile")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    // Implementar exportación de datos
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Export Library")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    authService.logout()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.square")
                                        Text("Logout")
                                        Spacer()
                                    }
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 30)
                    }
                    .sheet(isPresented: $showingEditProfile) {
                        EditProfileView()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("Not Logged In")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Login to track your anime and access your profile")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showingLoginView = true
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .fullScreenCover(isPresented: $showingLoginView) {
                        LoginView()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func calculateTotalEpisodes() -> Int {
        return userLibrary.savedAnimes.reduce(0) { $0 + $1.currentEpisode }
    }
    
    private func calculateDaysWatched() -> Double {
        // Asumiendo un promedio de 24 minutos por episodio
        let totalMinutes = Double(calculateTotalEpisodes()) * 24.0
        return totalMinutes / (60.0 * 24.0) // Convertir a días
    }
}

