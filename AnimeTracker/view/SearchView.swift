//
//  SearchView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var animeService: AnimeService
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var searchText = ""
    @State private var searchResults: [AnimePreview] = []
    @State private var isSearching = false
    @State private var selectedAnime: Int? = nil
    
    var body: some View {
        NavigationStack {  // Añadir NavigationStack aquí
            ZStack {
                Color(isDarkMode ? .black : .white)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search anime...", text: $searchText)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { newValue in
                                if newValue.isEmpty {
                                    searchResults = []
                                } else if newValue.count > 2 {
                                    performSearch()
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Content area
                    if isSearching {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    } else if searchResults.isEmpty && !searchText.isEmpty {
                        Spacer()
                        Text("No results found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else if searchResults.isEmpty {
                        // Show trending or popular anime when no search
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Popular Anime")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                                    ForEach(animeService.popularAnime) { anime in
                                        Button {
                                            selectedAnime = anime.id
                                        } label: {
                                            animeCard(anime: anime)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 16)
                        }
                    } else {
                        // Search results
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Search Results")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                                    ForEach(searchResults) { anime in
                                        Button {
                                            selectedAnime = anime.id
                                        } label: {
                                            animeCard(anime: anime)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                .navigationDestination(for: Int.self) { animeID in
                    AnimeDetailView(animeID: animeID)
                }
            }
            .navigationTitle("Search")  // Añadir título de navegación
            .navigationBarTitleDisplayMode(.large)  // Configurar estilo de título
            .toolbarBackground(isDarkMode ? Color.black.opacity(0.8) : Color.white.opacity(0.8), for: .navigationBar)  // Hacer la barra menos transparente
            .toolbarBackground(.visible, for: .navigationBar)  // Asegurar que la barra sea visible
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)  // Esquema de color adaptativo para la barra
        }
        .onAppear {
            // Cargar datos populares si están vacíos
            if animeService.popularAnime.isEmpty {
                animeService.fetchPopularAnime()
            }
        }
    }
    
    private func animeCard(anime: AnimePreview) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: anime.mal_id)) {
            VStack(alignment: .leading) {
                AsyncImage(url: URL(string: anime.images.jpg.image_url)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fill)
                            .frame(width: 150, height: 200)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 200)
                            .cornerRadius(8)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isDarkMode ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(3/4, contentMode: .fill)
                            .frame(width: 150, height: 200)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(isDarkMode ? .white : .black)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .shadow(color: Color.black.opacity(isDarkMode ? 0.2 : 0.1), radius: 3, x: 0, y: 2)
                
                Text(anime.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isDarkMode ? .white : .black)
                    .lineLimit(2)
                    .frame(width: 150, height: 40, alignment: .topLeading)
                
                if let score = anime.score {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text(String(format: "%.1f", score))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 150, alignment: .leading)
                }
            }
            .frame(width: 150)
            .background(isDarkMode ? Color.black : Color.white)
        }
    }
    
    private func performSearch() {
        isSearching = true
        
        animeService.searchAnime(query: searchText) { results in
            DispatchQueue.main.async {
                self.searchResults = results
                self.isSearching = false
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(AnimeService())
            .preferredColorScheme(.dark)
    }
}

