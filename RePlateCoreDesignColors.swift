//
//  Colors.swift
//  RePlate
//
//  Design system colors with dark mode support
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let primaryGradientStart = Color(hex: "118b50")
    static let primaryGradientEnd = Color(hex: "5db996")
    static let accent = Color(hex: "caf8a5")
    
    // MARK: - Semantic Colors
    static let background = Color("Background")
    static let secondaryBackground = Color("SecondaryBackground")
    static let cardBackground = Color("CardBackground")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    static let divider = Color("Divider")
    
    // MARK: - Status Colors
    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
    static let info = Color(hex: "007AFF")
    
    // MARK: - Gradient
    static let primaryGradient = LinearGradient(
        colors: [primaryGradientStart, primaryGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
