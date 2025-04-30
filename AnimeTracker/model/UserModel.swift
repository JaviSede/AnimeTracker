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
    var password: String // Store hashed password, as done in AuthRepository
    var profileImageUrl: String?
    var bio: String?
    var joinDate: Date

    // Relationship to AnimeStats (one-to-one)
    // Cascade delete means if UserModel is deleted, associated AnimeStats is also deleted.
    // Inverse path updated to point to 'owningUser' in AnimeStats
    @Relationship(deleteRule: .cascade, inverse: \AnimeStats.owningUser)
    var stats: AnimeStats?

    // Relationship to SavedAnimeModel (one-to-many)
    // Cascade delete means if UserModel is deleted, all their SavedAnimeModel entries are also deleted.
    // Made the array non-optional and updated inverse path.
    @Relationship(deleteRule: .cascade, inverse: \SavedAnimeModel.user)
    var savedAnimes: [SavedAnimeModel] = [] // Changed to non-optional array

    init(id: String = UUID().uuidString,
         username: String,
         email: String,
         password: String, // Hashed password
         profileImageUrl: String? = nil,
         bio: String? = nil,
         joinDate: Date = Date(),
         stats: AnimeStats? = nil, // Allow initializing with stats
         savedAnimes: [SavedAnimeModel] = []) // Default to empty array
    {
        self.id = id
        self.username = username
        self.email = email
        self.password = password // Store the hashed password
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.joinDate = joinDate
        self.stats = stats
        self.savedAnimes = savedAnimes
    }
}
