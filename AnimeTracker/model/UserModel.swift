//
//  UserModel.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation
import SwiftData

@Model
final class UserModel {
    var id: String
    var username: String
    var email: String
    var profileImageUrl: String?
    var bio: String?
    var joinDate: Date
    var password: String // En producción, deberías usar métodos más seguros
    
    // Relaciones
    @Relationship(.cascade, inverse: \AnimeStats.user)
    var stats: AnimeStats?
    
    @Relationship(.cascade, inverse: \SavedAnimeModel.user)
    var savedAnimes: [SavedAnimeModel] = []
    
    init(id: String = UUID().uuidString, 
         username: String, 
         email: String, 
         profileImageUrl: String? = nil, 
         bio: String? = nil, 
         password: String) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.joinDate = Date()
        self.password = password
        self.savedAnimes = []
    }
}

@Model
final class AnimeStats {
    var totalAnime: Int = 0
    var watching: Int = 0
    var completed: Int = 0
    var planToWatch: Int = 0
    var onHold: Int = 0
    var dropped: Int = 0
    var totalEpisodes: Int = 0
    var daysWatched: Double = 0.0
    
    @Relationship(inverse: \UserModel.stats)
    var user: UserModel?
    
    init() {}
}