# RePlate Implementation Guide

## Overview
This guide provides detailed instructions for completing the RePlate app implementation, including backend integration, payment processing, and additional features.

## Current Implementation Status

### ✅ Completed Features
- Complete UI/UX for all screens
- MVVM architecture with proper separation
- Design system with theme support
- Authentication flow (UI ready)
- Customer home feed and listing details
- Restaurant dashboard and posting flow
- Order management interface
- Search with filters
- Messaging interface
- Profile and settings
- Onboarding experience
- Dark mode support
- Reusable component library

### 🔄 Needs Backend Integration
- API service layer
- Real authentication with Firebase/Supabase
- Database operations
- Real-time updates
- Push notifications
- Image upload and storage
- Payment processing with Stripe

## Backend Integration Steps

### 1. API Service Setup

Create `APIService.swift`:
```swift
import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "YOUR_API_BASE_URL"
    private let session = URLSession.shared
    
    // MARK: - Authentication
    func signIn(email: String, password: String) async throws -> User {
        // Implement API call
    }
    
    func signUp(user: User, password: String) async throws -> User {
        // Implement API call
    }
    
    func signOut() async throws {
        // Implement API call
    }
    
    // MARK: - Listings
    func fetchListings(filters: SearchFilters?) async throws -> [FoodListing] {
        // Implement API call
    }
    
    func createListing(_ listing: FoodListing) async throws -> FoodListing {
        // Implement API call
    }
    
    func updateListing(_ listing: FoodListing) async throws -> FoodListing {
        // Implement API call
    }
    
    func deleteListing(id: String) async throws {
        // Implement API call
    }
    
    // MARK: - Orders
    func createOrder(_ order: Order) async throws -> Order {
        // Implement API call
    }
    
    func fetchOrders(for userId: String) async throws -> [Order] {
        // Implement API call
    }
    
    func updateOrderStatus(orderId: String, status: Order.OrderStatus) async throws {
        // Implement API call
    }
    
    // MARK: - Messages
    func sendMessage(_ message: Message) async throws -> Message {
        // Implement API call
    }
    
    func fetchMessages(for conversationId: String) async throws -> [Message] {
        // Implement API call
    }
    
    // MARK: - User
    func updateUser(_ user: User) async throws -> User {
        // Implement API call
    }
    
    func deleteAccount(userId: String) async throws {
        // Implement API call
    }
}
```

### 2. Firebase Setup (Option A)

1. **Install Firebase SDK**:
   - Add Firebase to your Xcode project via Swift Package Manager
   - Add `GoogleService-Info.plist` to your project

2. **Initialize Firebase** in `RePlateApp.swift`:
```swift
import Firebase

@main
struct RePlateApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ...
}
```

3. **Create `FirebaseService.swift`**:
```swift
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Authentication
    func signIn(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return try await fetchUser(userId: result.user.uid)
    }
    
    // Firestore operations
    func fetchListings() async throws -> [FoodListing] {
        let snapshot = try await db.collection("listings")
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: FoodListing.self)
        }
    }
    
    // Image upload
    func uploadImage(_ image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "", code: -1)
        }
        
        let ref = storage.reference().child(path)
        _ = try await ref.putDataAsync(imageData)
        return try await ref.downloadURL().absoluteString
    }
}
```

### 3. Supabase Setup (Option B)

1. **Install Supabase SDK**:
```swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "1.0.0")
]
```

2. **Create `SupabaseService.swift`**:
```swift
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client = SupabaseClient(
        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
        supabaseKey: "YOUR_SUPABASE_KEY"
    )
    
    // Authentication
    func signIn(email: String, password: String) async throws -> User {
        let response = try await client.auth.signIn(email: email, password: password)
        // Map to your User model
    }
    
    // Database operations
    func fetchListings() async throws -> [FoodListing] {
        let response: [FoodListing] = try await client
            .from("listings")
            .select()
            .eq("status", value: "active")
            .execute()
            .value
        
        return response
    }
}
```

### 4. Payment Integration with Stripe

1. **Install Stripe SDK**:
```swift
dependencies: [
    .package(url: "https://github.com/stripe/stripe-ios", from: "23.0.0")
]
```

2. **Create `PaymentService.swift`**:
```swift
import StripePaymentSheet

class PaymentService {
    static let shared = PaymentService()
    
    func createPaymentIntent(amount: Double, currency: String = "usd") async throws -> String {
        // Call your backend to create payment intent
        // Return client secret
    }
    
    func presentPaymentSheet(
        clientSecret: String,
        from viewController: UIViewController
    ) async throws -> Bool {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "RePlate"
        configuration.applePay = .init(merchantId: "YOUR_MERCHANT_ID", merchantCountryCode: "US")
        
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            paymentSheet.present(from: viewController) { result in
                switch result {
                case .completed:
                    continuation.resume(returning: true)
                case .canceled:
                    continuation.resume(returning: false)
                case .failed(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
```

