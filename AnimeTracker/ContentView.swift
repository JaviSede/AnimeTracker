//
//  ContentView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLoggedIn {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var animeService: AnimeService
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            NavigationStack {
                AnimeListView()
                    .navigationTitle("Discover")
            }
            .tabItem {
                Label("Discover", systemImage: "house.fill")
            }
            .tag(0)
            
            // Search tab
            NavigationStack {
                Text("Search functionality coming soon!")
                    .navigationTitle("Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(1)
            
            // My List tab
            NavigationStack {
                Text("Your anime list will appear here")
                    .navigationTitle("My List")
            }
            .tabItem {
                Label("My List", systemImage: "list.bullet")
            }
            .tag(2)
            
            // Profile tab
            NavigationStack {
                VStack(spacing: 20) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(String(appState.currentUser?.username.prefix(1) ?? "U"))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    Text(appState.currentUser?.username ?? "User")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(appState.currentUser?.email ?? "")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: {
                        appState.logout()
                    }) {
                        Text("Logout")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
                .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(3)
        }
        .accentColor(.purple)
    }
}

struct AnimeListView: View {
    @EnvironmentObject var animeService: AnimeService
    
    // For demo purposes, showing a few popular anime IDs
    let popularAnimeIDs = [5114, 1535, 21, 30276, 1575]
    
    var body: some View {
        List(popularAnimeIDs, id: \.self) { animeID in
            NavigationLink(destination: AnimeDetailView(animeID: animeID)) {
                Text("Anime ID: \(animeID)")
                    .padding()
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AnimeService())
}
