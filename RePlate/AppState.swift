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

    // Profile image (stored in memory; TODO: backend — sync with server)
    @Published var profileImageData: Data?

    // Saved payment methods (display-only: brand + last4 from Stripe — no raw card data)
    // SECURITY: never store raw card data; this is populated from the Supabase payment_methods table
    @Published var savedPaymentMethods: [PaymentMethod] = []

    // Single source of truth for orders shared between customer and restaurant views
    // TODO: backend — replace with real-time order subscription (WebSocket / push)
    @Published var orders: [Order] = []

    // Legal consent
    var hasAcceptedTerms: Bool {
        UserDefaults.standard.bool(forKey: "acceptedTerms")
    }

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
    let authService = RePlateAuthService.shared
    private let locationService = LocationService.shared
    private var authCancellable: AnyCancellable?

    // MARK: - Initialization
    init() {
        loadUserPreferences()
        checkAuthenticationStatus()
        setupLocationService()

        // Keep AppState in sync whenever the auth service updates.
        authCancellable = authService.objectWillChange.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isAuthenticated = self.authService.isAuthenticated
                self.currentUser = self.authService.currentUser
            }
        }
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
        isAuthenticated = authService.isAuthenticated
        currentUser = authService.currentUser
    }

    // The Supabase JWT for the signed-in user — passed as Authorization header to Edge Functions.
    var accessToken: String? { authService.accessToken }
    
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
// RePlateAuthService is defined in AuthService.swift
