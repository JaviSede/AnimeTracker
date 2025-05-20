//
//  SettingsView.swift
//  AnimeTracker
//
//  Created by Javi Sedeño on 28/3/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isDarkMode: Bool
    @AppStorage("autoMarkAsCompleted") private var autoMarkAsCompleted = true
    @AppStorage("showProgressBar") private var showProgressBar = true
    @AppStorage("defaultSortOption") private var defaultSortOption = "lastUpdated"
    @AppStorage("sortAscending") private var sortAscending = false
    @EnvironmentObject var userLibrary: UserLibrary
    
    // Estados para alertas y hojas
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingClearCacheAlert = false
    @State private var showingExportSuccessAlert = false
    @State private var showingImportSuccessAlert = false
    @State private var showingImportErrorAlert = false
    @State private var exportURL: URL?
    @State private var importErrorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo adaptativo según el modo
                Color(isDarkMode ? .black : .white).edgesIgnoringSafeArea(.all)
                
                List {
                    // En la sección de apariencia de tu SettingsView
                    Section(header: Text("Apariencia")) {
                        Toggle(isOn: $isDarkMode) {
                            HStack {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundColor(isDarkMode ? .yellow : .orange)
                                Text("Modo Oscuro")
                            }
                        }
                        .tint(.purple)
                        .onChange(of: isDarkMode) { newValue in
                            // Forzar la actualización de la UI
                            UserDefaults.standard.set(newValue, forKey: "isDarkMode")
                            // Notificar a otras vistas sobre el cambio
                            NotificationCenter.default.post(name: Notification.Name("DarkModeChanged"), object: nil)
                        }
                        
                        Picker("Orden Predeterminado", selection: $defaultSortOption) {
                            Text("Título").tag("title")
                            Text("Última Actualización").tag("lastUpdated")
                            Text("Progreso").tag("progress")
                            Text("Puntuación").tag("score")
                        }
                        .foregroundColor(isDarkMode ? .white : .black)
                        
                        Toggle("Orden Ascendente", isOn: $sortAscending)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                    }
                    
                    Section(header: Text("Biblioteca").foregroundColor(isDarkMode ? .gray : .black)) {
                        Toggle("Completado Automáticamente", isOn: $autoMarkAsCompleted)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                            .onChange(of: autoMarkAsCompleted) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "autoMarkAsCompleted")
                            }
                        
                        Toggle("Mostrar Barra de Progreso", isOn: $showProgressBar)
                            .foregroundColor(isDarkMode ? .white : .black)
                            .tint(.purple)
                            .onChange(of: showProgressBar) { newValue in
                                UserDefaults.standard.set(newValue, forKey: "showProgressBar")
                            }
                    }
                    
                    Section(header: Text("Datos").foregroundColor(isDarkMode ? .gray : .black)) {
                        Button(action: {
                            exportLibraryData()
                        }) {
                            Label("Exportar Datos de Biblioteca", systemImage: "square.and.arrow.up")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        Button(action: {
                            showingImportSheet = true
                        }) {
                            Label("Importar Datos de Biblioteca", systemImage: "square.and.arrow.down")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        Button(action: {
                            showingClearCacheAlert = true
                        }) { 
                            Label("Limpiar Caché", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("Acerca de").foregroundColor(isDarkMode ? .gray : .black)) {
                        HStack {
                            Text("Versión")
                                .foregroundColor(isDarkMode ? .white : .black)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView().preferredColorScheme(isDarkMode ? .dark : .light)) {
                            Text("Política de Privacidad")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                        
                        NavigationLink(destination: TermsOfServiceView().preferredColorScheme(isDarkMode ? .dark : .light)) {
                            Text("Términos de Servicio")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            // Aplicar el esquema de color a la vista de navegación
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.purple)
                }
            }
            // Alertas y hojas
            .alert("¿Estás seguro?", isPresented: $showingClearCacheAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpiar", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("Esto eliminará todas las imágenes en caché y datos temporales. No afectará a tu biblioteca de anime.")
            }
            .alert("Exportación exitosa", isPresented: $showingExportSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let url = exportURL {
                    Text("Tus datos han sido exportados a Archivos. Puedes encontrarlos en: \(url.lastPathComponent)")
                } else {
                    Text("Tus datos han sido exportados correctamente.")
                }
            }
            .alert("Importación exitosa", isPresented: $showingImportSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Tus datos han sido importados correctamente.")
            }
            .alert("Error de importación", isPresented: $showingImportErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(importErrorMessage)
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ActivityViewController(activityItems: [url])
                }
            }
            .sheet(isPresented: $showingImportSheet) {
                DocumentPicker(types: ["public.json"], onDocumentPicked: { url in
                    importLibraryData(from: url)
                })
            }
        }
    }
    
    // MARK: - Funciones de gestión de datos
    
    private func exportLibraryData() {
        print("Export")
    }
    
    private func importLibraryData(from url: URL) {
        print("Import")
    }
    
    
    private func clearCache() {
        // Limpiar caché de imágenes
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        
        do {
            let cacheContents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for url in cacheContents {
                try fileManager.removeItem(at: url)
            }
            
            // Limpiar caché de URLSession
            URLCache.shared.removeAllCachedResponses()
            
            print("Caché limpiada correctamente")
        } catch {
            print("Error al limpiar caché: \(error.localizedDescription)")
        }
    }
}

// MARK: - Vistas auxiliares para importación/exportación

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct DocumentPicker: UIViewControllerRepresentable {
    var types: [String]
    var onDocumentPicked: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
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
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Information We Collect")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("AnimeTracker stores all your data locally on your device. We do not collect or store any personal information on our servers. Your anime list, preferences, and settings are stored only on your device.")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
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
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("Use of Application")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("AnimeTracker is provided for personal, non-commercial use. You may use the application to track your anime watching progress and manage your anime collection.")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
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
