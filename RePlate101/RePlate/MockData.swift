//
//  MockData.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/27/26.
//

import Foundation
import CoreLocation

// MARK: - Mock Data
struct MockData {
    
    // MARK: - Sample Restaurants
    static let sampleRestaurant1 = Restaurant(
        id: "1",
        name: "Green Leaf Bistro",
        description: "Farm-to-table restaurant serving organic, locally sourced meals",
        address: "123 Main Street, San Francisco, CA 94102",
        location: Restaurant.LocationCoordinate(latitude: 37.7749, longitude: -122.4194),
        phoneNumber: "+1 (415) 555-0123",
        email: "contact@greenleafbistro.com",
        imageURL: nil,
        coverImageURL: nil,
        cuisine: ["Organic", "Farm-to-Table", "Vegetarian"],
        rating: 4.8,
        totalReviews: 342,
        verified: true,
        activeListingsCount: 3,
        isPremium: true
    )
    
    static let sampleRestaurant2 = Restaurant(
        id: "2",
        name: "Sunset Café",
        description: "Cozy neighborhood café with fresh pastries and coffee",
        address: "456 Oak Avenue, San Francisco, CA 94103",
        location: Restaurant.LocationCoordinate(latitude: 37.7849, longitude: -122.4094),
        phoneNumber: "+1 (415) 555-0124",
        email: "hello@sunsetcafe.com",
        imageURL: nil,
        coverImageURL: nil,
        cuisine: ["Café", "Bakery", "Coffee"],
        rating: 4.6,
        totalReviews: 189,
        verified: true,
        activeListingsCount: 2,
        isPremium: false
    )
    
    static let sampleRestaurant3 = Restaurant(
        id: "3",
        name: "Ocean View Grill",
        description: "Seafood restaurant with ocean views",
        address: "789 Beach Boulevard, San Francisco, CA 94104",
        location: Restaurant.LocationCoordinate(latitude: 37.7949, longitude: -122.3994),
        phoneNumber: "+1 (415) 555-0125",
        email: "info@oceanviewgrill.com",
        imageURL: nil,
        coverImageURL: nil,
        cuisine: ["Seafood", "Grill", "American"],
        rating: 4.7,
        totalReviews: 256,
        verified: true,
        activeListingsCount: 4,
        isPremium: true
    )
    
    // MARK: - Sample Users
    static let sampleCustomer = User(
        id: "user1",
        email: "customer@example.com",
        name: "John Doe",
        phoneNumber: "+1 (415) 555-0100",
        profileImageURL: nil,
        accountType: .customer,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        verifiedRestaurant: false,
        mealsSaved: 24,
        co2Reduced: 60.0,
        foodRescued: 48.5
    )
    
    static let sampleRestaurantUser = User(
        id: "user2",
        email: "restaurant@example.com",
        name: "Jane Smith",
        phoneNumber: "+1 (415) 555-0101",
        profileImageURL: nil,
        accountType: .restaurant,
        createdAt: Date().addingTimeInterval(-86400 * 60),
        verifiedRestaurant: true,
        mealsSaved: 156,
        co2Reduced: 390.0,
        foodRescued: 312.0
    )
    
    // MARK: - Sample Listings
    static let sampleListing1 = FoodListing(
        id: "listing1",
        restaurantId: "1",
        restaurant: sampleRestaurant1,
        title: "Fresh Garden Salad Mix",
        description: "Assorted fresh garden salads with organic vegetables, perfect for a healthy meal. Includes Caesar salad, Greek salad, and mixed greens.",
        category: .meals,
        imageURLs: [],
        originalPrice: 15.99,
        discountedPrice: 7.99,
        isFree: false,
        quantity: 5,
        availableQuantity: 3,
        pickupStartTime: Date().addingTimeInterval(3600),
        pickupEndTime: Date().addingTimeInterval(7200),
        status: .active,
        createdAt: Date().addingTimeInterval(-3600),
        expiresAt: Date().addingTimeInterval(7200),
        tags: ["organic", "fresh", "healthy"],
        dietaryInfo: [.vegetarian, .vegan, .glutenFree]
    )
    
    static let sampleListing2 = FoodListing(
        id: "listing2",
        restaurantId: "2",
        restaurant: sampleRestaurant2,
        title: "Artisan Bread & Pastries",
        description: "Freshly baked artisan bread and assorted pastries from this morning. Includes croissants, baguettes, and Danish pastries.",
        category: .bakery,
        imageURLs: [],
        originalPrice: 12.50,
        discountedPrice: 0.00,
        isFree: true,
        quantity: 8,
        availableQuantity: 6,
        pickupStartTime: Date().addingTimeInterval(1800),
        pickupEndTime: Date().addingTimeInterval(5400),
        status: .active,
        createdAt: Date().addingTimeInterval(-1800),
        expiresAt: Date().addingTimeInterval(5400),
        tags: ["bakery", "fresh", "artisan"],
        dietaryInfo: [.vegetarian]
    )
    
