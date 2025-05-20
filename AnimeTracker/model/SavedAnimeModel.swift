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
    @Attribute(.unique) var id: Int
    var animeId: Int
    var title: String
    var imageUrl: String?
    var status: AnimeStatus 
    var currentEpisode: Int
    var totalEpisodes: Int? 
    var score: Int?
    var dateAdded: Date
    var dateCompleted: Date?
    var lastUpdated: Date
    var notes: String?
    
    // Relationship back to the user who saved this anime
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
         user: UserModel? = nil) 
    {
        self.id = id
        self.animeId = id
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
