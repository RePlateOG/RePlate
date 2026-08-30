//
//  ViewModels.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import Combine

// MARK: - Home View Model
@MainActor
class HomeViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var featuredListings: [FoodListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var impactStats = ImpactStats.empty
    @Published var showMap = false
    
    func loadListings() async {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: backend — fetch real listings from Supabase
        listings = []
        featuredListings = []
        impactStats = ImpactStats.empty
    }
    
    func refreshListings() async {
        await loadListings()
    }
    
    func toggleMapView() {
        showMap.toggle()
        hapticFeedback(.light)
    }
}

// MARK: - Restaurant Dashboard View Model
@MainActor
class RestaurantDashboardViewModel: ObservableObject {
    @Published var activeListings: [FoodListing] = []
    @Published var pendingOrders: [Order] = []
    @Published var todayStats: DashboardStats = .empty
    @Published var isLoading = false
    @Published var hasUnreadNotifications: Bool = false
    
    struct DashboardStats {
        var activeListings: Int
        var pendingOrders: Int
        var revenueToday: Double
        var mealsSaved: Int
        var co2Reduced: Double
        
        static var empty: DashboardStats {
            DashboardStats(activeListings: 0, pendingOrders: 0, revenueToday: 0, mealsSaved: 0, co2Reduced: 0)
        }
    }
    
    func loadDashboard() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        activeListings = MockData.sampleListings.filter { $0.status == .active }
        pendingOrders = MockData.sampleOrders.filter { $0.status == .pending || $0.status == .confirmed }
        hasUnreadNotifications = !pendingOrders.isEmpty
        todayStats = DashboardStats(
            activeListings: activeListings.count,
            pendingOrders: pendingOrders.count,
            revenueToday: 245.50,
            mealsSaved: 12,
            co2Reduced: 15.4
        )
    }
    
    func refreshDashboard() async {
        await loadDashboard()
    }
}

// MARK: - Post Listing View Model
@MainActor
class PostListingViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var category: FoodListing.FoodCategory = .meals
    @Published var originalPrice = ""
    @Published var discountedPrice = ""
    @Published var quantity = "1"
    @Published var isFree = false
    @Published var selectedImages: [UIImage] = []
    @Published var pickupStartTime = Date().addingTimeInterval(3600)
    @Published var pickupEndTime = Date().addingTimeInterval(7200)
    @Published var selectedDietaryInfo: Set<FoodListing.DietaryInfo> = []
    @Published var isPosting = false
    @Published var showSuccess = false
    
    var canPost: Bool {
        !title.isEmpty &&
        !selectedImages.isEmpty &&
        !quantity.isEmpty &&
        (isFree || !discountedPrice.isEmpty)
    }
    
    func postListing() async {
        guard canPost else { return }
        
        isPosting = true
        defer { isPosting = false }
        
        // Simulate posting
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        hapticFeedback(.success)
        showSuccess = true
        
        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.resetForm()
        }
    }
    
    func resetForm() {
        title = ""
        description = ""
        category = .meals
        originalPrice = ""
        discountedPrice = ""
        quantity = "1"
        isFree = false
        selectedImages = []
        pickupStartTime = Date().addingTimeInterval(3600)
        pickupEndTime = Date().addingTimeInterval(7200)
        selectedDietaryInfo = []
    }
    
    func suggestPrice() {
        // AI-based pricing suggestion
        if !originalPrice.isEmpty, let original = Double(originalPrice) {
            let suggested = original * 0.5
            discountedPrice = String(format: "%.2f", suggested)
        }
    }
}

// MARK: - Orders View Model
@MainActor
class OrdersViewModel: ObservableObject {
    @Published var pendingOrders: [Order] = []
    @Published var completedOrders: [Order] = []
    @Published var isLoading = false
    @Published var selectedTab = 0

    weak var appState: AppState?

    init(appState: AppState? = nil) {
        self.appState = appState
    }

    func loadOrders() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Read from appState (single source of truth) if available, else fall back to MockData
        let allOrders = appState?.orders ?? MockData.sampleOrders
        pendingOrders = allOrders.filter {
            $0.status == .pending || $0.status == .confirmed || $0.status == .ready
        }
        completedOrders = allOrders.filter {
            $0.status == .completed || $0.status == .cancelled
        }
    }

    /// Cancel an order, updating the shared appState source of truth.
    /// TODO: backend — POST /orders/{id}/status { status: "cancelled" }
    func cancelOrder(_ order: Order) {
        guard let appState = appState,
              let idx = appState.orders.firstIndex(where: { $0.id == order.id }) else { return }
        appState.orders[idx].status = .cancelled
        withAnimation {
            pendingOrders.removeAll { $0.id == order.id }
            var cancelled = appState.orders[idx]
            cancelled.status = .cancelled
            completedOrders.insert(cancelled, at: 0)
        }
        hapticFeedback(.success)
        // TODO: backend — POST /orders/{id}/status { status: "cancelled" }
    }

    func updateOrderStatus(orderId: String, status: Order.OrderStatus) async {
        // Update order status
        hapticFeedback(.success)
        await loadOrders()
    }

    func markAsNoShow(orderId: String) async {
        await updateOrderStatus(orderId: orderId, status: .noShow)
    }
}

// MARK: - Search View Model
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [FoodListing] = []
    @Published var recentSearches: [String] = []
    @Published var filters = SearchFilters()
    @Published var isLoading = false
    @Published var showFilters = false
    
    func search() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock search
        searchResults = MockData.sampleListings.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery)
        }
        
        // Add to recent searches
        if !recentSearches.contains(searchQuery) {
            recentSearches.insert(searchQuery, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
        }
    }
    
    func applyFilters() async {
        showFilters = false
        await search()
    }
    
    func clearFilters() {
        filters = SearchFilters()
    }
}

// MARK: - Profile View Model
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var showEditProfile = false
    @Published var showSettings = false
    
    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Load from auth service
        user = RePlateAuthService.shared.currentUser
    }
    
    func updateProfile(name: String, email: String, phoneNumber: String?) async {
        isLoading = true
        defer { isLoading = false }
        // TODO: backend — sync with Supabase
        RePlateAuthService.shared.updateCurrentUser(name: name, email: email, phoneNumber: phoneNumber)
        hapticFeedback(.success)
        await loadProfile()
    }
    
    func exportData() async {
        // Export user data
        hapticFeedback(.success)
    }
    
    func deleteAccount() async {
        // Delete account
        RePlateAuthService.shared.signOut()
    }
}

// MARK: - Messages View Model
@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false

    func loadConversations() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 300_000_000)
        // TODO: backend — fetch real conversations from Supabase
        conversations = []
        isLoading = false
    }

    func markAsRead(conversationId: String) async {
        // Mark conversation as read
    }
}

// MockData is defined in MockData.swift
