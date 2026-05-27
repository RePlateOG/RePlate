//
//  HomeView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//  Redesigned to match RePlate 2.0 Figma — playful, bold, food-first.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedListing: FoodListing?

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                homeHeader
                categoriesSection
                freshlyRescuedSection
            }
            .padding(.bottom, 100)
        }
        .background(Color(.systemGray6).opacity(0.3))
        .ignoresSafeArea(edges: .top)
        .refreshable { await viewModel.refreshListings() }
        .task { await viewModel.loadListings() }
        .sheet(item: $selectedListing) { listing in
            ListingDetailView(listing: listing)
        }
    }

    // MARK: - Hero Header
    private var homeHeader: some View {
        ZStack(alignment: .top) {
            // Subtle blob decoration
            Circle()
                .fill(Theme.Colors.accent.opacity(0.25))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: 120, y: -40)

            VStack(alignment: .leading, spacing: 0) {
                // Top bar: location + bell
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: "location.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text("YOUR LOCATION")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .tracking(1)
                            Text(appState.currentUser != nil ? "Downtown Manhattan" : "San Francisco, CA")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.label)
                        }
                    }
                    Spacer()
                    // Notification bell
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(width: 44, height: 44)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                        Circle()
                            .fill(Theme.Colors.primaryGradientStart)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .offset(x: 2, y: -2)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 24)

                // Bold headline
                Group {
                    Text("Feed your ") +
                    Text("belly")
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .italic()
                }
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.label)

                Group {
                    Text("save the ") +
                    Text("world.")
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .italic()
                }
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.label)
                .padding(.bottom, 20)

                // Search bar
                NavigationLink(destination: SearchView()) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("Search for surplus near you...")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.systemGray5), lineWidth: 1.5)
                            )
                    )
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Categories")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
                Button("View All") {}
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(foodCategories, id: \.label) { cat in
                        CategoryPill(cat: cat)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Freshly Rescued
    private var freshlyRescuedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Freshly Rescued")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 11))
                    Text("New Today")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.Colors.primaryGradientStart.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 16)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                VStack(spacing: 28) {
                    ForEach(viewModel.listings) { listing in
                        FigmaListingCard(listing: listing) {
                            selectedListing = listing
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Data
    private let foodCategories: [(emoji: String, label: String, color: Color)] = [
        ("🥐", "Bakery",  Color.orange.opacity(0.12)),
        ("🥗", "Healthy", Color.green.opacity(0.12)),
        ("🍱", "Sushi",   Color.red.opacity(0.10)),
        ("🍕", "Pizza",   Color.yellow.opacity(0.12)),
        ("🍝", "Pasta",   Color.blue.opacity(0.10)),
        ("🧃", "Drinks",  Color.purple.opacity(0.10)),
    ]
}

// MARK: - Category Pill
private struct CategoryPill: View {
    let cat: (emoji: String, label: String, color: Color)

    var body: some View {
        VStack(spacing: 6) {
            Text(cat.emoji)
                .font(.system(size: 28))
            Text(cat.label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(width: 76, height: 96)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cat.color)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
        )
    }
}

// MARK: - Figma-style Listing Card
struct FigmaListingCard: View {
    let listing: FoodListing
    let onTap: () -> Void

    var body: some View {
        Button(action: { onTap(); hapticFeedback(.light) }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .bottom) {
                    AsyncImage(url: nil) { _ in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Theme.Colors.primaryGradientStart.opacity(0.3),
                                        Theme.Colors.primaryGradientEnd.opacity(0.5)
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    } placeholder: {
                        ZStack {
                            Theme.Colors.primaryGradient
                            Image(systemName: listing.category.icon)
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 200)
                    .clipped()

                    // Tags overlay
                    HStack {
                        ForEach(listing.dietaryInfo.prefix(2), id: \.self) { tag in
                            Text(tag.rawValue)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.black.opacity(0.35).blendMode(.normal))
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding(14)

                    // Rating badge
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.yellow)
                                Text("4.8")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.label)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        Spacer()
                    }
                    .padding(14)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28))

                // Info row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(listing.restaurantName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                        HStack(spacing: 14) {
                            Label("Pickup: 6–8 PM", systemImage: "clock")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                            Label("0.5 mi", systemImage: "location")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(String(format: "%.2f", listing.discountedPrice))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("$\(String(format: "%.2f", listing.originalPrice))")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .strikethrough()
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Listing Detail View (sheet)
struct ListingDetailView: View {
    let listing: FoodListing
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Hero image placeholder
                    ZStack {
                        Theme.Colors.primaryGradient
                        Image(systemName: listing.category.icon)
                            .font(.system(size: 64))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, Theme.Spacing.lg)

                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text(listing.title)
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.Colors.label)
                        Text(listing.restaurantName)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Text(listing.description)
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryLabel)

                        // Price row
                        HStack {
                            Text("$\(String(format: "%.2f", listing.discountedPrice))")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.Colors.primaryGradient)
                            Text("$\(String(format: "%.2f", listing.originalPrice))")
                                .font(Theme.Typography.title3)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .strikethrough()
                            Spacer()
                            Text("\(Int(listing.savingsPercentage))% off")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.Colors.primaryGradientStart.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        PrimaryButton("Reserve Now") {
                            hapticFeedback(.success)
                            dismiss()
                        }
                        .padding(.top, Theme.Spacing.sm)
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }
        }
    }
}
