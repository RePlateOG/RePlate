//
//  SearchView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedListing: FoodListing?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.lg) {
                        if viewModel.searchQuery.isEmpty {
                            // Recent Searches
                            if !viewModel.recentSearches.isEmpty {
                                recentSearchesSection
                            }
                            
                            // Categories
                            categoriesSection
                        } else if viewModel.isLoading {
                            // Loading
                            loadingView
                        } else if viewModel.searchResults.isEmpty {
                            // Empty State
                            emptyResultsView
                        } else {
                            // Results
                            resultsSection
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("Search")
            .sheet(isPresented: $viewModel.showFilters) {
                FiltersView(filters: $viewModel.filters) {
                    Task {
                        await viewModel.applyFilters()
                    }
                }
            }
            .sheet(item: $selectedListing) { listing in
                ListingDetailView(listing: listing)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.Colors.secondaryLabel)
                
                TextField("Search food, restaurants...", text: $viewModel.searchQuery)
                    .font(Theme.Typography.body)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await viewModel.search()
                        }
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.md)
            
            Button {
                viewModel.showFilters = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(width: 44, height: 44)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    
                    if viewModel.filters.isActive {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: 2)
                    }
                }
            }
        }
        .padding(Theme.Spacing.lg)
    }
    
    // MARK: - Recent Searches
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Recent Searches")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
                
                Button("Clear") {
                    viewModel.recentSearches.removeAll()
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            ForEach(viewModel.recentSearches, id: \.self) { search in
                Button {
                    viewModel.searchQuery = search
                    Task {
                        await viewModel.search()
                    }
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        
                        Text(search)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.label)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .font(.caption)
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.md)
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Browse by Category")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
                .padding(.horizontal, Theme.Spacing.lg)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                    Button {
                        // Filter by category
                        viewModel.filters.categories.insert(category)
                        Task {
                            await viewModel.applyFilters()
                        }
                    } label: {
                        VStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: category.icon)
                                .font(.system(size: 32))
                                .foregroundStyle(Theme.Colors.primaryGradient)
                            
                            Text(category.rawValue)
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.label)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.lg)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.xl)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonView()
                    .frame(height: 300)
                    .padding(.horizontal, Theme.Spacing.lg)
            }
        }
    }
    
    // MARK: - Empty Results
    private var emptyResultsView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or filters"
        )
        .padding(.top, Theme.Spacing.xxl)
    }
    
    // MARK: - Results
    private var resultsSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("\(viewModel.searchResults.count) Results")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            ForEach(viewModel.searchResults) { listing in
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

// MARK: - Filters View
struct FiltersView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var filters: SearchFilters
    let onApply: () -> Void
    
    @State private var localFilters: SearchFilters
    
    init(filters: Binding<SearchFilters>, onApply: @escaping () -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._localFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    // Categories
                    categoriesSection
                    
                    Divider()
                    
                    // Distance
                    distanceSection
                    
                    Divider()
                    
                    // Price
                    priceSection
                    
                    Divider()
                    
                    // Dietary
                    dietarySection
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        localFilters = SearchFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        filters = localFilters
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Categories")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                    Button {
                        if localFilters.categories.contains(category) {
                            localFilters.categories.remove(category)
                        } else {
                            localFilters.categories.insert(category)
                        }
                        hapticFeedback(.light)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(Theme.Typography.caption)
                        .foregroundColor(localFilters.categories.contains(category) ? .white : Theme.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(localFilters.categories.contains(category) ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
    }
    
    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Max Distance")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            HStack(spacing: Theme.Spacing.md) {
                ForEach([1.0, 3.0, 5.0, 10.0], id: \.self) { distance in
                    Button {
                        localFilters.maxDistance = distance
                        hapticFeedback(.light)
                    } label: {
                        Text("\(Int(distance)) mi")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(localFilters.maxDistance == distance ? .white : Theme.Colors.label)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(localFilters.maxDistance == distance ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Price Range")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            Toggle("Free Only", isOn: $localFilters.freeOnly)
                .font(Theme.Typography.body)
        }
    }
    
    private var dietarySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Dietary Restrictions")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                ForEach(FoodListing.DietaryInfo.allCases, id: \.self) { info in
                    Button {
                        if localFilters.dietaryRestrictions.contains(info) {
                            localFilters.dietaryRestrictions.remove(info)
                        } else {
                            localFilters.dietaryRestrictions.insert(info)
                        }
                        hapticFeedback(.light)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: info.icon)
                            Text(info.rawValue)
                        }
                        .font(Theme.Typography.caption)
                        .foregroundColor(localFilters.dietaryRestrictions.contains(info) ? .white : Theme.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(localFilters.dietaryRestrictions.contains(info) ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
    }
}
