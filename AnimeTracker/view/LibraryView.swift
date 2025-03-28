//
//  LibraryView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var animeService: AnimeService
    @EnvironmentObject var userLibrary: UserLibrary
    @State private var selectedFilter: AnimeStatus = .all
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            filterButton(for: .all)
                            filterButton(for: .watching)
                            filterButton(for: .completed)
                            filterButton(for: .planToWatch)
                            filterButton(for: .onHold)
                            filterButton(for: .dropped)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    if filteredAnimes.isEmpty {
                        emptyLibraryView
                    } else {
                        // Library content
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredAnimes) { anime in
                                    animeRow(anime: anime)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("My Library")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Sort options
                        }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(.purple)
                        }
                    }
                }
                .onAppear {
                    // Asegurarse de que los datos se cargan correctamente
                    if animeService.recommendedAnime.isEmpty {
                        animeService.fetchRecommendedAnime()
                    }
                    
                    // Cargar también los animes populares
                    if animeService.popularAnime.isEmpty {
                        animeService.fetchPopularAnime()
                    }
                }
            }
        }
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your library is empty")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Add anime from the search tab to start building your collection")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToSearchTab"), object: nil)
                print("Button pressed, notification sent")
            } label: {
                Text("Discover Anime")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private var filteredAnimes: [SavedAnime] {
        if selectedFilter == .all {
            return userLibrary.savedAnimes
        } else {
            return userLibrary.savedAnimes.filter { $0.status == selectedFilter }
        }
    }
    
    private func filterButton(for status: AnimeStatus) -> some View {
        Button(action: {
            selectedFilter = status
        }) {
            Text(status.displayName)
                .font(.subheadline)
                .fontWeight(selectedFilter == status ? .bold : .regular)
                .foregroundColor(selectedFilter == status ? .white : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    selectedFilter == status ?
                    Color.purple.opacity(0.8) :
                    Color.gray.opacity(0.2)
                )
                .cornerRadius(20)
        }
    }
    
    private func animeRow(anime: SavedAnime) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: anime.id)) {
            HStack(spacing: 16) {
                // Anime image
                AsyncImage(url: URL(string: anime.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 120)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(anime.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(anime.status.displayName)
                        .font(.subheadline)
                        .foregroundColor(anime.status.color)
                    
                    if anime.status == .watching {
                        HStack {
                            Text("Episode \(anime.currentEpisode)/\(anime.totalEpisodes > 0 ? String(anime.totalEpisodes) : "?")")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            if anime.totalEpisodes > 0 {
                                ProgressView(value: Double(anime.currentEpisode), total: Double(anime.totalEpisodes))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                    .frame(width: 100)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(UserLibrary())
            .environmentObject(AnimeService())
            .preferredColorScheme(.dark)
    }
}
