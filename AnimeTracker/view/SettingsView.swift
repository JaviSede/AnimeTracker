//
//  SettingsView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDarkMode: Bool
    @AppStorage("autoMarkAsCompleted") private var autoMarkAsCompleted = true
    @AppStorage("showProgressBar") private var showProgressBar = true
    @AppStorage("defaultSortOption") private var defaultSortOption = "lastUpdated"
    @AppStorage("sortAscending") private var sortAscending = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? .black : .white).edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text("Display").foregroundColor(isDarkMode ? .gray : .black)) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                        
                        Picker("Default Sort", selection: $defaultSortOption) {
                            Text("Title").tag("title")
                            Text("Last Updated").tag("lastUpdated")
                            Text("Progress").tag("progress")
                            Text("Score").tag("score")
                        }
                        .foregroundColor(isDarkMode ? .white : .black)
                        
                        Toggle("Sort Ascending", isOn: $sortAscending)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                    }
                    
                    Section(header: Text("Library").foregroundColor(isDarkMode ? .gray : .black)) {
                        Toggle("Auto-mark as Completed", isOn: $autoMarkAsCompleted)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                        
                        Toggle("Show Progress Bar", isOn: $showProgressBar)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                    }
                    
                    Section(header: Text("Data").foregroundColor(isDarkMode ? .gray : .black)) {
                        Button(action: {
                            // Lógica para exportar datos
                            print("Export data")
                        }) {
                            Label("Export Library Data", systemImage: "square.and.arrow.up")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        Button(action: {
                            // Lógica para importar datos
                            print("Import data")
                        }) {
                            Label("Import Library Data", systemImage: "square.and.arrow.down")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        Button(action: {
                            // Lógica para limpiar caché
                            print("Clear cache")
                        }) {
                            Label("Clear Cache", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("About").foregroundColor(isDarkMode ? .gray : .black)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(isDarkMode ? .white : .black)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView().preferredColorScheme(isDarkMode ? .dark : .light)) {
                            Text("Privacy Policy")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        NavigationLink(destination: TermsOfServiceView().preferredColorScheme(isDarkMode ? .dark : .light)) {
                            Text("Terms of Service")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
        }
    }
}

// Asegúrate de que estas vistas también respeten el modo claro/oscuro
struct PrivacyPolicyView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Last updated: March 28, 2025")
                    .foregroundColor(.gray)
                
                Text("This Privacy Policy describes how your personal information is collected, used, and shared when you use the AnimeTracker application.")
                    .foregroundColor(.white)
                
                Text("Information We Collect")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("AnimeTracker stores all your data locally on your device. We do not collect or store any personal information on our servers. Your anime list, preferences, and settings are stored only on your device.")
                    .foregroundColor(.white)
                
                // Más contenido de política de privacidad...
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea())
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsOfServiceView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Last updated: March 28, 2025")
                    .foregroundColor(.gray)
                
                Text("Please read these Terms of Service carefully before using the AnimeTracker application.")
                    .foregroundColor(.white)
                
                Text("Use of Application")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("AnimeTracker is provided for personal, non-commercial use. You may use the application to track your anime watching progress and manage your anime collection.")
                    .foregroundColor(.white)
                
                // Más contenido de términos de servicio...
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea())
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isDarkMode: .constant(true))
            .preferredColorScheme(.dark)
    }
}