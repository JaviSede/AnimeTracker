//
//  UserLibrary.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI
import Combine

enum AnimeStatus: String, Codable, CaseIterable {
    case all
    case watching
    case completed
    case planToWatch
    case onHold
    case dropped
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .watching: return "Watching"
        case .completed: return "Completed"
        case .planToWatch: return "Plan to Watch"
        case .onHold: return "On Hold"
        case .dropped: return "Dropped"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .white
        case .watching: return .blue
        case .completed: return .green
        case .planToWatch: return .purple
        case .onHold: return .orange
        case .dropped: return .red
        }
    }
}

struct SavedAnime: Identifiable, Codable {
    var id: Int
    var title: String
    var imageUrl: String
    var status: AnimeStatus
    var score: Double?
    var currentEpisode: Int
    var totalEpisodes: Int
    var notes: String
    var dateAdded: Date
    var lastUpdated: Date
    
    init(id: Int, title: String, imageUrl: String, status: AnimeStatus = .planToWatch, score: Double? = nil, currentEpisode: Int = 0, totalEpisodes: Int = 0, notes: String = "") {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.status = status
        self.score = score
        self.currentEpisode = currentEpisode
        self.totalEpisodes = totalEpisodes
        self.notes = notes
        self.dateAdded = Date()
        self.lastUpdated = Date()
    }
}

class UserLibrary: ObservableObject {
    @Published var savedAnimes: [SavedAnime] = []
    
    private let saveKey = "user_anime_library"
    
    init() {
        loadLibrary()
    }
    
    func addAnime(anime: AnimePreview, status: AnimeStatus = .planToWatch) {
        // Check if anime already exists
        if !isInLibrary(id: anime.id) {
            let newAnime = SavedAnime(
                id: anime.id,
                title: anime.title,
                imageUrl: anime.images.jpg.image_url,
                status: status,
                totalEpisodes: anime.episodes ?? 0
            )
            
            savedAnimes.append(newAnime)
            saveLibrary()
        }
    }
    
    func updateAnime(id: Int, status: AnimeStatus? = nil, score: Double? = nil, currentEpisode: Int? = nil, notes: String? = nil) {
        if let index = savedAnimes.firstIndex(where: { $0.id == id }) {
            if let status = status {
                savedAnimes[index].status = status
            }
            
            if let score = score {
                savedAnimes[index].score = score
            }
            
            if let currentEpisode = currentEpisode {
                savedAnimes[index].currentEpisode = currentEpisode
                
                // Auto-complete if reached final episode
                if currentEpisode >= savedAnimes[index].totalEpisodes && savedAnimes[index].totalEpisodes > 0 {
                    savedAnimes[index].status = .completed
                }
            }
            
            if let notes = notes {
                savedAnimes[index].notes = notes
            }
            
            savedAnimes[index].lastUpdated = Date()
            saveLibrary()
        }
    }
    
    func removeAnime(id: Int) {
        savedAnimes.removeAll { $0.id == id }
        saveLibrary()
    }
    
    func isInLibrary(id: Int) -> Bool {
        return savedAnimes.contains { $0.id == id }
    }
    
    func getAnimeStatus(id: Int) -> AnimeStatus? {
        return savedAnimes.first(where: { $0.id == id })?.status
    }
    
    private func saveLibrary() {
        if let encoded = try? JSONEncoder().encode(savedAnimes) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadLibrary() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([SavedAnime].self, from: data) {
                savedAnimes = decoded
                return
            }
        }
        
        // If no saved data or decoding fails, start with empty library
        savedAnimes = []
    }
}