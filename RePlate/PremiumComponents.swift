//
//  PremiumComponents.swift
//  RePlate - Premium UI Components
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import PhotosUI

// MARK: - Premium Custom Text Field
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(isFocused ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryLabel], startPoint: .top, endPoint: .bottom))
                .frame(width: 24)
                .animation(Theme.Animation.springSnappy, value: isFocused)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
        }
        .padding(Theme.Spacing.base)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.base)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.base)
                .stroke(isFocused ? Theme.Colors.primaryGradientStart : Color.clear, lineWidth: 2)
        )
        .animation(Theme.Animation.springSnappy, value: isFocused)
    }
}

// MARK: - Premium Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, selectedIcon: String, label: String)]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarButton(
                    icon: tabs[index].icon,
                    selectedIcon: tabs[index].selectedIcon,
                    label: tabs[index].label,
                    isSelected: selectedTab == index
                ) {
                    withAnimation(Theme.Animation.springBouncy) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.compactSpacing)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.xxxl)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.xxxl)
                .stroke(Theme.Colors.border.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 24, y: 6)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 3)
        .padding(.horizontal, Theme.Spacing.screenPadding)
        .padding(.bottom, Theme.Spacing.base)
    }
}

struct TabBarButton: View {
    let icon: String
    let selectedIcon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)
                    .foregroundStyle(
                        isSelected
                            ? Theme.Colors.primaryGradient
                            : LinearGradient(colors: [Theme.Colors.secondaryLabel], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 28)
                
                Text(label)
                    .font(Theme.Typography.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? Theme.Colors.primaryGradientStart : Theme.Colors.secondaryLabel)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.xs)
        }
    }
}

// MARK: - Premium Hero Header
struct HeroHeader: View {
    let title: String
    let subtitle: String?
    let showGradient: Bool
    
    init(title: String, subtitle: String? = nil, showGradient: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.showGradient = showGradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(showGradient ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.label], startPoint: .top, endPoint: .bottom))
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.screenPadding)
        .padding(.vertical, Theme.Spacing.lg)
    }
}

// MARK: - Premium Section Header
struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(Theme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.label)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: {
                    hapticFeedback(.light)
                    action()
                }) {
                    Text(actionTitle)
                        .font(Theme.Typography.subheadlineMedium)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.screenPadding)
    }
}

// MARK: - Card Style (top-level so ShadowModifier can reference it without generic gymnastics)
enum PremiumCardStyle {
    case elevated
    case flat
    case glass
    case floating
}

// MARK: - Premium Card Container
struct PremiumCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Theme.Spacing.cardPadding
    var style: PremiumCardStyle = .elevated

    // Keep the nested alias so any code using PremiumCard<X>.CardStyle still compiles.
    typealias CardStyle = PremiumCardStyle

    init(
        style: PremiumCardStyle = .elevated,
        padding: CGFloat = Theme.Spacing.cardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundStyle)
            .cornerRadius(Theme.CornerRadius.card)
            .modifier(ShadowModifier(style: style))
    }

    // Returns AnyShapeStyle so Color and Material branches share a single concrete type.
    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .elevated:  return AnyShapeStyle(Theme.Colors.elevatedCard)
        case .flat:      return AnyShapeStyle(Theme.Colors.secondaryBackground)
        case .glass:     return AnyShapeStyle(Theme.Blur.regular)
        case .floating:  return AnyShapeStyle(Theme.Colors.floatingCard)
        }
    }
}

struct ShadowModifier: ViewModifier {
    let style: PremiumCardStyle

    // Always applies .shadow() with the same signature — avoids a type mismatch
    // between branches that add a shadow modifier and the branch that doesn't.
    func body(content: Content) -> some View {
        content
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }

    private var shadowColor: Color {
        switch style {
        case .elevated:  return Color.black.opacity(0.06)
        case .flat:      return Color.clear
        case .glass:     return Color.black.opacity(0.04)
        case .floating:  return Color.black.opacity(0.07)
        }
    }
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:  return 12
        case .flat:      return 0
        case .glass:     return 8
        case .floating:  return 24
        }
    }
    private var shadowY: CGFloat {
        switch style {
        case .elevated:  return 4
        case .flat:      return 0
        case .glass:     return 2
        case .floating:  return 8
        }
    }
}

// MARK: - Premium Badge Component
struct PremiumBadge: View {
    let text: String
    let style: BadgeStyle
    
    enum BadgeStyle {
        case filled(Color)
        case outlined(Color)
        case gradient
        case subtle(Color)
        
        var foregroundColor: Color {
            switch self {
            case .filled: return .white
            case .outlined(let color): return color
            case .gradient: return .white
            case .subtle(let color): return color
            }
        }
        
