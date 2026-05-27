//
//  CustomerHomeView.swift
//  RePlate
//
//  Main home screen for customers
//

import SwiftUI
import MapKit

struct CustomerHomeView: View {
    @StateObject private var viewModel = CustomerHomeViewModel()
    @State private var showMap = false
    @State private var selectedListing: Listing?
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main content
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header with location
                        HStack {
                            VStack(alignment: .leading, spacing: Spacing.xxs) {
                                Text("Your Location")
                                    .font(.labelMedium)
                                    .foregroundColor(.textSecondary)
                                
                                HStack(spacing: Spacing.xxs) {
                                    Image(systemName: "location.fill")
                                        .font(.labelLarge)
                                    Text(viewModel.currentLocationName)
                                        .font(.titleSmall)
                                }
                                .foregroundColor(.textPrimary)
                            }
                            
                            Spacer()
                            
                            // Map toggle
                            Button(action: {
                                HapticManager.shared.light()
                                showMap.toggle()
                            }) {
                                Image(systemName: showMap ? "list.bullet" : "map.fill")
                                    .font(.titleMedium)
                                    .foregroundColor(.textPrimary)
                                    .frame(width: 44, height: 44)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(CornerRadius.md)
                            }
                            
                            // Filter button
                            Button(action: {
                                HapticManager.shared.light()
                                showFilters = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.titleMedium)
                                        .foregroundColor(.textPrimary)
                                        .frame(width: 44, height: 44)
                                        .background(Color.secondaryBackground)
                                        .cornerRadius(CornerRadius.md)
                                    
                                    if viewModel.hasActiveFilters {
                                        Circle()
                                            .fill(Color.error)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, Spacing.sm)
                        
                        // Impact stats
                        ImpactBanner(stats: viewModel.userImpactStats)
                            .padding(.horizontal)
                        
                        // Search bar
                        SearchBar(text: $viewModel.searchQuery)
                            .padding(.horizontal)
                        
                        // Category filter
                        CategoryScrollView(
                            selectedCategory: $viewModel.selectedCategory,
                            categories: FoodCategory.allCases
                        )
                        
                        if showMap {
                            // Map view
                            ListingsMapView(
                                listings: viewModel.filteredListings,
                                selectedListing: $selectedListing,
                                userLocation: viewModel.userLocation
                            )
                            .frame(height: 400)
                            .cornerRadius(CornerRadius.lg)
                            .padding(.horizontal)
                        } else {
                            // Listings
                            if viewModel.isLoading {
                                VStack(spacing: Spacing.md) {
                                    ForEach(0..<3) { _ in
                                        SkeletonView()
                                            .frame(height: 280)
                                            .cornerRadius(CornerRadius.xxl)
                                    }
                                }
                                .padding(.horizontal)
                            } else if viewModel.filteredListings.isEmpty {
                                EmptyStateView(
                                    icon: "tray",
                                    title: "No listings found",
                                    message: "Try adjusting your filters or check back later"
                                )
                                .padding(.vertical, Spacing.xxxxl)
                            } else {
                                LazyVStack(spacing: Spacing.md) {
                                    ForEach(viewModel.filteredListings) { listing in
                                        ListingCard(
                                            listing: listing,
                                            distance: viewModel.distance(to: listing),
                                            onTap: {
                                                selectedListing = listing
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                            .frame(height: Layout.tabBarHeight + Spacing.md)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(item: $selectedListing) { listing in
                ListingDetailView(listing: listing, viewModel: viewModel)
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel)
            }
        }
    }
}

struct ImpactBanner: View {
    let stats: ImpactStats
    
    var body: some View {
        RPCard(hasGlassmorphism: true) {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Your Impact")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(stats.totalMealsSaved) meals saved")
                        .font(.titleSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGradientStart)
                }
                
                Spacer()
                
                HStack(spacing: Spacing.lg) {
                    ImpactStat(
                        icon: "leaf.fill",
                        value: String(format: "%.0f", stats.co2InPounds),
                        unit: "lbs CO₂"
                    )
                    
                    ImpactStat(
                        icon: "scale.3d",
                        value: String(format: "%.0f", stats.foodInPounds),
                        unit: "lbs food"
                    )
                }
            }
        }
    }
}

struct ImpactStat: View {
    let icon: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.labelLarge)
                .foregroundColor(.success)
            
            Text(value)
                .font(.titleSmall)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(unit)
                .font(.labelSmall)
                .foregroundColor(.textSecondary)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            
            TextField("Search food, restaurants...", text: $text)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    HapticManager.shared.light()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.secondaryBackground)
        .cornerRadius(CornerRadius.lg)
    }
}

struct CategoryScrollView: View {
    @Binding var selectedCategory: FoodCategory?
    let categories: [FoodCategory]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                CategoryChip(
                    title: "All",
                    icon: nil,
                    isSelected: selectedCategory == nil
                ) {
                    HapticManager.shared.selection()
                    selectedCategory = nil
                }
                
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        HapticManager.shared.selection()
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Text(icon)
                        .font(.bodyMedium)
                }
                
                Text(title)
                    .font(.labelLarge)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ? Color.primaryGradient : AnyShapeStyle(Color.secondaryBackground)
            )
            .cornerRadius(CornerRadius.xl)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.textTertiary)
            
            Text(title)
                .font(.titleLarge)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview
struct CustomerHomeView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerHomeView()
    }
}
