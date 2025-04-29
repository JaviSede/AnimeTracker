//
//  StreamingService.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import Foundation

struct StreamingService: Identifiable, Codable {
    var name: String
    var url: String
    
    var id: String { name }
}