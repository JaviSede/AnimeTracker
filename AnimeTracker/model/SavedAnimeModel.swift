//
//  SavedAnimeModel.swift
//  AnimeTracker
//
//  Created based on usage in UserModel and AnimeStats.
//

import Foundation
import SwiftData

@Model
final class SavedAnimeModel {
    @Attribute(.unique) var id: Int // ID único para la entrada guardada
    var animeId: Int // ID from the anime database/API
    var title: String
    var imageUrl: String?
    var status: AnimeStatus // e.g., watching, completed, etc.
    var currentEpisode: Int
    var totalEpisodes: Int? // Optional, as some anime might be ongoing
    var score: Int? // User's score (e.g., 1-10)
    var dateAdded: Date
    var dateCompleted: Date?
    var lastUpdated: Date // Añadido para tracking de actualizaciones
    var notes: String? // Añadido para permitir notas del usuario
    
    // Relationship back to the user who saved this anime
    // This is the inverse of the 'savedAnimes' relationship in UserModel
    var user: UserModel?

    init(id: Int,
         title: String,
         imageUrl: String? = nil,
         status: AnimeStatus,
         currentEpisode: Int = 0,
         totalEpisodes: Int = 0,
         score: Int? = nil,
         dateAdded: Date = Date(),
         dateCompleted: Date? = nil,
         lastUpdated: Date = Date(),
         notes: String? = nil,
         user: UserModel? = nil) // Allow associating with a user upon creation
    {
        self.id = id
        self.animeId = id // Usar el mismo ID como animeId para simplificar
        self.title = title
        self.imageUrl = imageUrl
        self.status = status
        self.currentEpisode = currentEpisode
        self.totalEpisodes = totalEpisodes
        self.score = score
        self.dateAdded = dateAdded
        self.dateCompleted = dateCompleted
        self.lastUpdated = lastUpdated
        self.notes = notes
        self.user = user
    }
}