3. **Update CheckoutView** to use real payments:
```swift
func processCheckout() async {
    isProcessing = true
    defer { isProcessing = false }
    
    do {
        // Create payment intent
        let clientSecret = try await PaymentService.shared.createPaymentIntent(
            amount: totalAmount
        )
        
        // Present payment sheet
        let success = try await PaymentService.shared.presentPaymentSheet(
            clientSecret: clientSecret,
            from: UIApplication.shared.windows.first?.rootViewController ?? UIViewController()
        )
        
        if success {
            // Create order
            let order = Order(
                id: UUID().uuidString,
                listingId: listing.id,
                // ... other fields
            )
            
            try await APIService.shared.createOrder(order)
            showSuccess = true
            hapticFeedback(.success)
        }
    } catch {
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

### 5. Push Notifications

1. **Request permissions** in `AppState.swift`:
```swift
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
```

2. **Handle notifications** in `RePlateApp.swift`:
```swift
import UserNotifications

@main
struct RePlateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // ...
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // Send token to your backend
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
```

### 6. Real-time Updates

For real-time order and message updates, implement WebSocket connection:

```swift
import Combine

class RealtimeService: ObservableObject {
    static let shared = RealtimeService()
    @Published var updates: [String: Any] = [:]
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    func connect() {
        let url = URL(string: "wss://your-websocket-url")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    // Handle message
                    self?.handleMessage(text)
                case .data(let data):
                    // Handle data
                    break
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ message: String) {
        // Parse and handle message
    }
}
```

### 7. Location Services

Update `LocationService` to integrate with listings:

```swift
extension HomeViewModel {
    func loadNearbyListings() async {
        guard let userLocation = LocationService.shared.userLocation else {
            await loadListings()
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let allListings = try await APIService.shared.fetchListings(filters: nil)
            
            // Calculate distances and sort
            listings = allListings
                .map { listing -> (listing: FoodListing, distance: Double) in
                    guard let restaurant = listing.restaurant else {
                        return (listing, Double.infinity)
                    }
                    
                    let restaurantLocation = CLLocation(
                        latitude: restaurant.location.latitude,
                        longitude: restaurant.location.longitude
                    )
                    
                    let distance = userLocation.distance(to: restaurantLocation)
                    return (listing, distance)
                }
                .sorted { $0.distance < $1.distance }
                .map { $0.listing }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 8. Image Optimization

Optimize images before upload:

```swift
extension PostListingViewModel {
    func optimizeAndUploadImages() async throws -> [String] {
        var urls: [String] = []
        
        for image in selectedImages {
            // Resize
            guard let resized = image.resized(to: 1200) else { continue }
            
            // Compress
            guard let compressed = resized.compressed(to: 500) else { continue }
            
            // Upload
            let path = "listings/\(UUID().uuidString).jpg"
            let url = try await FirebaseService.shared.uploadImage(UIImage(data: compressed)!, path: path)
            urls.append(url)
        }
        
        return urls
    }
}
```

## Testing Checklist

### Unit Tests
- [ ] Model validation
- [ ] View model business logic
- [ ] API service calls (mocked)
- [ ] Utility functions
- [ ] Extensions

### UI Tests
- [ ] Onboarding flow
- [ ] Sign in/up flow
- [ ] Listing creation
- [ ] Order placement
- [ ] Search and filters
- [ ] Profile management

### Integration Tests
- [ ] End-to-end order flow
- [ ] Payment processing
- [ ] Real-time updates
- [ ] Push notifications

## Performance Optimization

1. **Image Caching**: Already implemented in `Extensions.swift`
2. **Lazy Loading**: Use `LazyVStack` and `LazyVGrid` (already implemented)
3. **Pagination**: Implement for long lists
4. **Background Tasks**: Use `Task` for heavy operations
5. **Memory Management**: Profile with Instruments

## App Store Submission Checklist

### Pre-submission
- [ ] Add app icons (all required sizes)
- [ ] Add launch screen
- [ ] Configure Info.plist with required permissions descriptions:
  - NSLocationWhenInUseUsageDescription
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription
  - NSUserNotificationsUsageDescription
- [ ] Set proper bundle identifier
- [ ] Configure signing & capabilities
- [ ] Test on multiple devices and iOS versions
- [ ] Privacy Policy URL configured
- [ ] Terms of Service URL configured
- [ ] Support URL configured

### App Store Connect
- [ ] Create app record
- [ ] Add screenshots for all device sizes
- [ ] Write compelling app description
- [ ] Add keywords for ASO
- [ ] Set pricing and availability
- [ ] Submit for review

## Monitoring & Analytics

Consider integrating:
- **Firebase Analytics** for user behavior
- **Crashlytics** for crash reporting
- **App Store Connect API** for metrics
- **Custom dashboard** for business metrics

## Maintenance Plan

### Regular Updates
- Monitor crash reports
- Review user feedback
- Update dependencies
- Add requested features
- Improve performance
- Fix bugs promptly

### Scaling Considerations
- Database indexing for performance
- CDN for image delivery
- Caching strategy
- API rate limiting
- Load balancing

## Additional Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Stripe iOS SDK](https://stripe.com/docs/payments/accept-a-payment?platform=ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

## Support

For implementation questions or issues:
1. Review this guide thoroughly
2. Check Apple Developer documentation
3. Search Stack Overflow
4. Review GitHub issues for dependencies
5. Contact the development team

---

**Good luck with your RePlate implementation! 🚀**
