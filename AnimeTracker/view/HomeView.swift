//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct NavigationHome: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeService: AnimeService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .environmentObject(animeService)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .environmentObject(animeService)
            
            LibraryView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Library")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .environmentObject(appState)
        }
        .accentColor(.purple)
        .toolbarBackground(.black, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            animeService.loadAllData()
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var animeService: AnimeService
    @EnvironmentObject var userLibrary: UserLibrary
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Currently Watching Section
                        Text("Currently Watching")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        currentlyWatchingSection
                        
                        // Recommended For You Section
                        Text("Recommended For You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        recommendedSection
                        
                        // Popular Now Section
                        Text("Popular Now")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        popularSection
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.purple)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var currentlyWatchingSection: some View {
        Group {
            if animeService.isLoading && userLibrary.savedAnimes.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .frame(maxWidth: .infinity)
            } else {
                let watchingAnimes = userLibrary.savedAnimes.filter { $0.status == .watching }
                
                if let firstAnime = watchingAnimes.first {
                    currentlyWatchingItem(savedAnime: firstAnime)
                } else {
                    Text("No anime in your watching list")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
    }
    
    private func currentlyWatchingItem(savedAnime: SavedAnime) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: savedAnime.id)) {
            HStack(spacing: 15) {
                animeImageView(imageURL: savedAnime.imageUrl, width: 100, height: 150)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(savedAnime.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(savedAnime.status.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    
                    if savedAnime.totalEpisodes > 0 {
                        Text("Episode \(savedAnime.currentEpisode)/\(savedAnime.totalEpisodes)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Episode \(savedAnime.currentEpisode)/Unknown")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Incrementar el episodio actual
                        let newEpisode = savedAnime.currentEpisode + 1
                        userLibrary.updateAnime(id: savedAnime.id, currentEpisode: newEpisode)
                    }) {
                        Text("Continue")
                            .fontWeight(.bold)
                            .frame(width: 100, height: 40)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var recommendedSection: some View {
        Group {
            if animeService.isLoading && animeService.recommendedAnime.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(animeService.recommendedAnime) { anime in
                            animeCard(anime: anime)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var popularSection: some View {
        Group {
            if animeService.isLoading && animeService.popularAnime.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(animeService.popularAnime) { anime in
                            animeCard(anime: anime)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func animeCard(anime: AnimePreview) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: anime.mal_id)) {
            VStack(spacing: 5) {
                animeImageView(imageURL: anime.images.jpg.image_url, width: 120, height: 160)
                
                Text(anime.title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 120)
                    .truncationMode(.tail)
            }
        }
    }
    
    private func animeImageView(imageURL: String, width: CGFloat, height: CGFloat) -> some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .cornerRadius(10)
            } else if phase.error != nil {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    )
            }
        }
    }
}

#Preview {
    NavigationHome()
        .environmentObject(AppState())
        .environmentObject(AnimeService())
        .environmentObject(UserLibrary())
}