    static let sampleListing3 = FoodListing(
        id: "listing3",
        restaurantId: "3",
        restaurant: sampleRestaurant3,
        title: "Grilled Salmon Platter",
        description: "Premium grilled salmon with roasted vegetables and wild rice. Restaurant quality meal at a fraction of the price!",
        category: .meals,
        imageURLs: [],
        originalPrice: 28.99,
        discountedPrice: 12.99,
        isFree: false,
        quantity: 4,
        availableQuantity: 2,
        pickupStartTime: Date().addingTimeInterval(2700),
        pickupEndTime: Date().addingTimeInterval(6300),
        status: .active,
        createdAt: Date().addingTimeInterval(-900),
        expiresAt: Date().addingTimeInterval(6300),
        tags: ["seafood", "healthy", "protein"],
        dietaryInfo: [.glutenFree, .dairyFree]
    )
    
    static let sampleListing4 = FoodListing(
        id: "listing4",
        restaurantId: "1",
        restaurant: sampleRestaurant1,
        title: "Organic Fruit Bowl",
        description: "Mixed seasonal organic fruits, perfect for a healthy snack or dessert.",
        category: .produce,
        imageURLs: [],
        originalPrice: 8.99,
        discountedPrice: 3.99,
        isFree: false,
        quantity: 10,
        availableQuantity: 8,
        pickupStartTime: Date().addingTimeInterval(3600),
        pickupEndTime: Date().addingTimeInterval(10800),
        status: .active,
        createdAt: Date().addingTimeInterval(-2400),
        expiresAt: Date().addingTimeInterval(10800),
        tags: ["fruit", "organic", "healthy"],
        dietaryInfo: [.vegan, .glutenFree, .dairyFree]
    )
    
    static let sampleListing5 = FoodListing(
        id: "listing5",
        restaurantId: "2",
        restaurant: sampleRestaurant2,
        title: "Gourmet Dessert Box",
        description: "Assorted gourmet desserts including chocolate cake, tiramisu, and fruit tarts.",
        category: .desserts,
        imageURLs: [],
        originalPrice: 18.99,
        discountedPrice: 8.99,
        isFree: false,
        quantity: 6,
        availableQuantity: 1,
        pickupStartTime: Date().addingTimeInterval(1800),
        pickupEndTime: Date().addingTimeInterval(5400),
        status: .active,
        createdAt: Date().addingTimeInterval(-3600),
        expiresAt: Date().addingTimeInterval(3600),
        tags: ["dessert", "sweet", "gourmet"],
        dietaryInfo: [.vegetarian]
    )
    
    static var sampleListings: [FoodListing] {
        [sampleListing1, sampleListing2, sampleListing3, sampleListing4, sampleListing5]
    }
    
    // MARK: - Sample Orders
    static let sampleOrder1 = Order(
        id: "order1",
        listingId: "listing1",
        listing: sampleListing1,
        customerId: "user1",
        customer: sampleCustomer,
        restaurantId: "1",
        restaurant: sampleRestaurant1,
        quantity: 2,
        totalAmount: 15.98,
        status: .pending,
        pickupCode: "A1B2C3",
        pickupTime: Date().addingTimeInterval(3600),
        pickupWindowStart: Date().addingTimeInterval(3600),
        pickupWindowEnd: Date().addingTimeInterval(7200),
        createdAt: Date().addingTimeInterval(-1800),
        completedAt: nil,
        notes: nil,
        paymentId: "pay_123"
    )
    
    static let sampleOrder2 = Order(
        id: "order2",
        listingId: "listing2",
        listing: sampleListing2,
        customerId: "user1",
        customer: sampleCustomer,
        restaurantId: "2",
        restaurant: sampleRestaurant2,
        quantity: 1,
        totalAmount: 0.00,
        status: .confirmed,
        pickupCode: "D4E5F6",
        pickupTime: Date().addingTimeInterval(2700),
        pickupWindowStart: Date().addingTimeInterval(1800),
        pickupWindowEnd: Date().addingTimeInterval(5400),
        createdAt: Date().addingTimeInterval(-900),
        completedAt: nil,
        notes: "Please include napkins",
        paymentId: nil
    )
    
    static let sampleOrder3 = Order(
        id: "order3",
        listingId: "listing3",
        listing: sampleListing3,
        customerId: "user1",
        customer: sampleCustomer,
        restaurantId: "3",
        restaurant: sampleRestaurant3,
        quantity: 1,
        totalAmount: 12.99,
        status: .ready,
        pickupCode: "G7H8I9",
        pickupTime: Date().addingTimeInterval(1800),
        pickupWindowStart: Date().addingTimeInterval(2700),
        pickupWindowEnd: Date().addingTimeInterval(6300),
        createdAt: Date().addingTimeInterval(-3600),
        completedAt: nil,
        notes: nil,
        paymentId: "pay_124"
    )
    
