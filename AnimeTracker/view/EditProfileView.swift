//
//  EditProfileView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//  Updated by Manus on 29/4/25.
//

import SwiftUI
import PhotosUI // Needed for PhotosPicker

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    
    // State variables bound to UI controls
    @State private var username: String = ""
    @State private var bio: String = ""
    
    // State for photo picker
    @State private var selectedPhotoItem: PhotosPickerItem? // Item from the picker
    @State private var selectedImageData: Data? // Raw data of the selected image
    @State private var profileImageToDisplay: Image? // Image view to display selection/current
    
    // State for loading and errors specific to this view
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Consistent background
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // --- Profile Image Section ---
                        VStack {
                            // Display selected image or current user image
                            profileImageDisplay
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.purple.opacity(0.8), lineWidth: 3))
                                .shadow(color: .purple.opacity(0.5), radius: 5)
                            
                            // PhotosPicker to select a new image
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.purple)
                            }
                            // Process the selected photo item
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                Task {
                                    // Load data from the selected item
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                        // Update the display image
                                        if let uiImage = UIImage(data: data) {
                                            profileImageToDisplay = Image(uiImage: uiImage)
                                        }
                                    } else {
                                        print("Failed to load image data")
                                        // Optionally clear selection or show error
                                    }
                                }
                            }
                        }
                        .padding(.top, 30)
                        
                        // --- Form Fields Section ---
                        VStack(spacing: 15) {
                            // Username TextField
                            TextField("Username", text: $username)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                            
                            // Bio TextEditor
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $bio)
                                    .frame(height: 150)
                                    .padding(4)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5)))
                                
                                // Placeholder for TextEditor
                                if bio.isEmpty {
                                    Text("Tell us about yourself...")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 8)
                                        .padding(.top, 12)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // --- Error Message Display ---
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.horizontal)
                        }
                        
                        // --- Save Button ---
                        Button(action: saveChanges) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                Text(isSaving ? "Saving..." : "Save Changes")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isSaving ? Color.gray : Color.purple)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .disabled(isSaving) // Disable button while saving
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.5), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            // Load initial data when the view appears
            .onAppear(perform: loadUserData)
        }
    }
    
    // Computes the image to display (selected or current user's)
    @ViewBuilder
    private var profileImageDisplay: some View {
        if let displayImage = profileImageToDisplay {
            displayImage
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let user = authService.currentUser, let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
            // Use AsyncImage for existing URL
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure, .empty:
                    placeholderImageView // Show placeholder on load failure
                @unknown default:
                    placeholderImageView
                }
            }
        } else {
            placeholderImageView // Default placeholder
        }
    }
    
    // Reusable placeholder view
    private var placeholderImageView: some View {
        Image(systemName: "person.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 65, height: 65)
            .foregroundColor(.white.opacity(0.7))
            .padding(32.5)
            .background(Color.gray.opacity(0.3))
    }
    
    // Load user data into state variables
    private func loadUserData() {
        if let user = authService.currentUser {
            username = user.username
            bio = user.bio ?? ""
            // No need to load image here, profileImageDisplay handles it
        }
    }
    
    // Action to save changes
    private func saveChanges() {
        guard !isSaving else { return } // Prevent double taps
        
        isSaving = true
        errorMessage = nil
        
        // Prepare image data if a new image was selected
        let imageDataToSave = selectedImageData // Pass the raw data
        
        // Create a local reference to avoid the wrapper issue
        let auth = authService
        
        // Use Task for async operation
        Task {
            do {
                // Use the local reference instead of $authService.wrappedValue
                try await auth.updateProfile(
                    username: username,
                    bio: bio,
                    imageData: imageDataToSave
                )
                // Use main thread for UI updates
                await MainActor.run {
                    isSaving = false
                    dismiss() // Close the view on success
                }
            } catch {
                // Use main thread for UI updates
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Preview

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthService = AuthService()
        let mockUser = UserModel(username: "PreviewUser", email: "preview@example.com", password: "password")
        mockUser.bio = "This is a bio for the preview user."
        // mockUser.profileImageUrl = "https://via.placeholder.com/150" // Example URL
        mockAuthService.currentUser = mockUser
        mockAuthService.isAuthenticated = true
        
        return EditProfileView()
            .environmentObject(mockAuthService)
            .preferredColorScheme(.dark)
    }
}