        @ViewBuilder
        var background: some View {
            switch self {
            case .filled(let color):
                color
            case .outlined:
                Color.clear
            case .gradient:
                Theme.Colors.primaryGradient
            case .subtle(let color):
                color.opacity(0.15)
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .outlined(let color): return color
            default: return nil
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(Theme.Typography.tag)
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xs)
            .background(style.background)
            .cornerRadius(Theme.CornerRadius.xs)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xs)
                    .stroke(style.borderColor ?? Color.clear, lineWidth: 1.5)
            )
    }
}

// MARK: - Premium Impact Stat Card
struct ImpactStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let showGlow: Bool
    
    init(icon: String, value: String, label: String, color: Color, showGlow: Bool = true) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
        self.showGlow = showGlow
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                if showGlow {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .blur(radius: 20)
                }
                
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: Theme.Spacing.xxs) {
                Text(value)
                    .font(Theme.Typography.title1)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.label)
                
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.elevatedCard)
        .cornerRadius(Theme.CornerRadius.cardLarge)
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Premium Animated Button
struct AnimatedButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let isLoading: Bool
    let action: () -> Void
    
    enum ButtonStyleType {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Text(title)
                        .font(Theme.Typography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(foregroundColor)
            .background(backgroundView)
            .cornerRadius(Theme.CornerRadius.base)
            .shadow(color: shadowColor, radius: 16, y: 4)
        }
        .disabled(isLoading)
        .buttonStyle(PremiumScaleButtonStyle())
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return Theme.Colors.primaryGradientStart
        case .tertiary: return Theme.Colors.label
        case .destructive: return .white
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Theme.Colors.primaryGradient
        case .secondary:
            Theme.Colors.secondaryBackground
        case .tertiary:
            Color.clear
        case .destructive:
            Color.red
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary: return Theme.Colors.primaryGradientStart.opacity(0.3)
        case .secondary: return Color.clear
        case .tertiary: return Color.clear
        case .destructive: return Color.red.opacity(0.3)
        }
    }
}

// MARK: - Premium Scale Button Style
struct PremiumScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(Theme.Animation.springSnappy, value: configuration.isPressed)
    }
}

// MARK: - Premium Shimmer Loading
struct ShimmerView: View {
    @State private var isAnimating = false
    var cornerRadius: CGFloat = Theme.CornerRadius.card
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Theme.Colors.secondaryBackground)
            .overlay(
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Theme.Colors.background.opacity(0.6),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Premium Floating Action Button
struct PremiumFAB: View {
    let icon: String
    let label: String?
    let style: FABStyle
    let action: () -> Void
    
    enum FABStyle {
        case large
        case compact
    }
    
    init(icon: String, label: String? = nil, style: FABStyle = .large, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            Group {
                if let label = label {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                        Text(label)
                            .font(Theme.Typography.buttonLarge)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.vertical, Theme.Spacing.base)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: style == .large ? 24 : 20, weight: .semibold))
                        .frame(width: style == .large ? 64 : 56, height: style == .large ? 64 : 56)
                }
            }
            .foregroundColor(.white)
            .background(Theme.Colors.primaryGradient)
            .cornerRadius(Theme.CornerRadius.pill)
            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.4), radius: 20, y: 8)
            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.2), radius: 40, y: 16)
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Premium Toast Notification
struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    enum ToastType {
        case success
        case error
        case info
        case warning
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return Theme.Colors.success
            case .error: return Theme.Colors.error
            case .info: return Theme.Colors.info
            case .warning: return Theme.Colors.warning
            }
        }
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(type.color)
            
            Text(message)
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.label)
            
            Spacer()
        }
        .padding(Theme.Spacing.base)
        .background(.ultraThinMaterial)
        .cornerRadius(Theme.CornerRadius.base)
        .shadow(color: Color.black.opacity(0.06), radius: 16, y: 5)
        .padding(.horizontal, Theme.Spacing.screenPadding)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(Theme.Animation.springSmooth) {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - Premium Progress Step Indicator
struct ProgressStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Theme.Colors.tertiaryBackground)
                        .frame(height: 6)
                    
                    // Progress
                    Capsule()
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: geometry.size.width * (CGFloat(currentStep) / CGFloat(totalSteps - 1)), height: 6)
                        .animation(Theme.Animation.springSmooth, value: currentStep)
                }
            }
            .frame(height: 6)
            
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Theme.Colors.primaryGradientStart : Theme.Colors.tertiaryBackground)
                        .frame(width: 8, height: 8)
                        .animation(Theme.Animation.springBouncy, value: currentStep)
                    
                    if step < totalSteps - 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}
