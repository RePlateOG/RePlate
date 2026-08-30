//
//  Extensions.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import Combine
import CoreLocation
import Network

// MARK: - View Extensions
extension View {
    /// Hides the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Applies a card style with shadow
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xxl)
            .shadow(color: Color.black.opacity(0.05), radius: Theme.Shadows.lg, y: Theme.Shadows.sm)
    }
    
    /// Applies conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Date Extensions
extension Date {
    /// Returns a human-readable time ago string
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is in the past
    var isPast: Bool {
        self < Date()
    }
    
    /// Check if date is in the future
    var isFuture: Bool {
        self > Date()
    }
    
    /// Returns time until date in minutes
    var minutesUntil: Int {
        Int(self.timeIntervalSinceNow / 60)
    }
}

// MARK: - String Extensions
extension String {
    /// Validate email format
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Returns initials from name
    var initials: String {
        let components = self.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        return String(initials).uppercased()
    }
    
    /// Truncate string to length
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
}

// MARK: - Double Extensions
extension Double {
    /// Format as currency
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    /// Format as distance in miles
    var asMiles: String {
        String(format: "%.1f mi", self)
    }
    
    /// Format as weight in lbs
    var asLbs: String {
        String(format: "%.1f lbs", self)
    }
    
    /// Format as CO2 in kg
    var asCO2: String {
        if self >= 1000 {
            return String(format: "%.1f t", self / 1000)
        }
        return String(format: "%.1f kg", self)
    }
}

// MARK: - Int Extensions
extension Int {
    /// Format with thousands separator
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - CLLocation Extensions
extension CLLocation {
    /// Calculate distance to another location in miles
    func distance(to location: CLLocation) -> Double {
        let distanceInMeters = self.distance(from: location)
        return distanceInMeters / 1609.34 // Convert to miles
    }
}

// MARK: - Color Extensions
extension Color {
    /// Create color from RGB values
    init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Array Extensions
extension Array {
    /// Safely access element at index
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - URL Extensions
extension URL {
    /// Check if URL is valid
    var isValid: Bool {
        UIApplication.shared.canOpenURL(self)
    }
}

// MARK: - UIImage Extensions
extension UIImage {
    /// Resize image to max dimension
    func resized(to maxDimension: CGFloat) -> UIImage? {
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Compress image to target size in KB
    func compressed(to targetSizeKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        let targetBytes = targetSizeKB * 1024
        
        guard var imageData = self.jpegData(compressionQuality: compression) else {
            return nil
        }
        
        while imageData.count > targetBytes && compression > 0.1 {
            compression -= 0.1
            if let compressedData = self.jpegData(compressionQuality: compression) {
                imageData = compressedData
            }
        }
        
        return imageData
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    /// App version
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// App build number
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Full version string
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let userDidSignIn = Notification.Name("userDidSignIn")
    static let userDidSignOut = Notification.Name("userDidSignOut")
    static let newOrderReceived = Notification.Name("newOrderReceived")
    static let orderStatusUpdated = Notification.Name("orderStatusUpdated")
    static let newMessageReceived = Notification.Name("newMessageReceived")
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let colorScheme = "colorScheme"
        static let currentUser = "currentUser"
        static let notificationsEnabled = "notificationsEnabled"
        static let locationPermissionAsked = "locationPermissionAsked"
    }
}

// MARK: - Error Extensions
enum AppError: LocalizedError {
    case networkError
    case authenticationFailed
    case invalidData
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .invalidData:
            return "Invalid data received. Please try again."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

// MARK: - Debouncer
class Debouncer {
    private var timer: Timer?
    
    func debounce(delay: TimeInterval, action: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            action()
        }
    }
}

// MARK: - Loading State
enum LoadingState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}

// MARK: - Validation
struct Validator {
    static func validateEmail(_ email: String) -> Bool {
        email.isValidEmail
    }
    
    static func validatePassword(_ password: String) -> (isValid: Bool, message: String) {
        if password.count < 8 {
            return (false, "Password must be at least 8 characters")
        }
        if !password.contains(where: { $0.isNumber }) {
            return (false, "Password must contain at least one number")
        }
        if !password.contains(where: { $0.isUppercase }) {
            return (false, "Password must contain at least one uppercase letter")
        }
        return (true, "Password is valid")
    }
    
    static func validatePhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone.replacingOccurrences(of: " ", with: ""))
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }
}

// MARK: - Image Cache
class ImageCache {
    static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Sign in with Apple nonce helpers

import CryptoKit

func randomNonceString(length: Int = 32) -> String {
    var randomBytes = [UInt8](repeating: 0, count: length)
    _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { charset[Int($0) % charset.count] })
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
