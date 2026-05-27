//
//  AppState.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import Combine
import CoreLocation

@MainActor
class AppState: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedTab: Tab = .home
    @Published var colorScheme: ColorSchemePreference = .system
    
    // Onboarding
    @Published var hasCompletedOnboarding = false
    @Published var isOnboarding = false
    
    // Location
    @Published var userLocation: CLLocation?
    @Published var locationPermissionStatus: LocationPermissionStatus = .notDetermined
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case search = "Search"
        case orders = "Orders"
        case messages = "Messages"
        case profile = "Profile"
        
        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .orders: return "bag"
            case .messages: return "message"
            case .profile: return "person"
            }
        }
        
        var iconFilled: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
            case .orders: return "bag.fill"
            case .messages: return "message.fill"
            case .profile: return "person.fill"
            }
        }
    }
    
    enum ColorSchemePreference: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    enum LocationPermissionStatus {
        case notDetermined
        case authorized
        case denied
    }
    
    // MARK: - Services
    private let authService = AuthService.shared
    private let locationService = LocationService.shared
    
    // MARK: - Initialization
    init() {
        loadUserPreferences()
        checkAuthenticationStatus()
        setupLocationService()
    }
    
    // MARK: - Methods
    func loadUserPreferences() {
        if let savedScheme = UserDefaults.standard.string(forKey: "colorScheme"),
           let preference = ColorSchemePreference(rawValue: savedScheme) {
            colorScheme = preference
        }
        
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func saveColorSchemePreference(_ preference: ColorSchemePreference) {
        colorScheme = preference
        UserDefaults.standard.set(preference.rawValue, forKey: "colorScheme")
    }
    
    func checkAuthenticationStatus() {
        // This would check with your auth service
        // For now, we'll simulate it
        isAuthenticated = authService.isAuthenticated
        currentUser = authService.currentUser
    }
    
    func setupLocationService() {
        // Setup location tracking
    }
    
    func signOut() {
        authService.signOut()
        isAuthenticated = false
        currentUser = nil
        selectedTab = .home
    }
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// LocationService is defined in LocationService.swift
// AuthService is defined in AuthService.swift
