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
    @AppStorage("isDarkMode") private var isDarkMode = true
    // Añadir estas propiedades al inicio de la estructura
    @State private var selectedFilter: AnimeStatus = .all
    @State private var sortOption: SortOption = .lastUpdated
    @State private var showingSortMenu = false
    @State private var sortAscending = false  // Añadir esta línea
    @State private var showingSettings = false  // Add this line to declare the state variable

    
    // Definir las opciones de ordenación
    enum SortOption: String, CaseIterable {
        case title = "Título"
        case lastUpdated = "Última Actualización"
        case progress = "Progreso"
        case score = "Puntuación"
        
        var icon: String {
            switch self {
            case .title: return "textformat.abc"
            case .lastUpdated: return "clock"
            case .progress: return "chart.bar.fill"
            case .score: return "star.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(isDarkMode ? .black : .white)
                    .ignoresSafeArea()
                
                libraryContent
            }
        }
    }
    
    private var libraryContent: some View {
        VStack(spacing: 0) {
            filterTabsView
            
            if filteredAnimes.isEmpty {
                emptyLibraryView
            } else {
                libraryListView
            }
        }
        .navigationTitle("Mi Biblioteca")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.purple)
                    }
                    
                    sortMenuButton
                }
            }
        }
        .onAppear {
            loadAnimeData()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(isDarkMode: $isDarkMode)
        }
    }
    
    private var filterTabsView: some View {
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
    }
    
    private var libraryListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredAnimes) { anime in
                    animeRow(anime: anime)
                }
            }
            .padding()
        }
    }
    
    private var sortMenuButton: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(action: {
                    sortOption = option
                }) {
                    Label(option.rawValue, systemImage: option.icon)
                        .foregroundColor(sortOption == option ? .purple : .white)
                }
            }
            
            Divider()
            
            Button(action: {
                sortAscending.toggle()
            }) {
                Label(
                    sortAscending ? "Ascending" : "Descending",
                    systemImage: sortAscending ? "arrow.up" : "arrow.down"
                )
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundColor(.purple)
        }
    }
    
    private func loadAnimeData() {
        if animeService.recommendedAnime.isEmpty {
            animeService.fetchRecommendedAnime()
        }
        
        if animeService.popularAnime.isEmpty {
            animeService.fetchPopularAnime()
        }
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(isDarkMode ? .gray : .gray.opacity(0.7))
                .padding()
                .background(
                    Circle()
                        .fill(isDarkMode ? Color.gray.opacity(0.2) : Color.purple.opacity(0.1))
                        .frame(width: 120, height: 120)
                )
            
            Text("Tu biblioteca está vacía")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isDarkMode ? .white : .black)
            
            Text("Añade anime desde la pestaña de búsqueda para comenzar a construir tu colección")
                .font(.body)
                .foregroundColor(isDarkMode ? .gray : .secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToSearchTab"), object: nil)
                print("Button pressed, notification sent")
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                    Text("Descubrir Anime")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 200)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
                .padding()
        )
    }
    
    private var filteredAnimes: [SavedAnimeModel] {
        let filtered = selectedFilter == .all ?
        userLibrary.fetchSavedAnimes() :
        userLibrary.fetchSavedAnimes().filter { $0.status == selectedFilter }
        
        // Aplicar ordenación
        return sortAnimes(filtered)
    }
    
    private func sortAnimes(_ animes: [SavedAnimeModel]) -> [SavedAnimeModel] {
        switch sortOption {
        case .title:
            if sortAscending {
                return animes.sorted(by: { $0.title < $1.title })
            } else {
                return animes.sorted(by: { $0.title > $1.title })
            }
            
        case .lastUpdated:
            if sortAscending {
                return animes.sorted(by: { $0.lastUpdated < $1.lastUpdated })
            } else {
                return animes.sorted(by: { $0.lastUpdated > $1.lastUpdated })
            }
            
        case .progress:
            if sortAscending {
                return animes.sorted(by: { 
                    let progress1 = ($0.totalEpisodes ?? 0) > 0 ? Double($0.currentEpisode) / Double($0.totalEpisodes ?? 1) : 0
                    let progress2 = ($1.totalEpisodes ?? 0) > 0 ? Double($1.currentEpisode) / Double($1.totalEpisodes ?? 1) : 0
                    return progress1 < progress2
                })
            } else {
                return animes.sorted(by: { 
                    let progress1 = ($0.totalEpisodes ?? 0) > 0 ? Double($0.currentEpisode) / Double($0.totalEpisodes ?? 1) : 0
                    let progress2 = ($1.totalEpisodes ?? 0) > 0 ? Double($1.currentEpisode) / Double($1.totalEpisodes ?? 1) : 0
                    return progress1 > progress2
                })
            }
            
        case .score:
            if sortAscending {
                return animes.sorted(by: { ($0.score ?? 0) < ($1.score ?? 0) })
            } else {
                return animes.sorted(by: { ($0.score ?? 0) > ($1.score ?? 0) })
            }
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
    
    private func animeRow(anime: SavedAnimeModel) -> some View {
        NavigationLink(destination: AnimeDetailView(animeID: anime.id)) {
            HStack(spacing: 16) {
                // Anime image
                AsyncImage(url: URL(string: anime.imageUrl!)) { phase in
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
                                    .foregroundColor(isDarkMode ? .white : .gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(anime.title)
                        .font(.headline)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .lineLimit(2)
                    
                    Text(anime.status.displayName)
                        .font(.subheadline)
                        .foregroundColor(anime.status.color)
                    
                    if anime.status == .watching {
                        HStack {
                            Text("Episode \(anime.currentEpisode)/\(anime.totalEpisodes != nil && anime.totalEpisodes! > 0 ? String(anime.totalEpisodes!) : "?")")
                                .font(.caption)
                                .foregroundColor(isDarkMode ? .gray : .secondary)
                            
                            Spacer()
                            
                            if let totalEpisodes = anime.totalEpisodes, totalEpisodes > 0 {
                                ProgressView(value: Double(anime.currentEpisode), total: Double(totalEpisodes))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                    .frame(width: 100)
                            }
                        }
                        
                        // Controles para editar episodios
                        HStack {
                            Button(action: {
                                if anime.currentEpisode > 0 {
                                    userLibrary.updateAnime(id: anime.id, currentEpisode: anime.currentEpisode - 1)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .disabled(anime.currentEpisode <= 0)
                            
                            Spacer()
                            
                            Button(action: {
                                let newEpisode = anime.currentEpisode + 1
                                userLibrary.updateAnime(id: anime.id, currentEpisode: newEpisode)
                                
                                // Si llegamos al último episodio, preguntar si quiere marcar como completado
                                if let totalEpisodes = anime.totalEpisodes, totalEpisodes > 0 && newEpisode >= totalEpisodes {
                                    // En una app real, aquí iría un alert o confirmación
                                    // Por ahora, simplemente actualizamos el estado
                                    userLibrary.updateAnime(id: anime.id, status: .completed)
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Añadir menú de opciones
                Menu {
                    // Sección para editar episodios
                    if anime.status == .watching || anime.status == .onHold {
                        Button(action: {
                            userLibrary.updateAnime(id: anime.id, currentEpisode: anime.currentEpisode + 1)
                        }) {
                            Label("Update Episode", systemImage: "pencil")
                        }
                        
                        Divider()
                    }
                    
                    ForEach(AnimeStatus.allCases.filter { $0 != .all }, id: \.self) { status in
                        Button(action: {
                            userLibrary.updateAnime(id: anime.id, status: status)
                        }) {
                            Label(status.displayName, systemImage: statusIcon(for: status))
                        }
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: {
                        userLibrary.removeAnime(id: anime.id)
                    }) {
                        Label("Remove from Library", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(isDarkMode ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .contextMenu {
            // Añadir opciones para editar episodios en el menú contextual
            if anime.status == .watching || anime.status == .onHold {
                Button(action: {
                    userLibrary.updateAnime(id: anime.id, currentEpisode: anime.currentEpisode + 1)
                }) {
                    Label("Increment Episode", systemImage: "plus.circle")
                }
                
                if anime.currentEpisode > 0 {
                    Button(action: {
                        userLibrary.updateAnime(id: anime.id, currentEpisode: anime.currentEpisode - 1)
                    }) {
                        Label("Decrement Episode", systemImage: "minus.circle")
                    }
                }
                
                Divider()
            }
            
            ForEach(AnimeStatus.allCases.filter { $0 != .all }, id: \.self) { status in
                Button(action: {
                    userLibrary.updateAnime(id: anime.id, status: status)
                }) {
                    Label(status.displayName, systemImage: statusIcon(for: status))
                }
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                userLibrary.removeAnime(id: anime.id)
            }) {
                Label("Remove from Library", systemImage: "trash")
            }
        }
    }
    
    // Función auxiliar para obtener el icono correspondiente a cada estado
    private func statusIcon(for status: AnimeStatus) -> String {
        switch status {
        case .watching: return "play.circle"
        case .completed: return "checkmark.circle"
        case .planToWatch: return "calendar"
        case .onHold: return "pause.circle"
        case .dropped: return "xmark.circle"
        default: return "circle"
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environmentObject(UserLibrary(authService: AuthService()))
            .environmentObject(AnimeService())
            .preferredColorScheme(.dark)
    }
}
