//
//  HomeView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedListing: FoodListing?
    @State private var showListingDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.lg) {
                        // Header
                        headerSection
                        
                        // Impact Stats
                        impactStatsSection
                        
                        // Featured Listings
                        if !viewModel.featuredListings.isEmpty {
                            featuredSection
                        }
                        
                        // All Listings
                        listingsSection
                    }
                    .padding(.bottom, 100) // Space for tab bar
                }
                .refreshable {
                    await viewModel.refreshListings()
                }
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("RePlate")
                        .font(Theme.Typography.title2)
                        .foregroundStyle(Theme.Colors.primaryGradient)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleMapView()
                    } label: {
                        Image(systemName: viewModel.showMap ? "list.bullet" : "map")
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }
            }
            .task {
                await viewModel.loadListings()
            }
            .sheet(item: $selectedListing) { listing in
                ListingDetailView(listing: listing)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Nearby Deals")
                .font(Theme.Typography.largeTitle)
                .foregroundColor(Theme.Colors.label)
            
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text("San Francisco, CA")
                    .font(Theme.Typography.subheadline)
            }
            .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.md)
    }
    
    // MARK: - Impact Stats Section
    private var impactStatsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Community Impact")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    StatCard(
                        icon: "fork.knife",
                        value: "\(viewModel.impactStats.totalMealsSaved.formatted())",
                        label: "Meals Saved",
                        gradient: true
                    )
                    
                    StatCard(
                        icon: "leaf.fill",
                        value: "\(String(format: "%.1f", viewModel.impactStats.totalCO2Reduced / 1000))t",
                        label: "CO₂ Reduced",
                        gradient: true
                    )
                    
                    StatCard(
                        icon: "scalemass.fill",
                        value: "\(String(format: "%.1f", viewModel.impactStats.totalFoodRescued / 1000))k lbs",
                        label: "Food Rescued",
                        gradient: true
                    )
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Featured Today")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.featuredListings) { listing in
                        FoodListingCard(
                            listing: listing,
                            distance: 0.8
                        ) {
                            selectedListing = listing
                        }
                        .frame(width: 300)
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
    
    // MARK: - Listings Section
    private var listingsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("All Available")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
                
                Button {
                    // Filter action
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filter")
                    }
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            if viewModel.isLoading {
                VStack(spacing: Theme.Spacing.md) {
                    ForEach(0..<3) { _ in
                        SkeletonView()
                            .frame(height: 300)
                            .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
            } else if viewModel.listings.isEmpty {
                EmptyStateView(
                    icon: "fork.knife",
                    title: "No Listings Available",
                    message: "Check back later for new deals from nearby restaurants"
                )
                .padding(.top, Theme.Spacing.xl)
            } else {
                LazyVStack(spacing: Theme.Spacing.md) {
                    ForEach(viewModel.listings) { listing in
                        FoodListingCard(
                            listing: listing,
                            distance: Double.random(in: 0.3...2.5)
                        ) {
                            selectedListing = listing
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
            }
        }
    }
}

// MARK: - Listing Detail View
struct ListingDetailView: View {
    @Environment(\.dismiss) var dismiss
    let listing: FoodListing
    @State private var selectedQuantity = 1
    @State private var showCheckout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Image Header
                    imageHeader
                    
                    // Content
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        // Title and Price
                        titleSection
                        
                        Divider()
                        
                        // Restaurant Info
                        if let restaurant = listing.restaurant {
                            restaurantSection(restaurant)
                        }
                        
                        Divider()
                        
                        // Description
                        descriptionSection
                        
                        // Pickup Info
                        pickupSection
                        
                        // Dietary Info
                        if !listing.dietaryInfo.isEmpty {
                            dietarySection
                        }
                    }
                    .padding(Theme.Spacing.lg)
                }
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                claimButton
            }
            .sheet(isPresented: $showCheckout) {
                CheckoutView(listing: listing, quantity: selectedQuantity)
            }
        }
    }
    
    // MARK: - Image Header
    private var imageHeader: some View {
        ZStack(alignment: .topTrailing) {
            if let imageURL = listing.imageURLs.first {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Theme.Colors.secondaryBackground)
                }
                .frame(height: 300)
                .clipped()
            }
            
            // Badges
            VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                if listing.isFree {
                    Badge("FREE", color: .green)
                } else if listing.discountPercentage > 0 {
                    Badge("\(listing.discountPercentage)% OFF", color: Theme.Colors.primaryGradientStart)
                }
            }
            .padding(Theme.Spacing.md)
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(listing.title)
                .font(Theme.Typography.title1)
                .foregroundColor(Theme.Colors.label)
            
            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                if listing.isFree {
                    Text("FREE")
                        .font(Theme.Typography.largeTitle)
                        .foregroundColor(.green)
                } else {
                    Text("$\(String(format: "%.2f", listing.discountedPrice))")
                        .font(Theme.Typography.largeTitle)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                    
                    if listing.originalPrice > listing.discountedPrice {
                        Text("$\(String(format: "%.2f", listing.originalPrice))")
                            .font(Theme.Typography.title3)
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                            .strikethrough()
                    }
                }
                
                Spacer()
                
                if listing.isAlmostGone {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Only \(listing.availableQuantity) left")
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    // MARK: - Restaurant Section
    private func restaurantSection(_ restaurant: Restaurant) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Colors.primaryGradient)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Theme.Spacing.xs) {
                    Text(restaurant.name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                    
                    if restaurant.verified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text(restaurant.address)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                
                HStack(spacing: Theme.Spacing.sm) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(.orange)
                    
                    Text("•")
                        .foregroundColor(Theme.Colors.tertiaryLabel)
                    
                    Text("\(restaurant.totalReviews) reviews")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Description")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            Text(listing.description)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
    }
    
    // MARK: - Pickup Section
    private var pickupSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Pickup Information")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: Theme.Spacing.sm) {
                infoRow(
                    icon: "clock.fill",
                    title: "Pickup Window",
                    value: "\(listing.pickupStartTime.formatted(date: .omitted, time: .shortened)) - \(listing.pickupEndTime.formatted(date: .omitted, time: .shortened))"
                )
                
                if listing.isExpiringSoon {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("Expiring soon - claim now!")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 6)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
    }
    
    // MARK: - Dietary Section
    private var dietarySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Dietary Information")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.sm) {
                    ForEach(listing.dietaryInfo, id: \.self) { info in
                        HStack(spacing: 4) {
                            Image(systemName: info.icon)
                                .font(.caption)
                            Text(info.rawValue)
                                .font(Theme.Typography.caption)
                        }
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.accent.opacity(0.3))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .cornerRadius(Theme.CornerRadius.sm)
                    }
                }
            }
        }
    }
    
    // MARK: - Info Row
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                Text(value)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.label)
            }
        }
    }
    
    // MARK: - Claim Button
    private var claimButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: Theme.Spacing.md) {
                // Quantity selector
                HStack(spacing: 0) {
                    Button {
                        if selectedQuantity > 1 {
                            selectedQuantity -= 1
                            hapticFeedback(.light)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(Theme.Typography.headline)
                            .foregroundColor(selectedQuantity > 1 ? Theme.Colors.primaryGradientStart : Theme.Colors.tertiaryLabel)
                            .frame(width: 44, height: 44)
                    }
                    
                    Text("\(selectedQuantity)")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                        .frame(width: 44)
                    
                    Button {
                        if selectedQuantity < listing.availableQuantity {
                            selectedQuantity += 1
                            hapticFeedback(.light)
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(Theme.Typography.headline)
                            .foregroundColor(selectedQuantity < listing.availableQuantity ? Theme.Colors.primaryGradientStart : Theme.Colors.tertiaryLabel)
                            .frame(width: 44, height: 44)
                    }
                }
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.xl)
                
                // Claim button
                Button {
                    hapticFeedback(.medium)
                    showCheckout = true
                } label: {
                    HStack {
                        Text("Claim Now")
                            .font(Theme.Typography.headline)
                        
                        Spacer()
                        
                        if listing.isFree {
                            Text("FREE")
                                .font(Theme.Typography.headline)
                        } else {
                            Text("$\(String(format: "%.2f", listing.discountedPrice * Double(selectedQuantity)))")
                                .font(Theme.Typography.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .frame(height: 56)
                    .background(Theme.Colors.primaryGradient)
                    .cornerRadius(Theme.CornerRadius.xxl)
                }
            }
            .padding(Theme.Spacing.lg)
            .background(Theme.Colors.background)
        }
    }
}

// MARK: - Checkout View
struct CheckoutView: View {
    @Environment(\.dismiss) var dismiss
    let listing: FoodListing
    let quantity: Int
    @State private var isProcessing = false
    @State private var showSuccess = false
    
    var totalAmount: Double {
        listing.discountedPrice * Double(quantity)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Order Summary
                    orderSummary
                    
                    // Payment Method
                    paymentSection
                    
                    // Checkout Button
                    PrimaryButton("Complete Order", isLoading: isProcessing) {
                        Task {
                            await processCheckout()
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Order Confirmed!", isPresented: $showSuccess) {
                Button("View Order") {
                    dismiss()
                }
            } message: {
                Text("Your order has been confirmed. Show your pickup code at the restaurant.")
            }
        }
    }
    
    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Order Summary")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Text(listing.title)
                        .font(Theme.Typography.body)
                    Spacer()
                    Text("×\(quantity)")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                
                if let restaurant = listing.restaurant {
                    HStack {
                        Text(restaurant.name)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Spacer()
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(Theme.Typography.headline)
                    Spacer()
                    if listing.isFree {
                        Text("FREE")
                            .font(Theme.Typography.headline)
                            .foregroundColor(.green)
                    } else {
                        Text("$\(String(format: "%.2f", totalAmount))")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Payment Method")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
            
            if listing.isFree {
                Text("No payment required for free items")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .padding(Theme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.xl)
            } else {
                Button {
                    // Select payment method
                } label: {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Apple Pay")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.label)
                            Text("Pay securely with Apple Pay")
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.xl)
                }
            }
        }
    }
    
    func processCheckout() async {
        isProcessing = true
        
        // Simulate payment processing
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        isProcessing = false
        showSuccess = true
        hapticFeedback(.success)
    }
}
