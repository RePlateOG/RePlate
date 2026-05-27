//
//  Theme.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

struct Theme {
    
    // MARK: - Colors
    struct Colors {
        // Primary Brand Colors - Enhanced Green Palette
        static let primaryGradientStart = Color(hex: "118b50")
        static let primaryGradientEnd = Color(hex: "5db996")
        static let primaryDark = Color(hex: "0d6b3d")
        static let primaryLight = Color(hex: "7dcaa8")
        static let accent = Color(hex: "caf8a5")
        static let accentDark = Color(hex: "a8d687")
        
        // Premium Gradients
        static let primaryGradient = LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let primaryGradientVertical = LinearGradient(
            colors: [primaryGradientStart, primaryGradientEnd],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let heroGradient = LinearGradient(
            colors: [
                primaryGradientStart,
                primaryGradientEnd,
                accent.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let subtleGradient = LinearGradient(
            colors: [
                accent.opacity(0.15),
                primaryLight.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let glassGradient = LinearGradient(
            colors: [
                Color.white.opacity(0.25),
                Color.white.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Surface Colors - Enhanced Hierarchy
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Elevated Surfaces
        static let cardBackground = Color(.secondarySystemBackground)
        static let elevatedCard = Color(.systemBackground)
        static let floatingCard = Color(.systemBackground)
        
        // Text Hierarchy
        static let label = Color(.label)
        static let secondaryLabel = Color(.secondaryLabel)
        static let tertiaryLabel = Color(.tertiaryLabel)
        static let placeholderLabel = Color(.placeholderText)
        
        // Semantic Colors - Premium Versions
        static let success = Color(hex: "34C759")
        static let successLight = Color(hex: "34C759").opacity(0.15)
        static let warning = Color(hex: "FF9500")
        static let warningLight = Color(hex: "FF9500").opacity(0.15)
        static let error = Color(hex: "FF3B30")
        static let errorLight = Color(hex: "FF3B30").opacity(0.15)
        static let info = Color(hex: "007AFF")
        static let infoLight = Color(hex: "007AFF").opacity(0.15)
        
        // Impact Colors (for environmental metrics)
        static let impactGreen = Color(hex: "118b50")
        static let impactGold = Color(hex: "FFD700")
        static let impactBlue = Color(hex: "5DB9E0")
        
        // Overlay & Glass
        static let overlay = Color.black.opacity(0.4)
        static let glassOverlay = Color.white.opacity(0.1)
        static let darkGlass = Color.black.opacity(0.05)
        
        // Dividers & Borders
        static let divider = Color(.separator)
        static let border = Color(.separator).opacity(0.5)
        static let focusBorder = primaryGradientStart
    }
    
    // MARK: - Typography - Premium Hierarchy
    struct Typography {
        // Display Styles (Hero Sections)
        static let display = Font.system(size: 48, weight: .bold, design: .rounded)
        static let displayHeavy = Font.system(size: 48, weight: .heavy, design: .rounded)
        
        // Large Titles (Page Headers)
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let largeTitleHeavy = Font.system(size: 34, weight: .heavy, design: .rounded)
        
        // Titles (Section Headers)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Headlines & Body
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let headlineMedium = Font.system(size: 17, weight: .medium, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
        static let bodySemibold = Font.system(size: 17, weight: .semibold, design: .default)
        
        // Supporting Text
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let calloutMedium = Font.system(size: 16, weight: .medium, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let subheadlineMedium = Font.system(size: 15, weight: .medium, design: .default)
        
        // Small Text
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let footnoteMedium = Font.system(size: 13, weight: .medium, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let captionSemibold = Font.system(size: 12, weight: .semibold, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        // Special Purpose
        static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let navigationTitle = Font.system(size: 17, weight: .semibold, design: .default)
        static let tag = Font.system(size: 11, weight: .bold, design: .rounded)
        static let monospaced = Font.system(size: 17, weight: .medium, design: .monospaced)
    }
    
    // MARK: - Spacing - Refined Scale
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let base: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let huge: CGFloat = 48
        static let massive: CGFloat = 64
        
        // Semantic Spacing
        static let cardPadding: CGFloat = 20
        static let screenPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 32
        static let itemSpacing: CGFloat = 16
        static let compactSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius - Modern Scale
    struct CornerRadius {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let base: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 28
        static let xxxl: CGFloat = 32
        
        // Semantic Radii
        static let button: CGFloat = 16
        static let card: CGFloat = 24
        static let cardLarge: CGFloat = 28
        static let sheet: CGFloat = 32
        static let pill: CGFloat = 100
    }
    
    // MARK: - Shadows - Layered Depth System
    struct Shadows {
        // Shadow Layers
        static func card(color: Color = Color.black.opacity(0.08)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 16, x: 0, y: 4)
                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        
        static func floating(color: Color = Color.black.opacity(0.12)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 24, x: 0, y: 8)
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        
        static func elevated(color: Color = Color.black.opacity(0.06)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 12, x: 0, y: 4)
        }
        
        static func subtle(color: Color = Color.black.opacity(0.04)) -> some View {
            EmptyView()
                .shadow(color: color, radius: 8, x: 0, y: 2)
        }
        
        static func glow(color: Color) -> some View {
            EmptyView()
                .shadow(color: color.opacity(0.4), radius: 20, x: 0, y: 8)
                .shadow(color: color.opacity(0.2), radius: 40, x: 0, y: 16)
        }
        
        // Legacy Support
        static let sm: CGFloat = 2
        static let md: CGFloat = 4
        static let lg: CGFloat = 8
    }
    
    // MARK: - Animation - Fluid Motion System
    struct Animation {
        // Timing Curves
        static let fast: SwiftUI.Animation = .easeInOut(duration: 0.2)
        static let standard: SwiftUI.Animation = .easeInOut(duration: 0.3)
        static let moderate: SwiftUI.Animation = .easeInOut(duration: 0.4)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 0.5)
        
        // Spring Animations
        static let spring: SwiftUI.Animation = .spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)
        static let springBouncy: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)
        static let springSnappy: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
        static let springSmooth: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0)
        
        // Interaction Animations
        static let buttonPress: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.6)
        static let cardExpand: SwiftUI.Animation = .spring(response: 0.4, dampingFraction: 0.8)
        static let slideIn: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.85)
        
        // Utility
        static let instant: SwiftUI.Animation = .linear(duration: 0.001)
    }
    
    // MARK: - Layout Constants
    struct Layout {
        static let maxCardWidth: CGFloat = 430
        static let maxContentWidth: CGFloat = 600
        static let fabSize: CGFloat = 64
        static let fabOffset: CGFloat = 24
        static let tabBarHeight: CGFloat = 88
        static let headerHeight: CGFloat = 56
        static let heroHeight: CGFloat = 240
        static let minTapTarget: CGFloat = 44
    }
    
    // MARK: - Blur Effects
    struct Blur {
        static let ultraThin: Material = .ultraThinMaterial
        static let thin: Material = .thinMaterial
        static let regular: Material = .regularMaterial
        static let thick: Material = .thickMaterial
        static let ultraThick: Material = .ultraThickMaterial
    }
}

// MARK: - Color Extension for Hex
extension Color {
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
