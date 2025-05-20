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
    case watching = "Viendo"
    case completed = "Completado"
    case planToWatch = "Pendiente"
    case onHold = "En Pausa"
    case dropped = "Abandonado"
    case all = "Todos"

    var displayName: String {
        return self.rawValue
    }

    var color: Color {
        switch self {
        case .watching: return .blue
        case .completed: return .green
        case .planToWatch: return .purple
        case .onHold: return .orange
        case .dropped: return .red
        case .all: return .gray
        }
    }
}

