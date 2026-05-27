//
//  RestaurantViews.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import PhotosUI

// MARK: - Restaurant Dashboard
struct RestaurantDashboardView: View {
    @StateObject private var viewModel = RestaurantDashboardViewModel()
    @State private var showPostListing = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sectionSpacing) {
                        // Hero Header with Greeting
                        heroHeader
                        
                        // Stats Cards - Premium Design
                        statsSection
                        
                        // Quick Actions - Redesigned
                        quickActionsSection
                        
                        // Active Listings
                        activeListingsSection
                        
                        // Pending Orders
                        pendingOrdersSection
                        
                        // Environmental Impact Section
                        impactSection
                    }
                    .padding(.bottom, 120)
                }
                .refreshable {
                    await viewModel.refreshDashboard()
                }
                
                // Premium FAB with Label
                PremiumFAB(icon: "plus", label: "Post", style: .large) {
                    showPostListing = true
                }
                .padding(Theme.Spacing.xl)
                .padding(.bottom, Theme.Layout.fabOffset)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadDashboard()
            }
            .sheet(isPresented: $showPostListing) {
                PostListingView()
            }
        }
    }
    
    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(greetingText)
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                    
                    Text("Dashboard")
                        .font(Theme.Typography.largeTitleHeavy)
                        .foregroundStyle(Theme.Colors.primaryGradient)
                }
                
                Spacer()
                
                // Notification Bell
                Button {
                    // Navigate to notifications
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Theme.Colors.label)
                            .frame(width: 44, height: 44)
                            .background(Theme.Colors.secondaryBackground)
                            .cornerRadius(Theme.CornerRadius.base)
                        
                        // Notification Badge
                        if viewModel.hasUnreadNotifications {
                            Circle()
                                .fill(Theme.Colors.error)
                                .frame(width: 10, height: 10)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.screenPadding)
        .padding(.top, Theme.Spacing.base)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    // MARK: - Stats Section - Premium Redesign
    private var statsSection: some View {
        VStack(spacing: Theme.Spacing.itemSpacing) {
            SectionHeader(title: "Today's Overview")
            
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Theme.Spacing.itemSpacing
            ) {
                PremiumStatCard(
                    icon: "bag.fill",
                    value: "\(viewModel.todayStats.activeListings)",
                    label: "Active",
                    color: Theme.Colors.info,
                    showGlow: true
                )
                
                PremiumStatCard(
                    icon: "clock.arrow.circlepath",
                    value: "\(viewModel.todayStats.pendingOrders)",
                    label: "Pending",
                    color: Theme.Colors.warning,
                    showGlow: true
                )
                
                PremiumStatCard(
                    icon: "dollarsign.circle.fill",
                    value: "$\(String(format: "%.0f", viewModel.todayStats.revenueToday))",
                    label: "Revenue",
                    color: Theme.Colors.success,
                    showGlow: true
                )
                
                PremiumStatCard(
                    icon: "leaf.circle.fill",
                    value: "\(viewModel.todayStats.mealsSaved)",
                    label: "Saved",
                    color: Theme.Colors.primaryGradientStart,
                    showGlow: true
                )
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }
    
    // MARK: - Quick Actions - Premium Redesign
    private var quickActionsSection: some View {
        VStack(spacing: Theme.Spacing.itemSpacing) {
            SectionHeader(title: "Quick Actions")
            
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Theme.Spacing.compactSpacing
            ) {
                PremiumQuickActionCard(
                    icon: "plus.circle.fill",
                    title: "Post Surplus",
                    gradient: Theme.Colors.primaryGradient
                ) {
                    showPostListing = true
                }
                
                PremiumQuickActionCard(
                    icon: "arrow.clockwise.circle.fill",
                    title: "Repost",
                    gradient: LinearGradient(colors: [Theme.Colors.info, Theme.Colors.info.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    // Repost action
                }
                
                PremiumQuickActionCard(
                    icon: "chart.bar.fill",
                    title: "Analytics",
                    gradient: LinearGradient(colors: [Color.purple, Color.purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    // Analytics action
                }
                
                PremiumQuickActionCard(
                    icon: "gearshape.fill",
                    title: "Settings",
                    gradient: LinearGradient(colors: [Color.gray, Color.gray.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                ) {
                    // Settings action
                }
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }
    
    // MARK: - Active Listings - Premium Redesign
    private var activeListingsSection: some View {
        VStack(spacing: Theme.Spacing.itemSpacing) {
            SectionHeader(
                title: "Active Listings",
                actionTitle: viewModel.activeListings.isEmpty ? nil : "View All"
            ) {
                // View all action
            }
            
            if viewModel.isLoading {
                VStack(spacing: Theme.Spacing.compactSpacing) {
                    ForEach(0..<2, id: \.self) { _ in
                        ShimmerView(cornerRadius: Theme.CornerRadius.cardLarge)
                            .frame(height: 140)
                            .padding(.horizontal, Theme.Spacing.screenPadding)
                    }
                }
            } else if viewModel.activeListings.isEmpty {
                PremiumEmptyState(
                    icon: "fork.knife",
                    title: "No Active Listings",
                    message: "Start rescuing food by posting your first surplus listing",
                    actionTitle: "Post Listing",
                    action: {
                        showPostListing = true
                    }
                )
                .padding(.horizontal, Theme.Spacing.screenPadding)
                .padding(.vertical, Theme.Spacing.xl)
            } else {
                ForEach(viewModel.activeListings.prefix(3)) { listing in
                    PremiumRestaurantListingCard(listing: listing)
                        .padding(.horizontal, Theme.Spacing.screenPadding)
                }
            }
        }
    }
    
    // MARK: - Pending Orders - Premium Redesign
    private var pendingOrdersSection: some View {
        VStack(spacing: Theme.Spacing.itemSpacing) {
            SectionHeader(
                title: "Pending Orders",
                actionTitle: viewModel.pendingOrders.isEmpty ? nil : "View All"
            ) {
                // View all action
            }
            
            if viewModel.pendingOrders.isEmpty {
                PremiumCard(style: .flat, padding: Theme.Spacing.xl) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Theme.Colors.primaryGradient)
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text("All Caught Up!")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.label)
                            
                            Text("No pending orders at the moment")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
            } else {
                ForEach(viewModel.pendingOrders.prefix(3)) { order in
                    PremiumRestaurantOrderCard(order: order)
                        .padding(.horizontal, Theme.Spacing.screenPadding)
                }
            }
        }
    }
    
    // MARK: - Impact Section
    private var impactSection: some View {
        VStack(spacing: Theme.Spacing.itemSpacing) {
            SectionHeader(title: "Environmental Impact")
            
            PremiumCard(style: .elevated) {
                VStack(spacing: Theme.Spacing.lg) {
                    HStack(spacing: Theme.Spacing.base) {
                        ImpactMetric(
                            icon: "leaf.fill",
                            value: "\(viewModel.todayStats.mealsSaved)",
                            label: "Meals Saved",
                            color: Theme.Colors.impactGreen
                        )
                        
                        Divider()
                            .frame(height: 60)
                        
                        ImpactMetric(
                            icon: "arrow.down.circle.fill",
                            value: "\(String(format: "%.1f", Double(viewModel.todayStats.mealsSaved) * 2.5)) kg",
                            label: "CO₂ Reduced",
                            color: Theme.Colors.impactBlue
                        )
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.Colors.primaryGradient)
                        
                        Text("Every meal saved prevents ~2.5kg of CO₂ emissions")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }
}

// MARK: - Dashboard Stat Card
struct DashboardStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
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

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.label)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 100)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
}

// MARK: - Restaurant Listing Card
struct RestaurantListingCard: View {
    let listing: FoodListing
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Thumbnail
            if let imageURL = listing.imageURLs.first {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Theme.Colors.tertiaryBackground)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(Theme.CornerRadius.md)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(listing.title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.label)
                    .lineLimit(1)
                
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "bag")
                        .font(.caption)
                    Text("\(listing.availableQuantity) of \(listing.quantity) left")
                        .font(Theme.Typography.subheadline)
                }
                .foregroundColor(Theme.Colors.secondaryLabel)
                
                if listing.isFree {
                    Text("FREE")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.green)
                } else {
                    Text("$\(String(format: "%.2f", listing.discountedPrice))")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }
            
            Spacer()
            
            VStack(spacing: Theme.Spacing.xs) {
                Menu {
                    Button {
                        // Edit action
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        // Pause action
                    } label: {
                        Label("Pause", systemImage: "pause")
                    }
                    
                    Button(role: .destructive) {
                        // Delete action
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.xl)
    }
}

// MARK: - Restaurant Order Card
struct RestaurantOrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let listing = order.listing {
                        Text(listing.title)
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.label)
                    }
                    
                    Text("Order #\(order.pickupCode)")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.status.rawValue)
                        .font(Theme.Typography.caption)
                        .foregroundColor(order.status.color)
                    
                    Text("$\(String(format: "%.2f", order.totalAmount))")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                }
            }
            
            Divider()
            
            HStack(spacing: Theme.Spacing.md) {
                Button {
                    // Mark as ready
                } label: {
                    Text("Mark Ready")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.Colors.primaryGradient)
                        .cornerRadius(Theme.CornerRadius.md)
                }
                
                Button {
                    // Contact customer
                } label: {
                    Image(systemName: "message.fill")
                        .font(.title3)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(width: 44, height: 44)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.xl)
    }
}

