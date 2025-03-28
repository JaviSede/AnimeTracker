//
//  AppState.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 20/3/25.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil  // Clear any previous error messages
        
        // Simulate network request with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // For demo purposes, accept any non-empty email/password
            // In a real app, you would validate against a backend
            if email.contains("@") && password.count >= 6 {
                // Create a user object
                let user = User(id: UUID().uuidString, email: email, username: email.split(separator: "@").first?.description ?? "user")
                self.currentUser = user
                self.isLoggedIn = true
                self.isLoading = false  // Make sure loading state is updated
            } else {
                self.errorMessage = "Invalid email or password. Password must be at least 6 characters."
                self.isLoading = false  // Make sure loading state is updated even on error
            }
        }
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
    }
}

struct User {
    let id: String
    let email: String
    let username: String
}