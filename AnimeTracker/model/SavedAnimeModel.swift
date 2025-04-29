//
//  SavedAnimeModel.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation
import SwiftData

@Model
final class SavedAnimeModel {
    var id: Int
    var title: String
    var imageUrl: String
    var status: AnimeStatus  // Cambiar de String a AnimeStatus
    var score: Double?
    var currentEpisode: Int
    var totalEpisodes: Int
    var notes: String
    var dateAdded: Date
    var lastUpdated: Date
    
    // Relación con el usuario
    @Relationship(inverse: \UserModel.savedAnimes)
    var user: UserModel?
    
    init(id: Int, 
         title: String, 
         imageUrl: String, 
         status: AnimeStatus = .planToWatch,  // Actualizar tipo
         score: Double? = nil, 
         currentEpisode: Int = 0, 
         totalEpisodes: Int = 0, 
         notes: String = "") {
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