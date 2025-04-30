//
//  AnimeStatusSelectionView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct AnimeStatusSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userLibrary: UserLibrary
    
    let animeID: Int
    let animeDetail: AnimePreview
    
    @State private var selectedStatus: AnimeStatus = .planToWatch
    @State private var currentEpisode: Int = 0
    @State private var score: Double = 0
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 16) {
                            // Anime image
                            AsyncImage(url: URL(string: animeDetail.images.jpg.image_url)) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 120)
                                        .cornerRadius(8)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 120)
                                        .cornerRadius(8)
                                        .clipped()
                                case .failure:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 120)
                                        .cornerRadius(8)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.white)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(animeDetail.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                
                                if let episodes = animeDetail.episodes {
                                    Text("\(episodes) episodes")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Status selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Status")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Status", selection: $selectedStatus) {
                                ForEach(AnimeStatus.allCases.filter { $0 != .all }, id: \.self) { status in
                                    Text(status.displayName)
                                        .tag(status)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        
                        // Episode counter (only for watching status)
                        if selectedStatus == .watching {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Current Episode")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Button(action: {
                                        if currentEpisode > 0 {
                                            currentEpisode -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Text("\(currentEpisode)")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.center)
                                    
                                    Button(action: {
                                        if let episodes = animeDetail.episodes, episodes > 0 {
                                            if currentEpisode < episodes {
                                                currentEpisode += 1
                                            }
                                        } else {
                                            currentEpisode += 1
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Spacer()
                                    
                                    if let episodes = animeDetail.episodes, episodes > 0 {
                                        Text("of \(episodes)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Score
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Score")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                ForEach(1...10, id: \.self) { i in
                                    Button(action: {
                                        score = Double(i)
                                    }) {
                                        Image(systemName: i <= Int(score) ? "star.fill" : "star")
                                            .foregroundColor(i <= Int(score) ? .yellow : .gray)
                                    }
                                }
                                
                                Text(String(format: "%.1f", score))
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.leading, 8)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // Save button
                        Button(action: {
                            saveAnime()
                            dismiss()
                        }) {
                            Text("Save to Library")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add to Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            .onAppear {
                // Si el anime ya está en la biblioteca, cargar sus datos actuales 
                if let savedAnime = userLibrary.getSavedAnime(id: animeID) {
                    selectedStatus = savedAnime.status 
                    currentEpisode = savedAnime.currentEpisode 
                    score = Double(savedAnime.score ?? 0) 
                    notes = savedAnime.notes! 
                }
            }
        }
    }
    
    private func saveAnime() {
        if userLibrary.isInLibrary(id: animeID) {
            // Actualizar anime existente
            userLibrary.updateAnime(
                id: animeID,
                status: selectedStatus,
                score: score > 0 ? score : nil,
                currentEpisode: currentEpisode,
                notes: notes
            )
        } else {
            // Añadir nuevo anime
            userLibrary.addAnime(anime: animeDetail, status: selectedStatus)
            
            // Actualizar episodio actual y notas si es necesario
            if currentEpisode > 0 || !notes.isEmpty || score > 0 {
                userLibrary.updateAnime(
                    id: animeID,
                    score: score > 0 ? score : nil,
                    currentEpisode: currentEpisode,
                    notes: notes
                )
            }
        }
    }
}