    static let sampleOrder4 = Order(
        id: "order4",
        listingId: "listing1",
        listing: sampleListing1,
        customerId: "user1",
        customer: sampleCustomer,
        restaurantId: "1",
        restaurant: sampleRestaurant1,
        quantity: 1,
        totalAmount: 7.99,
        status: .completed,
        pickupCode: "J1K2L3",
        pickupTime: Date().addingTimeInterval(-7200),
        pickupWindowStart: Date().addingTimeInterval(-10800),
        pickupWindowEnd: Date().addingTimeInterval(-3600),
        createdAt: Date().addingTimeInterval(-14400),
        completedAt: Date().addingTimeInterval(-7200),
        notes: nil,
        paymentId: "pay_125"
    )
    
    static var sampleOrders: [Order] {
        [sampleOrder1, sampleOrder2, sampleOrder3, sampleOrder4]
    }
    
    // MARK: - Sample Messages
    static let sampleMessage1 = Message(
        id: "msg1",
        orderId: "order1",
        senderId: "user1",
        receiverId: "user2",
        content: "Hi! What time can I pick up the order?",
        timestamp: Date().addingTimeInterval(-3600),
        read: true,
        messageType: .text
    )
    
    static let sampleMessage2 = Message(
        id: "msg2",
        orderId: "order1",
        senderId: "user2",
        receiverId: "user1",
        content: "Hello! You can pick it up between 6-8 PM today.",
        timestamp: Date().addingTimeInterval(-3300),
        read: true,
        messageType: .text
    )
    
    static let sampleMessage3 = Message(
        id: "msg3",
        orderId: "order1",
        senderId: "user1",
        receiverId: "user2",
        content: "Perfect! See you at 6:30 PM.",
        timestamp: Date().addingTimeInterval(-3000),
        read: false,
        messageType: .text
    )
    
    static var sampleMessages: [Message] {
        [sampleMessage1, sampleMessage2, sampleMessage3]
    }
    
    // MARK: - Sample Conversations
    static let sampleConversation1 = Conversation(
        id: "conv1",
        orderId: "order1",
        order: sampleOrder1,
        participantIds: ["user1", "user2"],
        participants: [sampleCustomer, sampleRestaurantUser],
        lastMessage: sampleMessage3,
        unreadCount: 1,
        updatedAt: Date().addingTimeInterval(-3000)
    )
    
    static var sampleConversations: [Conversation] {
        [sampleConversation1]
    }
    
    // MARK: - Sample Notifications
    static let sampleNotification1 = AppNotification(
        id: "notif1",
        userId: "user1",
        title: "Order Ready!",
        body: "Your order from Green Leaf Bistro is ready for pickup",
        type: .orderReady,
        relatedId: "order3",
        timestamp: Date().addingTimeInterval(-1800),
        read: false,
        actionURL: nil
    )
    
    static let sampleNotification2 = AppNotification(
        id: "notif2",
        userId: "user1",
        title: "New Listing Nearby",
        body: "Sunset Café just posted free pastries nearby!",
        type: .newListing,
        relatedId: "listing2",
        timestamp: Date().addingTimeInterval(-900),
        read: false,
        actionURL: nil
    )
    
    static let sampleNotification3 = AppNotification(
        id: "notif3",
        userId: "user1",
        title: "Pickup Reminder",
        body: "Don't forget to pick up your order in 30 minutes",
        type: .pickupReminder,
        relatedId: "order1",
        timestamp: Date().addingTimeInterval(-600),
        read: true,
        actionURL: nil
    )
    
    static var sampleNotifications: [AppNotification] {
        [sampleNotification1, sampleNotification2, sampleNotification3]
    }
    
    // MARK: - Sample Impact Stats
    static let sampleImpactStats = ImpactStats(
        totalMealsSaved: 12_543,
        totalCO2Reduced: 31_357.5,
        totalFoodRescued: 25_086.0,
        totalUsers: 3_421,
        totalRestaurants: 187,
        totalOrders: 8_765
    )
    
    // MARK: - Sample Payment Methods
    static let samplePaymentMethod1 = PaymentMethod(
        id: "pm1",
        type: .card,
        last4: "4242",
        brand: "Visa",
        expiryMonth: 12,
        expiryYear: 2025,
        isDefault: true
    )
    
    static let samplePaymentMethod2 = PaymentMethod(
        id: "pm2",
        type: .applePay,
        last4: "",
        brand: nil,
        expiryMonth: nil,
        expiryYear: nil,
        isDefault: false
    )
    
    static var samplePaymentMethods: [PaymentMethod] {
        [samplePaymentMethod1, samplePaymentMethod2]
    }
}
