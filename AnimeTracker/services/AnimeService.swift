//
//  AnimeService.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import Foundation
import Combine

class AnimeService: ObservableObject {
    @Published var isLoading = false
    @Published var error: Error?
    @Published var popularAnime: [AnimePreview] = []
    @Published var recommendedAnime: [AnimePreview] = []
    @Published var currentlyWatchingAnime: [AnimePreview] = []
    
    private let baseURL = "https://api.jikan.moe/v4"
    
    func fetchPopularAnime() {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)/top/anime?filter=bypopularity&limit=10") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
                    self?.popularAnime = response.data
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    func fetchRecommendedAnime() {
        isLoading = true
        
        // For demo purposes, we'll use the upcoming anime as "recommended"
        guard let url = URL(string: "\(baseURL)/seasons/upcoming?limit=10") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
                    self?.recommendedAnime = response.data
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    // For demo purposes, we'll use currently airing anime as "currently watching"
    func fetchCurrentlyWatchingAnime() {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)/seasons/now?limit=5") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
                    self?.currentlyWatchingAnime = response.data
                } catch {
                    self?.error = error
                }
            }
        }.resume()
    }
    
    // Load all data at once
    func loadAllData() {
        fetchPopularAnime()
        fetchRecommendedAnime()
        fetchCurrentlyWatchingAnime()
    }
    
    func fetchAnimeDetails(animeID: Int, completion: @escaping (AnimePreview?) -> Void) {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)/anime/\(animeID)") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                    completion(response.data)
                } catch {
                    self?.error = error
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // Añade este método a tu clase AnimeService
    func searchAnime(query: String, completion: @escaping ([AnimePreview]) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/anime?q=\(encodedQuery)&limit=20") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
                completion(response.data)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
}

// Models for API responses
struct AnimeResponse: Codable {
    let data: [AnimePreview]
}

struct AnimePreview: Identifiable, Codable {
    let mal_id: Int
    let title: String
    let images: AnimeImages
    let episodes: Int?
    let status: String?
    let score: Double?
    let synopsis: String?
    let genres: [AnimeGenre]?
    
    var id: Int { mal_id }
}

struct AnimeGenre: Codable, Identifiable {
    let mal_id: Int
    let name: String
    
    var id: Int { mal_id }
}

struct AnimeImages: Codable {
    let jpg: AnimeImage
    let webp: AnimeImage
}

struct AnimeImage: Codable {
    let image_url: String
    let small_image_url: String?
    let large_image_url: String?
}

// Estructura para la respuesta de detalles de anime
struct AnimeDetailResponse: Codable {
    let data: AnimePreview
}