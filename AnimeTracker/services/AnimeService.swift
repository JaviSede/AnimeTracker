//
//  AnimeService.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import Foundation
import Combine

struct AnimeDetail: Decodable {
    let id: Int
    let title: String
    let genres: [Genre]
    let episodes: Int?
    let synopsis: String
    let imageURL: String
    let rating: String?  // Added rating field
    
    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case title
        case genres
        case episodes
        case synopsis = "synopsis"
        case images
        case rating  // Added rating key
    }
    
    struct Genre: Decodable {
        let name: String
    }
    
    struct Images: Decodable {
        let jpg: ImageURLs
        
        enum CodingKeys: String, CodingKey {
            case jpg
        }
    }
    
    struct ImageURLs: Decodable {
        let imageURL: String
        
        enum CodingKeys: String, CodingKey {
            case imageURL = "large_image_url"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        genres = try container.decode([Genre].self, forKey: .genres)
        episodes = try container.decodeIfPresent(Int.self, forKey: .episodes)
        synopsis = try container.decode(String.self, forKey: .synopsis)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        
        let images = try container.decode(Images.self, forKey: .images)
        imageURL = images.jpg.imageURL
    }
}

// Add ObservableObject conformance to the service
class AnimeService: ObservableObject {
    private let baseURL = "https://api.jikan.moe/v4"
    
    func fetchAnimeDetails(animeID: Int, completion: @escaping (AnimeDetail?) -> Void) {
        let urlString = "\(baseURL)/anime/\(animeID)"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Print the request for debugging
        print("Making request to: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Log HTTP response for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status: \(httpResponse.statusCode)")
            }
            
            guard let data = data, error == nil else {
                print("Error fetching data:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(responseString.prefix(200))...") // Print just the beginning to avoid console overflow
            }
            
            do {
                // Jikan API wraps the response in a "data" object
                struct JikanResponse: Decodable {
                    let data: AnimeDetail
                }
                
                let response = try JSONDecoder().decode(JikanResponse.self, from: data)
                completion(response.data)
            } catch {
                print("JSON Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }
}