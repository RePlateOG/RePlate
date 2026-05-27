//
//  Typography.swift
//  RePlate
//
//  Design system typography with Dynamic Type support
//

import SwiftUI

extension Font {
    // MARK: - Display
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 45, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)
    
    // MARK: - Headline
    static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    // MARK: - Title
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // MARK: - Label
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
}

// MARK: - Text Styles
extension Text {
    func textStyle(_ style: TextStyle) -> Text {
        switch style {
        case .displayLarge:
            return self.font(.displayLarge)
        case .displayMedium:
            return self.font(.displayMedium)
        case .displaySmall:
            return self.font(.displaySmall)
        case .headlineLarge:
            return self.font(.headlineLarge)
        case .headlineMedium:
            return self.font(.headlineMedium)
        case .headlineSmall:
            return self.font(.headlineSmall)
        case .titleLarge:
            return self.font(.titleLarge)
        case .titleMedium:
            return self.font(.titleMedium)
        case .titleSmall:
            return self.font(.titleSmall)
        case .bodyLarge:
            return self.font(.bodyLarge)
        case .bodyMedium:
            return self.font(.bodyMedium)
        case .bodySmall:
            return self.font(.bodySmall)
        case .labelLarge:
            return self.font(.labelLarge)
        case .labelMedium:
            return self.font(.labelMedium)
        case .labelSmall:
            return self.font(.labelSmall)
        }
    }
}

enum TextStyle {
    case displayLarge, displayMedium, displaySmall
    case headlineLarge, headlineMedium, headlineSmall
    case titleLarge, titleMedium, titleSmall
    case bodyLarge, bodyMedium, bodySmall
    case labelLarge, labelMedium, labelSmall
}
