//
//  ProfileView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//  Updated by Manus on 29/4/25.
//

import SwiftUI
import SwiftData // Necesario si interactúas directamente con modelos aquí

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var showingEditProfile = false
    @State private var showingLoginView = false // Mantener para el estado de desconexión

    // Propiedad calculada para el usuario actual
    private var user: UserModel? {
        authService.currentUser
    }

    // Propiedad calculada para las estadísticas del usuario
    private var stats: AnimeStats? {
        user?.stats
    }

    var body: some View {
        // Eliminar NavigationStack si ya está dentro de un TabView con NavigationStack
        ZStack {
            // Cambiar el fondo para que se adapte al modo claro/oscuro
            LinearGradient(gradient: Gradient(colors: [
                isDarkMode ? Color.purple.opacity(0.3) : Color.purple.opacity(0.1),
                isDarkMode ? Color.black : Color.white
            ]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            if authService.isAuthenticated, let user = user {
                // Vista de desplazamiento del contenido principal
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 30) {
                        // --- Cabecera del perfil --- 
                        ProfileHeaderView(user: user)
                        
                        // --- Sección de estadísticas de anime --- 
                        // Pasar el objeto de estadísticas directamente
                        if let stats = stats {
                            AnimeStatsSectionView(stats: stats)
                        } else {
                            // Marcador de posición o vista de carga para estadísticas
                            Text("Cargando estadísticas...")
                                .foregroundColor(.gray)
                                .padding()
                        }

                        // --- Sección de opciones de perfil ---
                        ProfileOptionsSectionView(showingEditProfile: $showingEditProfile)
                    }
                    .padding(.vertical) // Añadir relleno arriba y abajo del VStack
                }
            } else {
                // --- Vista de desconectado ---
                LoggedOutView(showingLoginView: $showingLoginView)
            }
        }
        .navigationTitle(user?.username ?? "Perfil")
        .navigationBarTitleDisplayMode(.inline) // Barra de navegación más compacta
        .toolbarColorScheme(.dark, for: .navigationBar) // Asegurar que los elementos de la barra de navegación sean visibles
        .toolbarBackground(Color.black.opacity(0.5), for: .navigationBar) // Negro semitransparente
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingEditProfile) {
            // Presentar EditProfileView cuando showingEditProfile es verdadero
            // Asegurar que EditProfileView también reciba los objetos de entorno necesarios si es necesario
            EditProfileView()
                .environmentObject(authService)
        }
    }
}

// MARK: - Subvistas para ProfileView

// --- Vista de cabecera de perfil ---
struct ProfileHeaderView: View {
    let user: UserModel
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Picture
            Group {
                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure, .empty:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.purple, lineWidth: 3))
            .shadow(radius: 5)

            // Username
            Text(user.username)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)

            // Bio
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(isDarkMode ? .gray : .secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Join Date
            Text("Miembro desde \(user.joinDate, style: .date)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.top, 20) // Add padding above the header
    }

    // Placeholder image view
    private var placeholderImage: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(isDarkMode ? .white.opacity(0.7) : .gray.opacity(0.7))
            .padding(30)
            .background(isDarkMode ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
}

// --- Anime Stats Section View ---
struct AnimeStatsSectionView: View {
    let stats: AnimeStats
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Estadísticas de Anime")
                .font(.headline)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 20) {
                StatItemView(title: "Viendo", value: stats.watching, color: AnimeStatus.watching.color)
                StatItemView(title: "Completados", value: stats.completed, color: AnimeStatus.completed.color)
                StatItemView(title: "En Pausa", value: stats.onHold, color: AnimeStatus.onHold.color)
                StatItemView(title: "Abandonados", value: stats.dropped, color: AnimeStatus.dropped.color)
                StatItemView(title: "Pendientes", value: stats.planToWatch, color: AnimeStatus.planToWatch.color)
                StatItemView(title: "Total Anime", value: stats.totalAnime, color: isDarkMode ? .white : .black)
            }
            .padding(.horizontal)

            Divider().background(Color.gray.opacity(0.5)).padding(.horizontal)

            HStack {
                StatSummaryView(title: "Total Episodios Vistos", value: String(stats.totalEpisodes))
                Spacer()
                StatSummaryView(title: "Días Vistos", value: String(format: "%.1f", stats.daysWatched))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.1), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// --- Stat Item View (for the grid) ---
struct StatItemView: View {
    let title: String
    let value: Int
    let color: Color
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(isDarkMode ? .gray : .secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity) // Ensure items fill width
    }
}

// --- Stat Summary View (for Episodes/Days) ---
struct StatSummaryView: View {
    let title: String
    let value: String
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(isDarkMode ? .gray : .secondary)
            Text(value)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(isDarkMode ? .white : .black)
        }
    }
}

// --- Profile Options Section View ---
struct ProfileOptionsSectionView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showingEditProfile: Bool
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack(spacing: 10) {
            OptionButton(title: "Editar perfil;", icon: "pencil") {
                showingEditProfile = true
            }
            
            OptionButton(title: "Exportar biblioteca", icon: "square.and.arrow.up") {
                print("Export Library tapped")
            }
            
            OptionButton(title: "Configuración", icon: "gear") {
                print("Settings tapped")
            }
            
            Divider().background(Color.gray.opacity(0.5)).padding(.horizontal)
            
            OptionButton(title: "Logout", icon: "arrow.right.square", role: .destructive) {
                authService.logout()
            }
        }
        .padding(.horizontal) // Add horizontal padding to the options section
    }
}

// --- Reusable Option Button ---
struct OptionButton: View {
    let title: String
    let icon: String
    var role: ButtonRole? = nil
    let action: () -> Void
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        Button(role: role, action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 25, alignment: .center) // Align icons
                Text(title)
                Spacer()
                if role == nil { // Don't show chevron for destructive actions
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isDarkMode ? Color.black.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(role == .destructive ? .red : (isDarkMode ? .white : .black))
            .cornerRadius(10)
        }
    }
}

// --- Logged Out View ---
struct LoggedOutView: View {
    @Binding var showingLoginView: Bool
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 80))
                .foregroundColor(isDarkMode ? .gray.opacity(0.7) : .gray.opacity(0.5))
            
            Text("No Loggeado")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text("Logueese para ver su perfil y estadísticas de anime")
                .font(.body)
                .foregroundColor(isDarkMode ? .gray : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingLoginView = true
            }) {
                Text("Login / Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
            Spacer()
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showingLoginView) {
            LoginView()
        }
    }
}

// MARK: - Preview

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Create mock data for preview
        let mockAuthService = AuthService()
        let mockUser = UserModel(username: "PreviewUser", email: "preview@example.com", password: "password")
        mockUser.bio = "This is a bio for the preview user."
        let mockStats = AnimeStats()
        mockStats.watching = 5
        mockStats.completed = 20
        mockStats.planToWatch = 10
        mockStats.totalAnime = 35
        mockStats.totalEpisodes = 350
        mockStats.daysWatched = 5.8
        mockUser.stats = mockStats
        
        // Simulate logged-in state
        mockAuthService.currentUser = mockUser
        mockAuthService.isAuthenticated = true
        
        return ProfileView()
            .environmentObject(mockAuthService)
            .preferredColorScheme(.dark)
    }
}

