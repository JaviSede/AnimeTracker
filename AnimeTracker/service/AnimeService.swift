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
                    print("Error fetching anime details: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("No data received from API")
                    completion(nil)
                    return
                }
                
                do {
                    // Decodificar la respuesta
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(AnimeDetailResponse.self, from: data)
                    
                    // Crear una copia mutable del anime
                    var animeDetail = response.data
                    
                    // Añadir servicios de streaming de ejemplo
                    animeDetail.streaming = [
                        StreamingService(name: "Netflix", url: "https://www.netflix.com"),
                        StreamingService(name: "Crunchyroll", url: "https://www.crunchyroll.com"),
                        StreamingService(name: "Funimation", url: "https://www.funimation.com")
                    ]
                    
                    completion(animeDetail)
                } catch {
                    print("Error decoding anime details: \(error.localizedDescription)")
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

struct AnimeDetailResponse: Codable {
    let data: AnimePreview
}

struct AnimePreview: Identifiable, Codable, Equatable {
    let mal_id: Int
    let title: String
    let images: AnimeImages
    let synopsis: String?
    let status: String?
    let episodes: Int?
    let score: Double?
    let genres: [AnimeGenre]?
    var streaming: [StreamingService]?
    
    var id: Int {
        return mal_id
    }
    
    enum CodingKeys: String, CodingKey {
        case mal_id, title, images, synopsis, status, episodes, score, genres
        // No incluimos 'streaming' aquí porque no está en el JSON
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        mal_id = try container.decode(Int.self, forKey: .mal_id)
        title = try container.decode(String.self, forKey: .title)
        images = try container.decode(AnimeImages.self, forKey: .images)
        synopsis = try container.decodeIfPresent(String.self, forKey: .synopsis)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        episodes = try container.decodeIfPresent(Int.self, forKey: .episodes)
        score = try container.decodeIfPresent(Double.self, forKey: .score)
        genres = try container.decodeIfPresent([AnimeGenre].self, forKey: .genres)
        
        // Inicializamos streaming como nil porque no está en el JSON
        streaming = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(mal_id, forKey: .mal_id)
        try container.encode(title, forKey: .title)
        try container.encode(images, forKey: .images)
        try container.encodeIfPresent(synopsis, forKey: .synopsis)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(episodes, forKey: .episodes)
        try container.encodeIfPresent(score, forKey: .score)
        try container.encodeIfPresent(genres, forKey: .genres)
        
        // No codificamos 'streaming' porque no está en el JSON original
    }
}

struct AnimeGenre: Codable, Identifiable, Equatable {
    let mal_id: Int
    let name: String
    
    var id: Int { mal_id }
}

struct AnimeImages: Codable, Equatable {
    let jpg: AnimeImage
    let webp: AnimeImage
}

struct AnimeImage: Codable, Equatable {
    let image_url: String
    let small_image_url: String?
    let large_image_url: String?
}

// Also add this struct definition
struct StreamingService: Codable, Equatable {
    let name: String
    let url: String
}
