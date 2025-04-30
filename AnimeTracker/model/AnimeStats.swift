import Foundation
import SwiftData

@Model
final class AnimeStats {
    // Stats properties
    var totalAnime: Int = 0
    var watching: Int = 0
    var completed: Int = 0
    var planToWatch: Int = 0
    var onHold: Int = 0
    var dropped: Int = 0
    var totalEpisodes: Int = 0
    var daysWatched: Double = 0.0

    // Relationship back to the user
    // Renamed from 'user' to 'owningUser' to match the inverse relationship in UserModel
    // and potentially avoid macro expansion conflicts.
    var owningUser: UserModel?

    // Default initializer
    init() {}

    // Method to recalculate all statistics based on a list of SavedAnimeModel
    // Ensure AnimeStatus enum is correctly defined and accessible
    func recalculate(from animes: [SavedAnimeModel]) {
        // Reset counts before recalculating
        watching = 0
        completed = 0
        planToWatch = 0
        onHold = 0
        dropped = 0
        totalEpisodes = 0
        totalAnime = animes.count

        for anime in animes {
            // Ensure AnimeStatus enum cases match exactly how they are defined
            switch anime.status {
            case .watching:
                watching += 1
            case .completed:
                completed += 1
            case .planToWatch:
                planToWatch += 1
            case .onHold:
                onHold += 1
            case .dropped:
                dropped += 1
            // Add default or @unknown default if the enum might have other cases
            @unknown default:
                print("Warning: Unknown anime status encountered during stats recalculation: \(anime.status)")
            }
            totalEpisodes += anime.currentEpisode
        }

        // Calculate days watched (assuming 24 minutes per episode)
        let totalMinutes = Double(totalEpisodes) * 24.0 // Adjust episode duration if needed
        daysWatched = totalMinutes > 0 ? totalMinutes / (60.0 * 24.0) : 0.0

        print("Stats recalculated: Total=\(totalAnime), Watching=\(watching), Completed=\(completed), Plan=\(planToWatch), Hold=\(onHold), Dropped=\(dropped), Episodes=\(totalEpisodes), Days=\(String(format: "%.1f", daysWatched))")
    }
}

