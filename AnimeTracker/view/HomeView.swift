//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct NavigationHome: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var animeService: AnimeService
    @EnvironmentObject var userLibrary: UserLibrary
    @State private var selectedTab = 0
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(showSettings: $showingSettings, switchToProfileTab: {
                    selectedTab = 3
                })
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    .environmentObject(animeService)
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)
                    .environmentObject(animeService)
                
                LibraryView()
                    .tabItem {
                        Image(systemName: "books.vertical.fill")
                        Text("Library")
                    }
                    .tag(2)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(3)
                    // Remove or replace the environmentObject modifier
                    // .environmentObject(appState)
            }
            .accentColor(.purple)
            .toolbarBackground(.black, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
        }
        // En la parte donde se muestra la hoja de configuración
        .sheet(isPresented: $showingSettings) {
        //    SettingsView(isDarkMode: $isDarkMode)
        }
        .onAppear {
            animeService.loadAllData()
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var animeService: AnimeService
    @EnvironmentObject var userLibrary: UserLibrary
    @Binding var showSettings: Bool
    @AppStorage("isDarkMode") private var isDarkMode = true
    var switchToProfileTab: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Cambiar de color fijo a condicional
                Color(isDarkMode ? .black : .white)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Currently Watching Section
                        Text("Currently Watching")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(.horizontal)
                        
                        currentlyWatchingSection
                        
                        // Recommended For You Section
                        Text("Recommended For You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(.horizontal)
                        
                        recommendedSection
                        
                        // Popular Now Section
                        Text("Popular Now")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding(.horizontal)
                        
                        popularSection
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Home")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var currentlyWatchingSection: some View {
        Group {
            if animeService.isLoading && userLibrary.fetchSavedAnimes().isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                    .frame(maxWidth: .infinity)
            } else {
                let watchingAnimes = userLibrary.fetchSavedAnimes().filter { $0.status == .watching }
                
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
    
    private func currentlyWatchingItem(savedAnime: SavedAnimeModel) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: savedAnime.id)) {
            HStack(spacing: 15) {
                animeImageView(imageURL: savedAnime.imageUrl ?? "", width: 100, height: 150)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(savedAnime.title)
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .lineLimit(2)
                    
                    Text(savedAnime.status.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                    
                    if let totalEpisodes = savedAnime.totalEpisodes, totalEpisodes > 0 {
                        Text("Episode \(savedAnime.currentEpisode)/\(totalEpisodes)")
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
    
    @ViewBuilder
    private var recommendedSection: some View {
        if animeService.isLoading && animeService.recommendedAnime.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .frame(maxWidth: .infinity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(animeService.recommendedAnime) { anime in
                        animeCard(anime: anime)
                            .onAppear {
                                prefetchNextImages(currentIndex: animeService.recommendedAnime.firstIndex(of: anime) ?? 0, 
                                                   in: animeService.recommendedAnime)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var popularSection: some View {
        if animeService.isLoading && animeService.popularAnime.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                .frame(maxWidth: .infinity)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(animeService.popularAnime) { anime in
                        animeCard(anime: anime)
                            .onAppear {
                                prefetchNextImages(currentIndex: animeService.popularAnime.firstIndex(of: anime) ?? 0, 
                                                   in: animeService.popularAnime)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    
    // Función para precargar las próximas imágenes
    private func prefetchNextImages(currentIndex: Int, in animes: [AnimePreview]) {
        // Precargar las próximas 3 imágenes para mejorar la experiencia de desplazamiento
        let prefetchCount = 3
        let nextIndices = (1...prefetchCount).map { currentIndex + $0 }
        
        for index in nextIndices {
            if index < animes.count {
                let imageURL = animes[index].images.jpg.image_url
                if let url = URL(string: imageURL) {
                    // Iniciar la descarga en segundo plano
                    URLSession.shared.dataTask(with: url) { _, _, _ in }.resume()
                }
            }
        }
    }
    
    private func animeCard(anime: AnimePreview) -> some View {
        NavigationLink {
            AnimeDetailView(animeID: anime.mal_id)
        } label: {
            VStack(spacing: 5) {
                AsyncImage(url: URL(string: anime.images.jpg.image_url), transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 160)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                                    .scaleEffect(0.7)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 160)
                            .cornerRadius(10)
                            .clipped()
                            .transition(.opacity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isDarkMode ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    case .failure:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 160)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .layoutPriority(1)
                .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.1), radius: 3, x: 0, y: 2)
                
                Text(anime.title)
                    .font(.caption)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(1)
                    .frame(width: 120)
                    .truncationMode(.tail)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func animeImageView(imageURL: String, width: CGFloat, height: CGFloat) -> some View {
        AsyncImage(url: URL(string: imageURL), transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                // Mostrar un placeholder con dimensiones exactas mientras carga
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                            .scaleEffect(0.7)
                    )
                    .transition(.opacity)
            case .success(let image):
                // Aplicar transición suave cuando la imagen carga exitosamente
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .cornerRadius(10)
                    .clipped()
                    .transition(.opacity)
                    .background(Color.black.opacity(0.1)) // Fondo sutil para imágenes con transparencia
            case .failure:
                // Mostrar un placeholder de error con ícono
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
                    .transition(.opacity)
            @unknown default:
                EmptyView()
            }
        }
        // Aplicar prioridad alta para la carga de imágenes visibles
        .layoutPriority(1)
        // Añadir sombra sutil para mejorar la apariencia
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}
