//
//  RPButton.swift
//  RePlate
//
//  Reusable button component with multiple styles
//

import SwiftUI

struct RPButton: View {
    let title: String
    let icon: String?
    let style: RPButtonStyle
    let size: RPButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        style: RPButtonStyle = .primary,
        size: RPButtonSize = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.medium()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(size.iconFont)
                    }
                    
                    Text(title)
                        .font(size.font)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: size.maxWidth)
            .frame(height: size.height)
            .foregroundColor(style.foregroundColor)
            .background(style.background(isDisabled: isDisabled || isLoading))
            .cornerRadius(CornerRadius.xxl)
            .shadow(
                color: style.shadowColor(isDisabled: isDisabled || isLoading),
                radius: Shadow.medium.radius,
                x: Shadow.medium.x,
                y: Shadow.medium.y
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.6 : 1.0)
    }
}

enum RPButtonStyle {
    case primary
    case secondary
    case outline
    case destructive
    case ghost
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .primaryGradientStart
        case .outline:
            return .primaryGradientStart
        case .destructive:
            return .white
        case .ghost:
            return .primaryGradientStart
        }
    }
    
    func background(isDisabled: Bool) -> AnyView {
        if isDisabled {
            return AnyView(Color.gray.opacity(0.3))
        }
        
        switch self {
        case .primary:
            return AnyView(Color.primaryGradient)
        case .secondary:
            return AnyView(Color.accent)
        case .outline:
            return AnyView(Color.clear)
        case .destructive:
            return AnyView(Color.error)
        case .ghost:
            return AnyView(Color.clear)
        }
    }
    
    func shadowColor(isDisabled: Bool) -> Color {
        if isDisabled {
            return .clear
        }
        
        switch self {
        case .primary:
            return Color.primaryGradientStart.opacity(0.3)
        case .secondary:
            return Color.accent.opacity(0.3)
        case .outline:
            return .clear
        case .destructive:
            return Color.error.opacity(0.3)
        case .ghost:
            return .clear
        }
    }
}

enum RPButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 36
        case .medium: return 44
        case .large: return 56
        }
    }
    
    var font: Font {
        switch self {
        case .small: return .labelMedium
        case .medium: return .labelLarge
        case .large: return .titleMedium
        }
    }
    
    var iconFont: Font {
        switch self {
        case .small: return .system(size: 14)
        case .medium: return .system(size: 16)
        case .large: return .system(size: 18)
        }
    }
    
    var maxWidth: CGFloat? {
        switch self {
        case .small: return nil
        case .medium: return nil
        case .large: return .infinity
        }
    }
}

// MARK: - Preview
struct RPButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.md) {
            RPButton("Primary Button", icon: "checkmark.circle.fill") {
                print("Primary tapped")
            }
            
            RPButton("Secondary", style: .secondary) {
                print("Secondary tapped")
            }
            
            RPButton("Outline", style: .outline) {
                print("Outline tapped")
            }
            
            RPButton("Loading", isLoading: true) {
                print("Loading")
            }
            
            RPButton("Disabled", isDisabled: true) {
                print("Disabled")
            }
            
            RPButton("Small", size: .small) {
                print("Small")
            }
        }
        .padding()
    }
}
