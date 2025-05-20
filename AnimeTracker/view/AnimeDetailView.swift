//
//  AnimeDetailView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct AnimeDetailView: View {
    let animeID: Int
    @EnvironmentObject var service: AnimeService
    @EnvironmentObject var userLibrary: UserLibrary
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var animeDetail: AnimePreview?
    @State private var isLoading = true
    @State private var expandSynopsis = false
    @State private var showingStatusSheet = false
    
    var body: some View {
        ScrollView {
            if isLoading {
                loadingView
            } else if let anime = animeDetail {
                animeContentView(anime: anime)
            } else {
                errorView
            }
        }
        .navigationTitle("Detalles del Anime")
        .background(Color(isDarkMode ? .black : .white).ignoresSafeArea())
        .onAppear {
            loadAnimeDetails()
        }
        .sheet(isPresented: $showingStatusSheet) {
            if let animeDetail = animeDetail {
                AnimeStatusSelectionView(animeID: animeID, animeDetail: animeDetail)
                    .environmentObject(userLibrary)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 100)
    }
    
    private var errorView: some View {
        Text("Error al cargar los detalles del anime")
            .foregroundColor(.red)
            .padding()
    }
    
    private func animeContentView(anime: AnimePreview) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image section
            animeImageView(imageURL: anime.images.jpg.large_image_url ?? anime.images.jpg.image_url)
            
            // Title and info section
            titleSection(anime: anime)
            
            // Action buttons
            actionButtonsSection()
            
            // Synopsis section
            if let synopsis = anime.synopsis {
                synopsisSection(synopsis: synopsis)
            } else {
                synopsisSection(synopsis: "No hay sinopsis disponible.")
            }
            
            // Comenta esta sección hasta que tengas la propiedad streaming
            if let streaming = anime.streaming, !streaming.isEmpty {
                streamingServicesSection(services: streaming)
            }
            
            // Episodes section
            if let episodeCount = anime.episodes {
                Text("Episodios: \(episodeCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private func animeImageView(imageURL: String) -> some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isDarkMode ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.1), radius: 3, x: 0, y: 2)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .foregroundColor(isDarkMode ? .white : .black)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    private func titleSection(anime: AnimePreview) -> some View {
        VStack(alignment: .leading) {
            // Title
            Text(anime.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)
            
            // Status and type
            if let status = anime.status {
                Text(status)
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .padding(.horizontal)
            }
            
            // Genres
            if let genres = anime.genres, !genres.isEmpty {
                HStack {
                    Text("Genres: ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ForEach(genres.prefix(3), id: \.id) { genre in
                        Text(genre.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                    
                    if genres.count > 3 {
                        Text("+\(genres.count - 3)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            
            // Rating
            if let score = anime.score {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", score))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func actionButtonsSection() -> some View {
        VStack(spacing: 15) {
            // Add to library button
            Button(action: {
                showingStatusSheet = true
            }) {
                HStack {
                    Image(systemName: userLibrary.isInLibrary(id: animeID) ? "checkmark.circle.fill" : "plus.circle")
                    Text(userLibrary.isInLibrary(id: animeID) ? "Actualizar en Biblioteca" : "Añadir a Biblioteca")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .cornerRadius(10)
            }
            
            // Quick action buttons
            HStack(spacing: 15) {
                Button(action: {
                    if let anime = animeDetail {
                        if userLibrary.isInLibrary(id: animeID) {
                            userLibrary.updateAnime(id: animeID, status: .watching)
                        } else {
                            userLibrary.addAnime(anime: anime, status: .watching)
                        }
                    }
                }) {
                    Text("Viendo")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(userLibrary.isInLibrary(id: animeID) && userLibrary.getAnimeStatus(id: animeID) == .watching ? Color.purple : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    if let anime = animeDetail {
                        if userLibrary.isInLibrary(id: animeID) {
                            userLibrary.updateAnime(id: animeID, status: .planToWatch)
                        } else {
                            userLibrary.addAnime(anime: anime, status: .planToWatch)
                        }
                    }
                }) {
                    Text("Pendiente")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(userLibrary.isInLibrary(id: animeID) && userLibrary.getAnimeStatus(id: animeID) == .planToWatch ? Color.purple : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func synopsisSection(synopsis: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sinopsis")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)
            
            Text(synopsis)
                .font(.body)
                .foregroundColor(isDarkMode ? .gray : .secondary)
                .lineLimit(expandSynopsis ? nil : 3)
                .padding(.horizontal)
            
            Button(action: {
                expandSynopsis.toggle()
            }) {
                Text(expandSynopsis ? "Mostrar Menos" : "Leer Más")
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
        }
    }
    
    private func episodesSection(episodes: [AnimeEpisode]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Episodios")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)
            
            ForEach(episodes) { episode in
                episodeRow(episode: episode)
            }
        }
    }
    
    private func episodeRow(episode: AnimeEpisode) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Episodio \(episode.number): \(episode.title)")
                    .fontWeight(.bold)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                Text("\(episode.duration)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                // Action to play episode
            }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    // MARK: - Data Loading
    
    private func loadAnimeDetails() {
        service.fetchAnimeDetails(animeID: animeID) { detail in
            DispatchQueue.main.async {
                self.animeDetail = detail
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Streaming Services
    
    private func streamingServicesSection(services: [StreamingService]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Donde Ver")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(services, id: \.name) { service in
                        Link(destination: URL(string: service.url) ?? URL(string: "https://example.com")!) {
                            VStack {
                                Text(service.name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.purple)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func serviceIcon(for serviceName: String) -> String {
        switch serviceName.lowercased() {
        case "netflix":
            return "netflix_icon"
        case "crunchyroll":
            return "crunchyroll_icon"
        case "amazon prime":
            return "amazon_icon"
        case "hulu":
            return "hulu_icon"
        case "disney+":
            return "disney_icon"
        case "funimation":
            return "funimation_icon"
        default:
            return "streaming_icon" // Icono genérico
        }
    }
}

// This struct needs to be defined to match your model
struct AnimeEpisode: Identifiable {
    let id: Int
    let number: Int
    let title: String
    let duration: String
}

#Preview {
    NavigationStack {
        AnimeDetailView(animeID: 5114)
            .environmentObject(AnimeService())
            .environmentObject(UserLibrary(authService: AuthService()))
    }
}

