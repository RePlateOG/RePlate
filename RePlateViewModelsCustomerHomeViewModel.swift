//
//  CustomerHomeViewModel.swift
//  RePlate
//
//  ViewModel for customer home screen
//

import SwiftUI
import CoreLocation

@MainActor
final class CustomerHomeViewModel: NSObject, ObservableObject {
    @Published var listings: [Listing] = []
    @Published var filteredListings: [Listing] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Location
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var currentLocationName = "Finding location..."
    private var locationManager = CLLocationManager()
    
    // Filters
    @Published var searchQuery = "" {
        didSet { applyFilters() }
    }
    @Published var selectedCategory: FoodCategory? {
        didSet { applyFilters() }
    }
    @Published var maxDistance: Double = 10.0
    @Published var maxPrice: Double = 50.0
    @Published var showFreeOnly = false
    @Published var selectedPickupTime: Date?
    
    // Impact stats
    @Published var userImpactStats = ImpactStats(
        totalMealsSaved: 0,
        totalCO2Reduced: 0,
        totalFoodRescued: 0,
        totalUsers: 0,
        totalRestaurants: 0
    )
    
    var hasActiveFilters: Bool {
        selectedCategory != nil || showFreeOnly || maxDistance < 10.0 || maxPrice < 50.0
    }
    
    override init() {
        super.init()
        setupLocationManager()
        loadListings()
        loadUserImpact()
    }
    
    // MARK: - Location
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func distance(to listing: Listing) -> Double? {
        guard let userLocation = userLocation else { return nil }
        
        let listingLocation = CLLocation(
            latitude: listing.restaurantLocation.latitude,
            longitude: listing.restaurantLocation.longitude
        )
        let userCLLocation = CLLocation(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude
        )
        
        let distanceMeters = userCLLocation.distance(from: listingLocation)
        return distanceMeters / 1609.34 // Convert to miles
    }
    
    // MARK: - Data Loading
    func loadListings() {
        isLoading = true
        
        Task {
            do {
                // TODO: Replace with actual API call
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Mock data
                listings = generateMockListings()
                applyFilters()
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func loadUserImpact() {
        Task {
            // TODO: Load from backend
            userImpactStats = ImpactStats(
                totalMealsSaved: 12,
                totalCO2Reduced: 15.5,
                totalFoodRescued: 8.2,
                totalUsers: 0,
                totalRestaurants: 0
            )
        }
    }
    
    func refresh() async {
        loadListings()
        loadUserImpact()
    }
    
    // MARK: - Filters
    private func applyFilters() {
        filteredListings = listings.filter { listing in
            // Search query
            if !searchQuery.isEmpty {
                let matchesTitle = listing.title.localizedCaseInsensitiveContains(searchQuery)
                let matchesRestaurant = listing.restaurantName.localizedCaseInsensitiveContains(searchQuery)
                let matchesCategory = listing.category.rawValue.localizedCaseInsensitiveContains(searchQuery)
                
                if !matchesTitle && !matchesRestaurant && !matchesCategory {
                    return false
                }
            }
            
            // Category
            if let selectedCategory = selectedCategory, listing.category != selectedCategory {
                return false
            }
            
            // Free only
            if showFreeOnly && !listing.isFree {
                return false
            }
            
            // Max price
            if listing.discountedPrice > maxPrice {
                return false
            }
            
            // Distance
            if let distance = distance(to: listing), distance > maxDistance {
                return false
            }
            
            // Status
            if listing.status != .active || listing.isExpired {
                return false
            }
            
            return true
        }
        
        // Sort by distance
        filteredListings.sort { listing1, listing2 in
            let dist1 = distance(to: listing1) ?? Double.infinity
            let dist2 = distance(to: listing2) ?? Double.infinity
            return dist1 < dist2
        }
    }
    
    func resetFilters() {
        searchQuery = ""
        selectedCategory = nil
        maxDistance = 10.0
        maxPrice = 50.0
        showFreeOnly = false
        selectedPickupTime = nil
    }
    
    // MARK: - Mock Data
    private func generateMockListings() -> [Listing] {
        let restaurants = [
            ("Pizza Palace", "New York, NY", 40.7580, -73.9855),
            ("Sushi Express", "New York, NY", 40.7489, -73.9680),
            ("Burger Joint", "New York, NY", 40.7614, -73.9776),
            ("Healthy Bites", "New York, NY", 40.7549, -73.9840),
            ("Pasta Paradise", "New York, NY", 40.7505, -73.9934)
        ]
        
        let foodItems = [
            ("Margherita Pizza", FoodCategory.pizza, 15.99, 7.99),
            ("California Roll", FoodCategory.sushi, 12.99, 6.99),
            ("Classic Burger", FoodCategory.burgers, 10.99, 5.99),
            ("Caesar Salad", FoodCategory.salads, 9.99, 0),
            ("Spaghetti Carbonara", FoodCategory.pasta, 14.99, 8.99)
        ]
        
        return (0..<10).map { index in
            let restaurant = restaurants[index % restaurants.count]
            let food = foodItems[index % foodItems.count]
            
            let now = Date()
            let pickupStart = now.addingTimeInterval(Double.random(in: 1800...3600))
            let pickupEnd = pickupStart.addingTimeInterval(Double.random(in: 3600...7200))
            
            return Listing(
                id: UUID().uuidString,
                restaurantId: "r\(index % restaurants.count)",
                restaurantName: restaurant.0,
                restaurantLocation: GeoPoint(
                    latitude: restaurant.2 + Double.random(in: -0.01...0.01),
                    longitude: restaurant.3 + Double.random(in: -0.01...0.01)
                ),
                title: food.0,
                description: "Delicious \(food.0) available for pickup",
                category: food.1,
                imageURLs: [],
                quantity: Int.random(in: 1...5),
                originalPrice: food.2,
                discountedPrice: food.3,
                isFree: food.3 == 0,
                pickupStart: pickupStart,
                pickupEnd: pickupEnd,
                status: .active,
                createdAt: now,
                updatedAt: now,
                expiresAt: pickupEnd
            )
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CustomerHomeViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        userLocation = location.coordinate
        
        // Reverse geocode to get location name
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first else { return }
            
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            
            DispatchQueue.main.async {
                self.currentLocationName = "\(city), \(state)"
            }
        }
        
        applyFilters()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        currentLocationName = "Location unavailable"
    }
}
