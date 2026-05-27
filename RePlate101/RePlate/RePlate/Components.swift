//
//  Components.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .font(Theme.Typography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(Theme.Colors.primaryGradient)
            .cornerRadius(Theme.CornerRadius.xxl)
            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.3), radius: Theme.Shadows.md, y: Theme.Shadows.sm)
        }
        .disabled(isLoading)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(Theme.Colors.primaryGradientStart)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xxl)
        }
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xxl)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.05), radius: Theme.Shadows.lg, y: Theme.Shadows.sm)
            )
    }
}

// MARK: - Food Listing Card
struct FoodListingCard: View {
    let listing: FoodListing
    let showDistance: Bool
    let distance: Double?
    let onTap: () -> Void
    
    init(
        listing: FoodListing,
        showDistance: Bool = true,
        distance: Double? = nil,
        onTap: @escaping () -> Void = {}
    ) {
        self.listing = listing
        self.showDistance = showDistance
        self.distance = distance
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topTrailing) {
                    if let imageURL = listing.imageURLs.first {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Theme.Colors.secondaryBackground)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(Theme.Colors.tertiaryLabel)
                                )
                        }
                        .frame(height: 200)
                        .clipped()
                    }
                    
                    // Badges
                    VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                        if listing.isFree {
                            Badge("FREE", color: .green)
                        } else if listing.discountPercentage > 0 {
                            Badge("\(listing.discountPercentage)% OFF", color: Theme.Colors.primaryGradientStart)
                        }
                        
                        if listing.isAlmostGone {
                            Badge("Almost Gone", color: .orange)
                        }
                        
                        if listing.isExpiringSoon {
                            Badge("Expiring Soon", color: .red)
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                
                // Info
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text(listing.title)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                        .lineLimit(2)
                    
                    if let restaurant = listing.restaurant {
                        HStack(spacing: Theme.Spacing.xs) {
                            Image(systemName: "fork.knife")
                                .font(.caption)
                            Text(restaurant.name)
                                .font(Theme.Typography.subheadline)
                        }
                        .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                    
                    HStack {
                        // Price
                        if listing.isFree {
                            Text("FREE")
                                .font(Theme.Typography.title3)
                                .foregroundColor(.green)
                        } else {
                            Text("$\(String(format: "%.2f", listing.discountedPrice))")
                                .font(Theme.Typography.title3)
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                            
                            if listing.originalPrice > listing.discountedPrice {
                                Text("$\(String(format: "%.2f", listing.originalPrice))")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(Theme.Colors.tertiaryLabel)
                                    .strikethrough()
                            }
                        }
                        
                        Spacer()
                        
                        // Distance
                        if showDistance, let distance = distance {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption)
                                Text(String(format: "%.1f mi", distance))
                                    .font(Theme.Typography.caption)
                            }
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }
                    
                    // Pickup Time
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Pickup: \(listing.pickupStartTime.formatted(date: .omitted, time: .shortened))")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(Theme.Colors.secondaryLabel)
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xxl)
            .shadow(color: Color.black.opacity(0.05), radius: Theme.Shadows.lg, y: Theme.Shadows.sm)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Badge
struct Badge: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(Theme.Typography.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Order Card
struct OrderCard: View {
    let order: Order
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        if let listing = order.listing {
                            Text(listing.title)
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.label)
                        }
                        
                        if let restaurant = order.restaurant {
                            Text(restaurant.name)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: order.status.icon)
                        Text(order.status.rawValue)
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 6)
                    .background(order.status.color)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pickup Time")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Text(order.pickupWindowStart.formatted(date: .omitted, time: .shortened))
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.label)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Text("$\(String(format: "%.2f", order.totalAmount))")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }
                
                if order.status == .ready || order.status == .confirmed {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Pickup Code")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Text(order.pickupCode)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.accent.opacity(0.2))
                    .cornerRadius(Theme.CornerRadius.md)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xxl)
            .shadow(color: Color.black.opacity(0.05), radius: Theme.Shadows.lg, y: Theme.Shadows.sm)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: Bool
    
    init(icon: String, value: String, label: String, gradient: Bool = false) {
        self.icon = icon
        self.value = value
        self.label = label
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(gradient ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.primaryGradientStart], startPoint: .top, endPoint: .bottom))
            
            Text(value)
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.label)
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.xl)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Theme.Colors.primaryGradient)
            
            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.label)
                
                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, action: action)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .padding(Theme.Spacing.xl)
    }
}

// MARK: - Loading Skeleton
struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
            .fill(Theme.Colors.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, Color.white.opacity(0.3), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: isAnimating ? 400 : -400)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - FAB (Floating Action Button)
struct FAB: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Theme.Colors.primaryGradient)
                .clipShape(Circle())
                .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.4), radius: 12, y: 6)
        }
    }
}

// MARK: - Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Theme.Animation.fast, value: configuration.isPressed)
    }
}

// MARK: - Haptic Feedback
func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}
