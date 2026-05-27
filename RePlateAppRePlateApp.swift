//
//  RePlateApp.swift
//  RePlate
//
//  Main app entry point
//

import SwiftUI

@main
struct RePlateApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.appearanceMode)
        }
    }
}

// MARK: - App Settings
final class AppSettings: ObservableObject {
    @Published var appearanceMode: ColorScheme?
    @Published var notificationsEnabled = true
    @Published var hapticsEnabled = true
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // TODO: Load from UserDefaults
    }
    
    func saveSettings() {
        // TODO: Save to UserDefaults
    }
}