// MARK: - Post Listing View
struct PostListingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PostListingViewModel()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var currentStep = 0
    
    let steps = ["Photos", "Details", "Pricing", "Pickup", "Review"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicator
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Photos
                    photosStep
                        .tag(0)
                    
                    // Step 2: Details
                    detailsStep
                        .tag(1)
                    
                    // Step 3: Pricing
                    pricingStep
                        .tag(2)
                    
                    // Step 4: Pickup
                    pickupStep
                        .tag(3)
                    
                    // Step 5: Review
                    reviewStep
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation Buttons
                navigationButtons
            }
            .background(Theme.Colors.background)
            .navigationTitle("Post Surplus Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success!", isPresented: $viewModel.showSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your listing has been posted successfully!")
            }
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack(spacing: 4) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.tertiaryBackground], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            Text("Step \(currentStep + 1) of \(steps.count): \(steps[currentStep])")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .padding(.vertical, Theme.Spacing.md)
    }
    
    // MARK: - Step 1: Photos
    private var photosStep: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                Text("Add Photos")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.label)
                
                Text("Upload at least one photo of your food")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 5, matching: .images) {
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.Colors.primaryGradient)
                        
                        Text("Tap to select photos")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.xl)
                }
                
                if !viewModel.selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(0..<viewModel.selectedImages.count, id: \.self) { index in
                                Image(uiImage: viewModel.selectedImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(Theme.CornerRadius.md)
                            }
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .onChange(of: selectedPhotos) { _, newPhotos in
            Task {
                viewModel.selectedImages = []
                for photo in newPhotos {
                    if let data = try? await photo.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    // MARK: - Step 2: Details
    private var detailsStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                CustomTextField(
                    placeholder: "Food Title",
                    text: $viewModel.title,
                    icon: "fork.knife"
                )
                
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Description")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                    
                    TextEditor(text: $viewModel.description)
                        .frame(height: 120)
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Category")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.sm) {
                            ForEach(FoodListing.FoodCategory.allCases, id: \.self) { category in
                                Button {
                                    viewModel.category = category
                                    hapticFeedback(.light)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: category.icon)
                                        Text(category.rawValue)
                                    }
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(viewModel.category == category ? .white : Theme.Colors.label)
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .padding(.vertical, Theme.Spacing.sm)
                                    .background(viewModel.category == category ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(Theme.CornerRadius.xl)
                                }
                            }
                        }
                    }
                }
                
                CustomTextField(
                    placeholder: "Quantity Available",
                    text: $viewModel.quantity,
                    icon: "number"
                )
                .keyboardType(.numberPad)
            }
            .padding(Theme.Spacing.lg)
        }
    }
    
    // MARK: - Step 3: Pricing
    private var pricingStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Toggle(isOn: $viewModel.isFree) {
                    Text("Offer for Free")
                        .font(Theme.Typography.headline)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.md)
                
                if !viewModel.isFree {
                    CustomTextField(
                        placeholder: "Original Price",
                        text: $viewModel.originalPrice,
                        icon: "dollarsign.circle"
                    )
                    .keyboardType(.decimalPad)
                    
                    CustomTextField(
                        placeholder: "Discounted Price",
                        text: $viewModel.discountedPrice,
                        icon: "tag"
                    )
                    .keyboardType(.decimalPad)
                    
                    Button {
                        viewModel.suggestPrice()
                        hapticFeedback()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Suggest Price (50% off)")
                        }
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.accent.opacity(0.2))
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
    }
    
    // MARK: - Step 4: Pickup
    private var pickupStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Pickup Window")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.label)
                
                DatePicker(
                    "Start Time",
                    selection: $viewModel.pickupStartTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                
                DatePicker(
                    "End Time",
                    selection: $viewModel.pickupEndTime,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                
                Text("Dietary Information")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.label)
                    .padding(.top, Theme.Spacing.md)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.sm) {
                    ForEach(FoodListing.DietaryInfo.allCases, id: \.self) { info in
                        Button {
                            if viewModel.selectedDietaryInfo.contains(info) {
                                viewModel.selectedDietaryInfo.remove(info)
                            } else {
                                viewModel.selectedDietaryInfo.insert(info)
                            }
                            hapticFeedback(.light)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: info.icon)
                                Text(info.rawValue)
                            }
                            .font(Theme.Typography.caption)
                            .foregroundColor(viewModel.selectedDietaryInfo.contains(info) ? .white : Theme.Colors.label)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(viewModel.selectedDietaryInfo.contains(info) ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(Theme.CornerRadius.md)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
        }
    }
    
    // MARK: - Step 5: Review
    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("Review Your Listing")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.label)
                
                VStack(spacing: Theme.Spacing.md) {
                    reviewRow(label: "Title", value: viewModel.title)
                    reviewRow(label: "Category", value: viewModel.category.rawValue)
                    reviewRow(label: "Quantity", value: viewModel.quantity)
                    
                    if viewModel.isFree {
                        reviewRow(label: "Price", value: "FREE")
                    } else {
                        reviewRow(label: "Price", value: "$\(viewModel.discountedPrice)")
                        reviewRow(label: "Original Price", value: "$\(viewModel.originalPrice)")
                    }
                    
                    reviewRow(
                        label: "Pickup Window",
                        value: "\(viewModel.pickupStartTime.formatted(date: .abbreviated, time: .shortened)) - \(viewModel.pickupEndTime.formatted(date: .omitted, time: .shortened))"
                    )
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.xl)
            }
            .padding(Theme.Spacing.lg)
        }
    }
    
    private func reviewRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.secondaryLabel)
            Spacer()
            Text(value)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.label)
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: Theme.Spacing.md) {
            if currentStep > 0 {
                SecondaryButton("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
            }
            
            if currentStep < steps.count - 1 {
                PrimaryButton("Continue") {
                    withAnimation {
                        currentStep += 1
                    }
                }
            } else {
                PrimaryButton("Post Listing", isLoading: viewModel.isPosting) {
                    Task {
                        await viewModel.postListing()
                    }
                }
                .disabled(!viewModel.canPost)
                .opacity(viewModel.canPost ? 1 : 0.5)
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.background)
    }
}
// MARK: - Premium Stat Card
struct PremiumStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let showGlow: Bool
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                if showGlow {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .blur(radius: 12)
                }
                
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: Theme.Spacing.xxs) {
                Text(value)
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.label)
                
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
        .background(Theme.Colors.elevatedCard)
        .cornerRadius(Theme.CornerRadius.cardLarge)
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Premium Quick Action Card
struct PremiumQuickActionCard: View {
    let icon: String
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            action()
        }) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(gradient)
                    .frame(height: 32)
                
                Text(title)
                    .font(Theme.Typography.subheadlineMedium)
                    .foregroundColor(Theme.Colors.label)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(Theme.Colors.elevatedCard)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Premium Restaurant Listing Card
