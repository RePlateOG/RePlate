//
//  OrdersView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

struct OrdersView: View {
    @StateObject private var viewModel = OrdersViewModel()
    @State private var selectedOrder: Order?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Orders", selection: $viewModel.selectedTab) {
                    Text("Active").tag(0)
                    Text("Completed").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(Theme.Spacing.lg)
                
                // Content
                TabView(selection: $viewModel.selectedTab) {
                    // Active Orders
                    activeOrdersList
                        .tag(0)
                    
                    // Completed Orders
                    completedOrdersList
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Theme.Colors.background)
            .navigationTitle("My Orders")
            .task {
                await viewModel.loadOrders()
            }
            .sheet(item: $selectedOrder) { order in
                OrderDetailView(order: order)
            }
        }
    }
    
    private var activeOrdersList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                if viewModel.isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonView()
                            .frame(height: 200)
                            .padding(.horizontal, Theme.Spacing.lg)
                    }
                } else if viewModel.pendingOrders.isEmpty {
                    EmptyStateView(
                        icon: "bag",
                        title: "No Active Orders",
                        message: "Your active orders will appear here"
                    )
                    .padding(.top, Theme.Spacing.xxl)
                } else {
                    ForEach(viewModel.pendingOrders) { order in
                        OrderCard(order: order) {
                            selectedOrder = order
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
        .refreshable {
            await viewModel.loadOrders()
        }
    }
    
    private var completedOrdersList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.md) {
                if viewModel.isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        SkeletonView()
                            .frame(height: 200)
                            .padding(.horizontal, Theme.Spacing.lg)
                    }
                } else if viewModel.completedOrders.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No Completed Orders",
                        message: "Your order history will appear here"
                    )
                    .padding(.top, Theme.Spacing.xxl)
                } else {
                    ForEach(viewModel.completedOrders) { order in
                        OrderCard(order: order) {
                            selectedOrder = order
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
        .refreshable {
            await viewModel.loadOrders()
        }
    }
}

// MARK: - Order Detail View
struct OrderDetailView: View {
    @Environment(\.dismiss) var dismiss
    let order: Order
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Status
                    statusSection
                    
                    // Pickup Code
                    if order.status == .ready || order.status == .confirmed {
                        pickupCodeSection
                    }
                    
                    // Order Details
                    orderDetailsSection
                    
                    // Restaurant Info
                    if let restaurant = order.restaurant {
                        restaurantSection(restaurant)
                    }
                    
                    // Timeline
                    timelineSection
                    
                    // Actions
                    if order.status != .completed && order.status != .cancelled {
                        actionButtons
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var statusSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: order.status.icon)
                .font(.system(size: 60))
                .foregroundColor(order.status.color)
            
            Text(order.status.rawValue)
                .font(Theme.Typography.title2)
                .foregroundColor(Theme.Colors.label)
            
            if order.status == .ready {
                Text("Your order is ready for pickup!")
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(order.status.color.opacity(0.1))
        .cornerRadius(Theme.CornerRadius.xl)
    }
    
    private var pickupCodeSection: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Text("Your Pickup Code")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            Text(order.pickupCode)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.Colors.primaryGradient)
            
            Text("Show this code to the restaurant")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(Theme.Colors.accent.opacity(0.2))
        .cornerRadius(Theme.CornerRadius.xl)
    }
    
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Order Details")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: Theme.Spacing.sm) {
                if let listing = order.listing {
                    detailRow(label: "Item", value: listing.title)
                }
                detailRow(label: "Quantity", value: "\(order.quantity)")
                detailRow(label: "Total", value: "$\(String(format: "%.2f", order.totalAmount))")
                detailRow(
                    label: "Pickup Window",
                    value: "\(order.pickupWindowStart.formatted(date: .abbreviated, time: .shortened)) - \(order.pickupWindowEnd.formatted(date: .omitted, time: .shortened))"
                )
                detailRow(label: "Order ID", value: order.id)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private func restaurantSection(_ restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Restaurant")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
            
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Colors.primaryGradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                    
                    Text(restaurant.address)
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                    
                    Text(restaurant.phoneNumber)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Order Timeline")
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.label)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                TimelineItem(
                    icon: "checkmark.circle.fill",
                    title: "Order Placed",
                    time: order.createdAt,
                    isCompleted: true
                )
                
                TimelineItem(
                    icon: "clock.fill",
                    title: "Confirmed",
                    time: order.createdAt,
                    isCompleted: order.status != .pending
                )
                
                TimelineItem(
                    icon: "bag.fill",
                    title: "Ready for Pickup",
                    time: order.pickupWindowStart,
                    isCompleted: order.status == .ready || order.status == .completed
                )
                
                TimelineItem(
                    icon: "checkmark.circle.fill",
                    title: "Completed",
                    time: order.completedAt,
                    isCompleted: order.status == .completed
                )
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: Theme.Spacing.md) {
            PrimaryButton("Contact Restaurant") {
                // Contact action
            }
            
            Button("Get Directions") {
                // Directions action
            }
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primaryGradientStart)
            
            if order.status == .pending {
                Button("Cancel Order") {
                    // Cancel action
                }
                .font(Theme.Typography.subheadline)
                .foregroundColor(.red)
            }
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
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
}

// MARK: - Timeline Item
struct TimelineItem: View {
    let icon: String
    let title: String
    let time: Date?
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isCompleted ? Theme.Colors.primaryGradientStart : Theme.Colors.tertiaryLabel)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(isCompleted ? Theme.Colors.label : Theme.Colors.tertiaryLabel)
                
                if let time = time {
                    Text(time.formatted(date: .abbreviated, time: .shortened))
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
            
            Spacer()
        }
    }
}
