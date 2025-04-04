//
//  User.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation
import SwiftUI

struct User: Codable, Identifiable {
    var id: String
    var username: String
    var email: String
    var profileImageUrl: String?
    var bio: String?
    var joinDate: Date
    var animeStats: AnimeStats
    
    struct AnimeStats: Codable {
        var totalAnime: Int = 0
        var watching: Int = 0
        var completed: Int = 0
        var planToWatch: Int = 0
        var onHold: Int = 0
        var dropped: Int = 0
        var totalEpisodes: Int = 0
        var daysWatched: Double = 0.0
    }
}