struct PremiumRestaurantListingCard: View {
    let listing: FoodListing
    
    var body: some View {
        HStack(spacing: Theme.Spacing.base) {
            // Thumbnail with Gradient Overlay
            ZStack(alignment: .bottomLeading) {
                if let imageURL = listing.imageURLs.first {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Theme.Colors.tertiaryBackground)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(Theme.Colors.tertiaryLabel)
                            )
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(Theme.CornerRadius.lg)
                }
                
                // Status Badge
                if listing.isAlmostGone {
                    PremiumBadge(text: "Almost Gone", style: .filled(Theme.Colors.warning))
                        .padding(Theme.Spacing.xs)
                }
            }
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(listing.title)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.label)
                    .lineLimit(2)
                
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "bag")
                        .font(.caption)
                    Text("\(listing.availableQuantity) of \(listing.quantity) left")
                        .font(Theme.Typography.subheadline)
                }
                .foregroundColor(Theme.Colors.secondaryLabel)
                
                Spacer()
                
                HStack {
                    if listing.isFree {
                        PremiumBadge(text: "FREE", style: .gradient)
                    } else {
                        Text("$\(String(format: "%.2f", listing.discountedPrice))")
                            .font(Theme.Typography.headlineMedium)
                            .foregroundStyle(Theme.Colors.primaryGradient)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            // Edit action
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            // Pause action
                        } label: {
                            Label("Pause", systemImage: "pause")
                        }
                        
                        Button(role: .destructive) {
                            // Delete action
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .frame(width: 32, height: 32)
                            .background(Theme.Colors.tertiaryBackground)
                            .cornerRadius(Theme.CornerRadius.xs)
                    }
                }
            }
        }
        .padding(Theme.Spacing.base)
        .background(Theme.Colors.elevatedCard)
        .cornerRadius(Theme.CornerRadius.cardLarge)
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Premium Restaurant Order Card
struct PremiumRestaurantOrderCard: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: Theme.Spacing.base) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    if let listing = order.listing {
                        Text(listing.title)
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.label)
                    }
                    
                    HStack(spacing: Theme.Spacing.xs) {
                        Text("Order")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Text("#\(order.pickupCode)")
                            .font(Theme.Typography.monospaced)
                            .foregroundColor(Theme.Colors.label)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                    PremiumBadge(
                        text: order.status.rawValue,
                        style: .filled(order.status.color)
                    )
                    
                    Text("$\(String(format: "%.2f", order.totalAmount))")
                        .font(Theme.Typography.headlineMedium)
                        .foregroundColor(Theme.Colors.label)
                }
            }
            
            Divider()
            
            HStack(spacing: Theme.Spacing.compactSpacing) {
                AnimatedButton("Mark Ready", style: .primary) {
                    // Mark as ready
                }
                
                Button {
                    // Contact customer
                } label: {
                    Image(systemName: "message.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(width: 56, height: 56)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.base)
                }
                .buttonStyle(PremiumScaleButtonStyle())
            }
        }
        .padding(Theme.Spacing.cardPadding)
        .background(Theme.Colors.elevatedCard)
        .cornerRadius(Theme.CornerRadius.cardLarge)
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Premium Empty State
struct PremiumEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.primaryGradient)
            }
            
            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.label)
                
                Text(message)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let actionTitle = actionTitle, let action = action {
                AnimatedButton(actionTitle, icon: "plus", style: .primary, action: action)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .padding(Theme.Spacing.xl)
    }
}

// MARK: - Impact Metric
struct ImpactMetric: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(Theme.Typography.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.label)
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

