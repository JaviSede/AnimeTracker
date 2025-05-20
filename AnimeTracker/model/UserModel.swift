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
    @Attribute(.unique) var id: String
    var username: String
    var email: String
    var password: String // Store hashed password
    var profileImageUrl: String?
    var bio: String?
    var joinDate: Date

    // Relationship to AnimeStats (one-to-one)
    @Relationship(deleteRule: .cascade, inverse: \AnimeStats.owningUser)
    var stats: AnimeStats?

    // Relationship to SavedAnimeModel (one-to-many)
    @Relationship(deleteRule: .cascade, inverse: \SavedAnimeModel.user)
    var savedAnimes: [SavedAnimeModel] = []

    init(id: String = UUID().uuidString,
         username: String,
         email: String,
         password: String, // Hashed password
         profileImageUrl: String? = nil,
         bio: String? = nil,
         joinDate: Date = Date(),
         stats: AnimeStats? = nil,
         savedAnimes: [SavedAnimeModel] = [])
    {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.joinDate = joinDate
        self.stats = stats
        self.savedAnimes = savedAnimes
    }
}
