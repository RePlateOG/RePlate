//
//  Models.swift
//  RePlate
//
//  Core data models for the application
//

import Foundation
import CoreLocation

// MARK: - User Types
enum UserType: String, Codable {
    case restaurant
    case customer
}

// MARK: - User
struct User: Identifiable, Codable {
    let id: String
    var email: String
    var name: String
    var phone: String?
    var profileImageURL: String?
    var userType: UserType
    var createdAt: Date
    var isVerified: Bool
    
    // Restaurant-specific
    var restaurantName: String?
    var restaurantAddress: String?
    var restaurantLocation: GeoPoint?
    var restaurantDescription: String?
    var isRestaurantVerified: Bool?
    
    // Customer-specific
    var savedListings: [String]?
    var preferences: UserPreferences?
    
    // Impact stats
    var mealsSaved: Int
    var co2Reduced: Double
    var foodRescued: Double
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var pushNotificationsEnabled: Bool
    var emailNotificationsEnabled: Bool
    var searchRadius: Double
    var dietaryRestrictions: [String]
    var favoriteCategories: [FoodCategory]
}

struct GeoPoint: Codable {
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

// MARK: - Listing
struct Listing: Identifiable, Codable {
    let id: String
    var restaurantId: String
    var restaurantName: String
    var restaurantLocation: GeoPoint
    var restaurantImageURL: String?
    
    var title: String
    var description: String?
    var category: FoodCategory
    var imageURLs: [String]
    
    var quantity: Int
    var originalPrice: Double
    var discountedPrice: Double
    var isFree: Bool
    
    var pickupStart: Date
    var pickupEnd: Date
    var status: ListingStatus
    
    var createdAt: Date
    var updatedAt: Date
    var expiresAt: Date
    
    var claimedBy: String?
    var claimedAt: Date?
    
    // Computed properties
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    var isAlmostGone: Bool {
        quantity <= 2
    }
    
    var discountPercentage: Int {
        guard originalPrice > 0 else { return 0 }
        return Int(((originalPrice - discountedPrice) / originalPrice) * 100)
    }
    
    var pickupWindowString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: pickupStart)) - \(formatter.string(from: pickupEnd))"
    }
}

enum ListingStatus: String, Codable {
    case active
    case claimed
    case completed
    case expired
    case cancelled
}

enum FoodCategory: String, Codable, CaseIterable {
    case pizza = "Pizza"
    case burgers = "Burgers"
    case sushi = "Sushi"
    case pasta = "Pasta"
    case salads = "Salads"
    case sandwiches = "Sandwiches"
    case breakfast = "Breakfast"
    case desserts = "Desserts"
    case bakery = "Bakery"
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case seafood = "Seafood"
    case chinese = "Chinese"
    case indian = "Indian"
    case mexican = "Mexican"
    case thai = "Thai"
    case italian = "Italian"
    case japanese = "Japanese"
    case mediterranean = "Mediterranean"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .pizza: return "🍕"
        case .burgers: return "🍔"
        case .sushi: return "🍣"
        case .pasta: return "🍝"
        case .salads: return "🥗"
        case .sandwiches: return "🥪"
        case .breakfast: return "🍳"
        case .desserts: return "🍰"
        case .bakery: return "🥐"
        case .vegetarian: return "🥕"
        case .vegan: return "🌱"
        case .seafood: return "🦞"
        case .chinese: return "🥡"
        case .indian: return "🍛"
        case .mexican: return "🌮"
        case .thai: return "🍜"
        case .italian: return "🍝"
        case .japanese: return "🍱"
        case .mediterranean: return "🫒"
        case .other: return "🍴"
        }
    }
}

// MARK: - Order
struct Order: Identifiable, Codable {
    let id: String
    var listingId: String
    var listing: Listing?
    var customerId: String
    var customerName: String
    var customerPhone: String?
    var restaurantId: String
    var restaurantName: String
    
    var quantity: Int
    var totalPrice: Double
    var status: OrderStatus
    
    var pickupCode: String
    var pickupTime: Date
    var createdAt: Date
    var completedAt: Date?
    
    var paymentId: String?
    var refundId: String?
    
    var customerNotes: String?
    var restaurantNotes: String?
}

enum OrderStatus: String, Codable {
    case pending
    case confirmed
    case ready
    case completed
    case cancelled
    case noShow
}

// MARK: - Message
struct Message: Identifiable, Codable {
    let id: String
    var conversationId: String
    var senderId: String
    var senderName: String
    var text: String
    var createdAt: Date
    var isRead: Bool
}

struct Conversation: Identifiable, Codable {
    let id: String
    var participants: [String]
    var orderId: String
    var lastMessage: Message?
    var updatedAt: Date
}

// MARK: - Impact Stats
struct ImpactStats: Codable {
    var totalMealsSaved: Int
    var totalCO2Reduced: Double
    var totalFoodRescued: Double
    var totalUsers: Int
    var totalRestaurants: Int
    
    var co2InPounds: Double {
        co2Reduced * 2.20462
    }
    
    var foodInPounds: Double {
        foodRescued * 2.20462
    }
}

// MARK: - Notification
struct AppNotification: Identifiable, Codable {
    let id: String
    var userId: String
    var title: String
    var body: String
    var type: NotificationType
    var relatedId: String?
    var isRead: Bool
    var createdAt: Date
}

enum NotificationType: String, Codable {
    case newListing
    case orderConfirmed
    case orderReady
    case orderCompleted
    case orderCancelled
    case newMessage
    case impactMilestone
    case reminderPickup
    case listingExpiring
}

// MARK: - Payment
struct PaymentMethod: Identifiable, Codable {
    let id: String
    var type: PaymentType
    var last4: String?
    var brand: String?
    var expiryMonth: Int?
    var expiryYear: Int?
    var isDefault: Bool
}

enum PaymentType: String, Codable {
    case card
    case applePay
    case googlePay
}

struct PaymentIntent: Codable {
    let id: String
    var amount: Double
    var currency: String
    var status: String
    var clientSecret: String?
}
