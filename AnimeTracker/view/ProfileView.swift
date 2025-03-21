//
//  ProfileView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 21/3/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Profile Header
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("🦁")
                                    .font(.system(size: 40))
                            )
                        
                        VStack(alignment: .leading) {
                            Text("AniMaster42")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("154 Anime • 48 Following")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    // Stats
                    HStack {
                        Spacer()
                        StatView(count: "42", title: "Watching")
                        Spacer()
                        StatView(count: "87", title: "Completed")
                        Spacer()
                        StatView(count: "25", title: "Plan to Watch")
                        Spacer()
                    }
                    .padding(.vertical)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    // My Lists
                    Text("My Lists")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                    
                    VStack(spacing: 10) {
                        ListRowView(title: "Watching", count: 42)
                        ListRowView(title: "Completed", count: 87)
                        ListRowView(title: "Plan to Watch", count: 25)
                        ListRowView(title: "Dropped", count: 12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button("Edit") {
                // Action for edit button
            }.foregroundColor(.purple))
        }
    }
}

struct StatView: View {
    let count: String
    let title: String
    
    var body: some View {
        VStack {
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct ListRowView: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text("\(count) →")
                .foregroundColor(.purple)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

