//
//  ListingDetailView.swift
//  RePlate
//
//  Detailed view for a food listing
//

import SwiftUI
import MapKit

struct ListingDetailView: View {
    let listing: Listing
    let viewModel: CustomerHomeViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showPayment = false
    @State private var isClaiming = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Image carousel
                    TabView {
                        ForEach(listing.imageURLs.isEmpty ? ["placeholder"] : listing.imageURLs, id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    Color.secondaryBackground
                                        .overlay(
                                            ProgressView()
                                        )
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Color.secondaryBackground
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.system(size: 50))
                                                .foregroundColor(.textTertiary)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 300)
                    
                    VStack(alignment: .leading, spacing: Spacing.lg) {
                        // Title and price
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: Spacing.xs) {
                                    Text(listing.title)
                                        .font(.headlineSmall)
                                        .fontWeight(.bold)
                                        .foregroundColor(.textPrimary)
                                    
                                    HStack(spacing: Spacing.xs) {
                                        Text(listing.category.icon)
                                        Text(listing.category.rawValue)
                                            .font(.bodyMedium)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: Spacing.xxs) {
                                    if listing.isFree {
                                        Text("FREE")
                                            .font(.headlineSmall)
                                            .fontWeight(.bold)
                                            .foregroundColor(.success)
                                    } else {
                                        if listing.discountedPrice < listing.originalPrice {
                                            Text("$\(String(format: "%.2f", listing.originalPrice))")
                                                .font(.bodySmall)
                                                .foregroundColor(.textTertiary)
                                                .strikethrough()
                                        }
                                        
                                        Text("$\(String(format: "%.2f", listing.discountedPrice))")
                                            .font(.headlineMedium)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primaryGradientStart)
                                    }
                                    
                                    if listing.discountPercentage > 0 {
                                        Text("\(listing.discountPercentage)% OFF")
                                            .font(.labelSmall)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, Spacing.sm)
                                            .padding(.vertical, Spacing.xxs)
                                            .background(Color.error)
                                            .cornerRadius(CornerRadius.sm)
                                    }
                                }
                            }
                            
                            if listing.isAlmostGone {
                                HStack(spacing: Spacing.xs) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Only \(listing.quantity) left!")
                                }
                                .font(.labelMedium)
                                .foregroundColor(.warning)
                            }
                        }
                        
                        Divider()
                        
                        // Restaurant info
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Restaurant")
                                .font(.titleSmall)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: Spacing.md) {
                                Circle()
                                    .fill(Color.secondaryBackground)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "building.2.fill")
                                            .foregroundColor(.textTertiary)
                                    )
                                
                                VStack(alignment: .leading, spacing: Spacing.xxs) {
                                    HStack(spacing: Spacing.xs) {
                                        Text(listing.restaurantName)
                                            .font(.bodyLarge)
                                            .fontWeight(.semibold)
                                        
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.labelMedium)
                                            .foregroundColor(.info)
                                    }
                                    
                                    if let distance = viewModel.distance(to: listing) {
                                        HStack(spacing: Spacing.xxs) {
                                            Image(systemName: "location.fill")
                                            Text(String(format: "%.1f mi away", distance))
                                        }
                                        .font(.bodySmall)
                                        .foregroundColor(.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    HapticManager.shared.light()
                                    // TODO: Navigate to restaurant profile
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.labelLarge)
                                        .foregroundColor(.textTertiary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Pickup information
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Pickup Information")
                                .font(.titleSmall)
                                .fontWeight(.semibold)
                            
                            InfoRow(
                                icon: "clock.fill",
                                title: "Pickup Window",
                                value: listing.pickupWindowString
                            )
                            
                            InfoRow(
                                icon: "cube.box.fill",
                                title: "Quantity Available",
                                value: "\(listing.quantity)"
                            )
                            
                            CountdownTimer(expiresAt: listing.expiresAt)
                        }
                        
                        if let description = listing.description {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Description")
                                    .font(.titleSmall)
                                    .fontWeight(.semibold)
                                
                                Text(description)
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Divider()
                        
                        // Map
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("Location")
                                .font(.titleSmall)
                                .fontWeight(.semibold)
                            
                            Map(coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: listing.restaurantLocation.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            ), annotationItems: [listing]) { listing in
                                MapMarker(coordinate: listing.restaurantLocation.coordinate, tint: .primaryGradientStart)
                            }
                            .frame(height: 200)
                            .cornerRadius(CornerRadius.lg)
                            .allowsHitTesting(false)
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(Spacing.lg)
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        HapticManager.shared.light()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.titleLarge)
                            .foregroundColor(.textSecondary)
                            .background(
                                Circle()
                                    .fill(Color.cardBackground)
                                    .frame(width: 32, height: 32)
                            )
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        HapticManager.shared.light()
                        // TODO: Save listing
                    }) {
                        Image(systemName: "heart")
                            .font(.titleLarge)
                            .foregroundColor(.textSecondary)
                            .background(
                                Circle()
                                    .fill(Color.cardBackground)
                                    .frame(width: 32, height: 32)
                            )
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Claim button
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: Spacing.md) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Total")
                                .font(.labelMedium)
                                .foregroundColor(.textSecondary)
                            
                            if listing.isFree {
                                Text("FREE")
                                    .font(.titleLarge)
                                    .fontWeight(.bold)
                                    .foregroundColor(.success)
                            } else {
                                Text("$\(String(format: "%.2f", listing.discountedPrice))")
                                    .font(.titleLarge)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                            }
                        }
                        
                        Spacer()
                        
                        RPButton(
                            listing.isFree ? "Claim Now" : "Claim & Pay",
                            icon: "checkmark.circle.fill",
                            size: .medium,
                            isLoading: isClaiming
                        ) {
                            claimListing()
                        }
                        .frame(width: 200)
                    }
                    .padding(Spacing.md)
                    .background(
                        ZStack {
                            BlurView(style: .systemMaterial)
                            Color.cardBackground.opacity(0.8)
                        }
                        .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
        }
    }
    
    private func claimListing() {
        if listing.isFree {
            // Free - claim directly
            isClaiming = true
            HapticManager.shared.success()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isClaiming = false
                dismiss()
                // TODO: Show success message
            }
        } else {
            // Paid - show payment sheet
            showPayment = true
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.titleSmall)
                .foregroundColor(.primaryGradientStart)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.bodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

struct CountdownTimer: View {
    let expiresAt: Date
    @State private var timeRemaining: TimeInterval = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "timer")
                .font(.titleSmall)
                .foregroundColor(.warning)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Time Remaining")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
                
                Text(timeString)
                    .font(.bodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(timeRemaining < 3600 ? .warning : .textPrimary)
            }
            
            Spacer()
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = max(0, expiresAt.timeIntervalSinceNow)
    }
    
    private var timeString: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60
        let seconds = Int(timeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Preview
struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(
            listing: Listing(
                id: "1",
                restaurantId: "r1",
                restaurantName: "Pizza Palace",
                restaurantLocation: GeoPoint(latitude: 40.7128, longitude: -74.0060),
                title: "Large Pepperoni Pizza",
                description: "Fresh, delicious pepperoni pizza made with premium ingredients. Slightly overcooked but perfectly edible!",
                category: .pizza,
                imageURLs: [],
                quantity: 2,
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
            viewModel: CustomerHomeViewModel()
        )
    }
}
