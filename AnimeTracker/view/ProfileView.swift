//
//  ProfileView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//  Updated by Manus on 29/4/25.
//

import SwiftUI
import SwiftData // Needed if interacting directly with models here

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    // Removed UserLibrary dependency as stats will be fetched from UserModel
    // @EnvironmentObject var userLibrary: UserLibrary
    @State private var showingEditProfile = false
    @State private var showingLoginView = false // Keep for logged-out state

    // Computed property for the current user
    private var user: UserModel? {
        authService.currentUser
    }

    // Computed property for user stats
    private var stats: AnimeStats? {
        user?.stats
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Use a gradient background for a more modern feel
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if authService.isAuthenticated, let user = user {
                    // Main content scroll view
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            // --- Profile Header --- 
                            ProfileHeaderView(user: user)
                            
                            // --- Anime Stats Section --- 
                            // Pass the stats object directly
                            if let stats = stats {
                                AnimeStatsSectionView(stats: stats)
                            } else {
                                // Placeholder or loading view for stats
                                Text("Loading stats...")
                                    .foregroundColor(.gray)
                                    .padding()
                            }

                            // --- Profile Options Section ---
                            ProfileOptionsSectionView(showingEditProfile: $showingEditProfile)
                        }
                        .padding(.vertical) // Add padding top and bottom of VStack
                    }
                } else {
                    // --- Logged Out View ---
                    LoggedOutView(showingLoginView: $showingLoginView)
                }
            }
            .navigationTitle(user?.username ?? "Profile") // Dynamic title
            .navigationBarTitleDisplayMode(.inline) // More compact nav bar
            .toolbarColorScheme(.dark, for: .navigationBar) // Ensure nav bar items are visible
            .toolbarBackground(Color.black.opacity(0.5), for: .navigationBar) // Semi-transparent black
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingEditProfile) {
                // Present EditProfileView when showingEditProfile is true
                // Ensure EditProfileView also gets necessary environment objects if needed
                EditProfileView()
                    .environmentObject(authService)
            }
        }
        // Ensure environment objects are available if needed by subviews
        // .environmentObject(authService) // Already available from parent
    }
}

// MARK: - Subviews for ProfileView

// --- Profile Header View ---
struct ProfileHeaderView: View {
    let user: UserModel

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
                .foregroundColor(.white)

            // Bio
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Join Date
            Text("Member since \(user.joinDate, style: .date)")
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
            .foregroundColor(.white.opacity(0.7))
            .padding(30)
            .background(Color.gray.opacity(0.3))
            .clipShape(Circle())
    }
}

// --- Anime Stats Section View ---
struct AnimeStatsSectionView: View {
    let stats: AnimeStats

    // Define grid layout: 3 columns, flexible width
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Anime Statistics")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            // Use LazyVGrid for a flexible grid layout
            LazyVGrid(columns: columns, spacing: 20) {
                StatItemView(title: "Watching", value: stats.watching, color: AnimeStatus.watching.color)
                StatItemView(title: "Completed", value: stats.completed, color: AnimeStatus.completed.color)
                StatItemView(title: "On Hold", value: stats.onHold, color: AnimeStatus.onHold.color)
                StatItemView(title: "Dropped", value: stats.dropped, color: AnimeStatus.dropped.color)
                StatItemView(title: "Plan to Watch", value: stats.planToWatch, color: AnimeStatus.planToWatch.color)
                StatItemView(title: "Total Anime", value: stats.totalAnime, color: .white)
            }
            .padding(.horizontal)

            Divider().background(Color.gray.opacity(0.5)).padding(.horizontal)

            // Summary Stats (Episodes, Days Watched)
            HStack {
                StatSummaryView(title: "Total Episodes Watched", value: String(stats.totalEpisodes))
                Spacer()
                StatSummaryView(title: "Days Watched", value: String(format: "%.1f", stats.daysWatched))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .padding(.horizontal) // Add horizontal padding to the section card
    }
}

// --- Stat Item View (for the grid) ---
struct StatItemView: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 0, maxWidth: .infinity) // Ensure items fill width
    }
}

// --- Stat Summary View (for Episodes/Days) ---
struct StatSummaryView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

// --- Profile Options Section View ---
struct ProfileOptionsSectionView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var showingEditProfile: Bool

    var body: some View {
        VStack(spacing: 10) {
            OptionButton(title: "Edit Profile", icon: "pencil") {
                showingEditProfile = true
            }
            
            OptionButton(title: "Export Library", icon: "square.and.arrow.up") {
                // TODO: Implement export functionality
                print("Export Library tapped")
            }
            
            OptionButton(title: "Settings", icon: "gear") {
                // TODO: Navigate to or present settings view
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
            .background(Color.black.opacity(0.2))
            .foregroundColor(role == .destructive ? .red : .white)
            .cornerRadius(10)
        }
    }
}

// --- Logged Out View ---
struct LoggedOutView: View {
    @Binding var showingLoginView: Bool

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.xmark")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("Not Logged In")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Log in or sign up to track your anime and manage your profile.")
                .font(.body)
                .foregroundColor(.gray)
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
            // Assuming LoginView handles both login and presenting registration
            LoginView()
                // Pass necessary environment objects if LoginView needs them
                // .environmentObject(authService) // Already available
        }
    }
}

// MARK: - Helper Functions (Moved from original ProfileView)

// No longer needed here as stats come from AnimeStats model
// private func calculateTotalEpisodes() -> Int { ... }
// private func calculateDaysWatched() -> Double { ... }

// Date formatting is handled inline now with `style: .date`
// private func formattedDate(_ date: Date) -> String { ... }

// Stat view is replaced by StatItemView and StatSummaryView
// private func statView(title: String, value: String) -> some View { ... }

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
            // Provide a dummy ModelContainer for preview if needed by subviews
            // .modelContainer(for: [UserModel.self, AnimeStats.self], inMemory: true)
            .preferredColorScheme(.dark)
    }
}

