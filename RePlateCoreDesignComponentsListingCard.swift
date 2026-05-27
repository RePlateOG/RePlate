//
//  ListingCard.swift
//  RePlate
//
//  Card component for displaying food listings
//

import SwiftUI

struct ListingCard: View {
    let listing: Listing
    let distance: Double?
    let onTap: () -> Void
    
    @State private var imageLoaded = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            onTap()
        }) {
            RPCard(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // Image
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: listing.imageURLs.first ?? "")) { phase in
                            switch phase {
                            case .empty:
                                SkeletonView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Color.secondaryBackground
                                    .overlay(
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundColor(.textTertiary)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 160)
                        .clipped()
                        
                        // Badges
                        VStack(alignment: .trailing, spacing: Spacing.xs) {
                            if listing.isFree {
                                Badge(text: "FREE", color: .success)
                            } else if listing.discountPercentage > 0 {
                                Badge(text: "\(listing.discountPercentage)% OFF", color: .primaryGradientStart)
                            }
                            
                            if listing.isAlmostGone {
                                Badge(text: "Almost Gone!", color: .warning)
                            }
                        }
                        .padding(Spacing.sm)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(listing.title)
                                .font(.titleSmall)
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let distance = distance {
                                HStack(spacing: Spacing.xxs) {
                                    Image(systemName: "location.fill")
                                        .font(.labelSmall)
                                    Text(String(format: "%.1f mi", distance))
                                        .font(.labelSmall)
                                }
                                .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Text(listing.restaurantName)
                            .font(.bodySmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                        
                        HStack(spacing: Spacing.xs) {
                            Text(listing.category.icon)
                                .font(.labelMedium)
                            
                            Text(listing.category.rawValue)
                                .font(.labelMedium)
                                .foregroundColor(.textTertiary)
                            
                            Spacer()
                            
                            if listing.isFree {
                                Text("FREE")
                                    .font(.titleSmall)
                                    .foregroundColor(.success)
                                    .fontWeight(.bold)
                            } else {
                                HStack(spacing: Spacing.xxs) {
                                    if listing.discountedPrice < listing.originalPrice {
                                        Text("$\(String(format: "%.2f", listing.originalPrice))")
                                            .font(.labelMedium)
                                            .foregroundColor(.textTertiary)
                                            .strikethrough()
                                    }
                                    
                                    Text("$\(String(format: "%.2f", listing.discountedPrice))")
                                        .font(.titleSmall)
                                        .foregroundColor(.primaryGradientStart)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "clock.fill")
                                .font(.labelSmall)
                            Text(listing.pickupWindowString)
                                .font(.labelMedium)
                            
                            if listing.quantity > 1 {
                                Spacer()
                                Text("\(listing.quantity) left")
                                    .font(.labelMedium)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                        .foregroundColor(.textSecondary)
                    }
                    .padding(Spacing.md)
                }
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.labelSmall)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(color)
            .cornerRadius(CornerRadius.sm)
    }
}

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(Color.secondaryBackground)
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(70))
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

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct ListingCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                ListingCard(
                    listing: Listing(
                        id: "1",
                        restaurantId: "r1",
                        restaurantName: "Pizza Palace",
                        restaurantLocation: GeoPoint(latitude: 40.7128, longitude: -74.0060),
                        title: "Large Pepperoni Pizza",
                        category: .pizza,
                        imageURLs: [],
                        quantity: 3,
                        originalPrice: 18.99,
                        discountedPrice: 9.99,
                        isFree: false,
                        pickupStart: Date(),
                        pickupEnd: Date().addingTimeInterval(3600),
                        status: .active,
                        createdAt: Date(),
                        updatedAt: Date(),
                        expiresAt: Date().addingTimeInterval(7200)
                    ),
                    distance: 0.5,
                    onTap: {}
                )
                
                ListingCard(
                    listing: Listing(
                        id: "2",
                        restaurantId: "r2",
                        restaurantName: "Healthy Bites",
                        restaurantLocation: GeoPoint(latitude: 40.7128, longitude: -74.0060),
                        title: "Fresh Garden Salad",
                        category: .salads,
                        imageURLs: [],
                        quantity: 1,
                        originalPrice: 12.99,
                        discountedPrice: 0,
                        isFree: true,
                        pickupStart: Date(),
                        pickupEnd: Date().addingTimeInterval(3600),
                        status: .active,
                        createdAt: Date(),
                        updatedAt: Date(),
                        expiresAt: Date().addingTimeInterval(7200)
                    ),
                    distance: 1.2,
                    onTap: {}
                )
            }
            .padding()
        }
    }
}
