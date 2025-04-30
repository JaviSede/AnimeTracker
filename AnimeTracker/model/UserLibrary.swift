import SwiftUI
import SwiftData
import Combine

class UserLibrary: ObservableObject {
    // Dependencies: ModelContext for database operations and AuthService for current user
    private var modelContext: ModelContext?
    private var authService: AuthService?
    private var cancellables = Set<AnyCancellable>()

    // Published property to indicate loading state or errors
    @Published var isLoading: Bool = false
    @Published var error: String?

    // Initializer requires AuthService
    init(authService: AuthService) {
        self.authService = authService
        // Observe changes in the current user to reload data if necessary
        authService.$currentUser
            .sink { [weak self] _ in
                // Potentially trigger a reload or update if needed when user changes
                // For now, actions are user-initiated, so direct reload might not be required here
            }
            .store(in: &cancellables)
    }

    // Method to inject the ModelContext (similar to AuthService)
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        // Initial data loading could happen here if needed, but LibraryView will fetch
    }

    // Helper to get the current user and their stats object
    private func getCurrentUserAndStats() -> (UserModel, AnimeStats)? {
        guard let user = authService?.currentUser else {
            error = "Not logged in."
            return nil
        }
        guard let stats = user.stats else {
            error = "User statistics not found."
            // Attempt to create stats if missing (shouldn't happen with current register logic)
            if let context = modelContext {
                let newStats = AnimeStats()
                user.stats = newStats
                // context.insert(newStats) // Cascade should handle this
                do {
                    try context.save()
                    print("Created missing AnimeStats for user \(user.username)")
                    return (user, newStats)
                } catch {
                    self.error = "Failed to create missing stats: \(error.localizedDescription)"
                    return nil
                }
            } else {
                self.error = "Database context unavailable to create stats."
                return nil
            }
        }
        return (user, stats)
    }

    // --- Core Library Functions --- 

    func addAnime(anime: AnimePreview, status: AnimeStatus = .planToWatch) {
        guard let context = modelContext else {
            error = "Database context unavailable."
            return
        }
        guard let (user, stats) = getCurrentUserAndStats() else { return }
        guard !isInLibrary(id: anime.id) else {
            error = "\(anime.title) is already in your library."
            return
        }

        isLoading = true
        error = nil

        let newAnime = SavedAnimeModel(
            id: anime.id,  // Pasar directamente el Int, sin convertir a String
            title: anime.title,
            imageUrl: anime.images.jpg.image_url,
            status: status,
            totalEpisodes: anime.episodes ?? 0
        )

        // Associate with the user
        newAnime.user = user
        
        context.insert(newAnime)

        do {
            // Recalculate stats *before* saving
            var currentAnimes = user.savedAnimes
            currentAnimes.append(newAnime) // Add the new one for calculation
            stats.recalculate(from: currentAnimes)
            
            try context.save()
            print("Added \(anime.title) to library for user \(user.username)")
        } catch {
            self.error = "Failed to add anime: \(error.localizedDescription)"
            context.delete(newAnime)
        }
        isLoading = false
    }

    func updateAnime(id: Int, status: AnimeStatus? = nil, score: Double? = nil, currentEpisode: Int? = nil, notes: String? = nil) {
        guard let context = modelContext else {
            error = "Database context unavailable."
            return
        }
        guard let (user, stats) = getCurrentUserAndStats() else { return }
        guard let animeToUpdate = user.savedAnimes.first(where: { $0.id == id }) else {
            error = "Anime with ID \(id) not found in library."
            return
        }

        isLoading = true
        error = nil
        var changed = false

        if let status = status, animeToUpdate.status != status {
            animeToUpdate.status = status
            changed = true
        }
        if let score = score, animeToUpdate.score != Int(score) {  // Convertir Double a Int
            animeToUpdate.score = Int(score)
            changed = true
        }
        if let currentEpisode = currentEpisode, animeToUpdate.currentEpisode != currentEpisode {
            animeToUpdate.currentEpisode = currentEpisode
            // Auto-complete logic
            if let totalEpisodes = animeToUpdate.totalEpisodes, 
               currentEpisode >= totalEpisodes && 
               totalEpisodes > 0 && 
               animeToUpdate.status != .completed {
                animeToUpdate.status = .completed
                changed = true // Status changed
            }
            changed = true
        }
        if let notes = notes, animeToUpdate.notes != notes {
            animeToUpdate.notes = notes
            changed = true
        }

        if changed {
            animeToUpdate.lastUpdated = Date()
            do {
                // Recalculate stats before saving
                stats.recalculate(from: user.savedAnimes)
                try context.save()
                print("Updated anime ID \(id) for user \(user.username)")
            } catch {
                self.error = "Failed to update anime: \(error.localizedDescription)"
            }
        } else {
            print("No changes detected for anime ID \(id)")
        }
        isLoading = false
    }

    func removeAnime(id: Int) {
        guard let context = modelContext else {
            error = "Database context unavailable."
            return
        }
        guard let (user, stats) = getCurrentUserAndStats() else { return }
        guard let animeToRemove = user.savedAnimes.first(where: { $0.id == id }) else {
            error = "Anime with ID \(id) not found in library."
            return
        }

        isLoading = true
        error = nil

        // Need a copy of the list *before* deletion for recalculation
        let animesBeforeDeletion = user.savedAnimes
        let animesAfterDeletion = animesBeforeDeletion.filter { $0.id != id }

        context.delete(animeToRemove)

        do {
            // Recalculate stats based on the list *after* deletion
            stats.recalculate(from: animesAfterDeletion)
            try context.save()
            print("Removed anime ID \(id) for user \(user.username)")
        } catch {
            self.error = "Failed to remove anime: \(error.localizedDescription)"
            context.rollback()
        }
        isLoading = false
    }

    // --- Helper Functions --- 

    func isInLibrary(id: Int) -> Bool {
        guard let user = authService?.currentUser else { return false }
        return user.savedAnimes.contains { $0.id == id }
    }

    func getAnimeStatus(id: Int) -> AnimeStatus? {
        guard let user = authService?.currentUser else { return nil }
        return user.savedAnimes.first { $0.id == id }?.status
    }
    
    func getSavedAnime(id: Int) -> SavedAnimeModel? {
        guard let user = authService?.currentUser else { return nil }
        return user.savedAnimes.first { $0.id == id }
    }
    
    func fetchSavedAnimes() -> [SavedAnimeModel] {
        guard let user = authService?.currentUser else { return [] }
        return user.savedAnimes.sorted { $0.lastUpdated > $1.lastUpdated }
    }
}

