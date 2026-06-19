//
//  SearchView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//  Redesigned to match RePlate 2.0 Figma — full-bleed header, emoji category grid, Figma listing cards.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedListing: FoodListing?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                searchHeader

                if viewModel.searchQuery.isEmpty {
                    if !viewModel.recentSearches.isEmpty {
                        recentSearchesSection
                            .padding(.top, 28)
                    }
                    categoriesSection
                        .padding(.top, 28)
                } else if viewModel.isLoading {
                    loadingView
                        .padding(.top, 32)
                } else if viewModel.searchResults.isEmpty {
                    emptyResultsView
                        .padding(.top, 60)
                } else {
                    resultsSection
                        .padding(.top, 24)
                }
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGray6).opacity(0.3))
        .sheet(isPresented: $viewModel.showFilters) {
            FiltersView(filters: $viewModel.filters) {
                Task { await viewModel.applyFilters() }
            }
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailView(listing: listing)
        }
    }

    // MARK: - Search Header (gradient → clips to UnevenRounded)
    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Find rescued food near you")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                // Filter button
                Button {
                    hapticFeedback(.light)
                    viewModel.showFilters = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                                .frame(width: 48, height: 48)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        if viewModel.filters.isActive {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                .offset(x: 3, y: -3)
                        }
                    }
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Search bar — white, sits inside gradient
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryGradientStart)

                TextField("Search food, restaurants...", text: $viewModel.searchQuery)
                    .font(.system(size: 16, weight: .medium))
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await viewModel.search() }
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.12), radius: 14, y: 5)
            )

            Spacer().frame(height: 52)
        }
        .padding(.horizontal, 20)
        .background(Theme.Colors.primaryGradient)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
    }

    // MARK: - Recent Searches
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Searches")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
                Button("Clear") {
                    viewModel.recentSearches.removeAll()
                    hapticFeedback(.light)
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(viewModel.recentSearches, id: \.self) { search in
                    Button {
                        viewModel.searchQuery = search
                        Task { await viewModel.search() }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "clock")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .frame(width: 20)
                            Text(search)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.Colors.label)
                            Spacer()
                            Image(systemName: "arrow.up.left")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.Colors.tertiaryLabel)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    if search != viewModel.recentSearches.last {
                        Divider().padding(.leading, 54)
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Browse by Category")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
            }
            .padding(.horizontal, 20)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 14
            ) {
                ForEach(searchCategories, id: \.label) { cat in
                    Button {
                        hapticFeedback(.light)
                        // Match emoji label to FoodCategory raw value
                        if let category = FoodListing.FoodCategory.allCases.first(
                            where: { $0.rawValue == cat.label }
                        ) {
                            viewModel.filters.categories.insert(category)
                            Task { await viewModel.applyFilters() }
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                            Text(cat.label)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.label)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cat.color)
                                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Loading
    private var loadingView: some View {
        VStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonView()
                    .frame(height: 100)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Empty Results
    private var emptyResultsView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(Theme.Colors.primaryGradientStart.opacity(0.5))
            }
            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text("Try adjusting your search or filters")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Results
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(viewModel.searchResults.count) Results")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            VStack(spacing: 28) {
                ForEach(viewModel.searchResults) { listing in
                    FigmaListingCard(listing: listing) {
                        selectedListing = listing
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Category Data
    private let searchCategories: [(icon: String, label: String, color: Color)] = [
        ("birthday.cake",      "Bakery",    Theme.Colors.primaryGradientStart.opacity(0.10)),
        ("fork.knife",         "Meals",     Theme.Colors.primaryGradientStart.opacity(0.10)),
        ("carrot",             "Produce",   Theme.Colors.primaryGradientStart.opacity(0.10)),
        ("cup.and.saucer",     "Beverages", Theme.Colors.primaryGradientStart.opacity(0.10)),
        ("birthday.cake.fill", "Desserts",  Theme.Colors.primaryGradientStart.opacity(0.10)),
        ("bag",                "Snacks",    Theme.Colors.primaryGradientStart.opacity(0.10)),
    ]
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
                    categoriesSection
                    Divider()
                    distanceSection
                    Divider()
                    priceSection
                    Divider()
                    dietarySection
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") { localFilters = SearchFilters() }
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

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Theme.Spacing.sm
            ) {
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
                        .foregroundColor(
                            localFilters.categories.contains(category) ? .white : Theme.Colors.label
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(
                            localFilters.categories.contains(category)
                                ? Theme.Colors.primaryGradient
                                : LinearGradient(
                                    colors: [Theme.Colors.secondaryBackground],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
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
                            .foregroundColor(
                                localFilters.maxDistance == distance ? .white : Theme.Colors.label
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(
                                localFilters.maxDistance == distance
                                    ? Theme.Colors.primaryGradient
                                    : LinearGradient(
                                        colors: [Theme.Colors.secondaryBackground],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                            )
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

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Theme.Spacing.sm
            ) {
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
                        .foregroundColor(
                            localFilters.dietaryRestrictions.contains(info) ? .white : Theme.Colors.label
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(
                            localFilters.dietaryRestrictions.contains(info)
                                ? Theme.Colors.primaryGradient
                                : LinearGradient(
                                    colors: [Theme.Colors.secondaryBackground],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
    }
}
