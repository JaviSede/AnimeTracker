//
//  AppState.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 21/3/25.
//

import Foundation

import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var selectedTab = 0
    
    // Datos de ejemplo
    @Published var watchingAnimes: [Anime] = []
    @Published var recommendedAnimes: [Anime] = []
    @Published var popularAnimes: [Anime] = []
    
    init() {
        // Cargar datos de ejemplo
        loadSampleData()
    }
    
    func login(email: String, password: String) {
        // Simulación de login exitoso
        self.isLoggedIn = true
        self.currentUser = User(id: "1", username: "AniMaster42", email: email, watchingCount: 42, completedCount: 87, planToWatchCount: 25, droppedCount: 12)
    }
    
    func logout() {
        self.isLoggedIn = false
        self.currentUser = nil
    }
    
    private func loadSampleData() {
        watchingAnimes = [
            Anime(id: 1, title: "Attack on Titan", season: "Season 4", episodeCount: 16, currentEpisode: 15, imageURL: "")
        ]
        
        recommendedAnimes = [
            Anime(id: 2, title: "Demon Slayer", imageURL: ""),
            Anime(id: 3, title: "My Hero Academia", imageURL: ""),
            Anime(id: 4, title: "Jujutsu Kaisen", imageURL: ""),
            Anime(id: 5, title: "One Piece", imageURL: "")
        ]
        
        popularAnimes = [
            Anime(id: 6, title: "Chainsaw Man", imageURL: ""),
            Anime(id: 7, title: "Spy x Family", imageURL: ""),
            Anime(id: 8, title: "Bleach", imageURL: ""),
            Anime(id: 9, title: "Tokyo Revengers", imageURL: "")
        ]
    }
}

// Modelos
struct User {
    let id: String
    let username: String
    let email: String
    let watchingCount: Int
    let completedCount: Int
    let planToWatchCount: Int
    let droppedCount: Int
}

struct Anime: Identifiable {
    let id: Int
    let title: String
    var season: String = ""
    var episodeCount: Int = 0
    var currentEpisode: Int = 0
    let imageURL: String
}
