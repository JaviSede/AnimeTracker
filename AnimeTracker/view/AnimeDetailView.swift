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
    @State private var animeDetail: AnimeDetail?
    @State private var isLoading = true
    @State private var expandSynopsis = false
    
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
        .navigationTitle("Anime Detail")
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            loadAnimeDetails()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 100)
    }
    
    private var errorView: some View {
        Text("Failed to load anime details")
            .foregroundColor(.red)
            .padding()
    }
    
    private func animeContentView(anime: AnimeDetail) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Image section
            animeImageView(imageURL: anime.imageURL)
            
            // Title and info section
            titleSection(anime: anime)
            
            // Action buttons
            actionButtonsSection()
            
            // Synopsis section
            synopsisSection(synopsis: anime.synopsis ?? "No synopsis available.")
            
            // Episodes section
            if let episodeCount = anime.episodes {
                Text("Episodes: \(episodeCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            
            // Note: We're removing the episodesSection call since we don't have episode details
            // If you want to display episode details, you'll need to fetch them separately
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
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    private func titleSection(anime: AnimeDetail) -> some View {
        VStack(alignment: .leading) {
            // Title
            Text(anime.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            // Genres
            Text(anime.genres.map { $0.name }.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.purple)
                .padding(.horizontal)
            
            // Rating
            if let rating = anime.rating {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(rating)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func actionButtonsSection() -> some View {
        HStack(spacing: 15) {
            Button(action: {
                // Action for "Watching"
            }) {
                Text("Watching")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // Action for "+ List"
            }) {
                Text("+ List")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple, lineWidth: 2)
                    )
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal)
    }
    
    private func synopsisSection(synopsis: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Synopsis")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Text(synopsis)
                .font(.body)
                .foregroundColor(.gray)
                .lineLimit(expandSynopsis ? nil : 3)
                .padding(.horizontal)
            
            Button(action: {
                expandSynopsis.toggle()
            }) {
                Text(expandSynopsis ? "Show Less" : "Read More")
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
        }
    }
    
    private func episodesSection(episodes: [AnimeEpisode]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Episodes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(episodes) { episode in
                episodeRow(episode: episode)
            }
        }
    }
    
    private func episodeRow(episode: AnimeEpisode) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Episode \(episode.number): \(episode.title)")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
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
    }
}

