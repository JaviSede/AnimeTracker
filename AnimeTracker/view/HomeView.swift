//
//  HomeView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct NavigationHome: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill").foregroundStyle(Color.white)
                    Text("Home")
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            Text("Library")
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Library")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Sección "Currently Watching"
                        Text("Currently Watching")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 150)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Attack on Titan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Season 4")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                
                                Text("Episode 15/16")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Button(action: {}) {
                                    Text("Continue")
                                        .fontWeight(.bold)
                                        .frame(width: 100, height: 40)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sección "Recommended For You"
                        Text("Recommended For You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { index in
                                    VStack(spacing: 5) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 120, height: 160)
                                        
                                        Text(index % 2 == 0 ? "Demon Slayer" : "My Hero Academia")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Sección "Popular Now"
                        Text("Popular Now")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { _ in
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 160)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationHome()
}
