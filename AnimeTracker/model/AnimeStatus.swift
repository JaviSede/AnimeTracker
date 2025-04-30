//
//  AnimeStatus.swift
//  AnimeTracker
//
//  Created by Manus on 30/4/25.
//  Moved from UserLibrary.swift to resolve potential circular dependencies.
//

import SwiftUI // Needed for Color
import Foundation // Needed for Codable, CaseIterable

// Define the status of an anime in the user's library
enum AnimeStatus: String, Codable, CaseIterable {
    case watching = "Watching"
    case completed = "Completed"
    case planToWatch = "Plan to Watch"
    case onHold = "On Hold"
    case dropped = "Dropped"
    case all = "All" // Used for filtering in UI, not for storing in SavedAnimeModel

    // Computed property to get the display name
    var displayName: String {
        return self.rawValue
    }

    // Computed property to get an associated color for UI elements
    var color: Color {
        switch self {
        case .watching: return .blue
        case .completed: return .green
        case .planToWatch: return .purple
        case .onHold: return .orange
        case .dropped: return .red
        case .all: return .gray // Color for the 'All' filter option
        }
    }
}

