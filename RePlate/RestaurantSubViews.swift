//
//  RestaurantSubViews.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/30/26.
//  Restaurant sub-screens: settings hub, edit listing, order details,
//  restaurant profile edit, location/pickup edit, payment settings,
//  notification preferences, help center, contact support, and messaging.
//

import SwiftUI

// MARK: - Shared: Section label
private func sectionLabel(_ title: String) -> some View {
    Text(title.uppercased())
        .font(.system(size: 11, weight: .bold, design: .rounded))
        .foregroundColor(Theme.Colors.secondaryLabel)
        .tracking(0.8)
        .padding(.horizontal, 4)
}

// MARK: - Shared: Sub-screen gradient header (X dismiss style)
private struct SubScreenHeader: View {
    let title: String
    let subtitle: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { hapticFeedback(.light); onDismiss() }) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.22))
                            .frame(width: 40, height: 40)
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 12)

            Text(title)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 4)
                .padding(.bottom, 36)
        }
        .padding(.horizontal, 20)
        .background(Theme.Colors.primaryGradient)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))
    }
}

// MARK: - Shared: White form card wrapper
private struct FormCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }
}

// MARK: - Shared: Save button
private struct SaveButton: View {
    @Binding var isSaving: Bool
    let onSave: () -> Void

    var body: some View {
        Button {
            hapticFeedback(.success)
            isSaving = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isSaving = false
                onSave()
            }
        } label: {
            HStack(spacing: 8) {
                if isSaving { ProgressView().tint(.white).scaleEffect(0.85) }
                Text(isSaving ? "Saving…" : "Save Changes")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Theme.Colors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.32), radius: 10, y: 5)
        }
        .disabled(isSaving)
    }
}

// MARK: - Restaurant Settings Hub
struct RestaurantSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showRestaurantDetails = false
    @State private var showLocationPickup = false
    @State private var showPaymentSettings = false
    @State private var showNotifications = false
    @State private var showHelpCenter = false
    @State private var showContactSupport = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Settings",
                    subtitle: "Manage your restaurant account",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // MARK: Restaurant Profile
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Restaurant Profile")
                        FormCard {
                            VStack(spacing: 0) {
                                settingsRow(
                                    icon: "storefront.fill",
                                    title: "Restaurant Details",
                                    subtitle: "Name, cuisine & hours"
                                ) { showRestaurantDetails = true }
                                Divider().padding(.leading, 58)
                                settingsRow(
                                    icon: "location.fill",
                                    title: "Location & Pickup",
                                    subtitle: "Address and pickup instructions"
                                ) { showLocationPickup = true }
                            }
                        }
                    }

                    // MARK: Financials
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Financials")
                        FormCard {
                            settingsRow(
                                icon: "banknote.fill",
                                title: "Payment Settings",
                                subtitle: "Bank and payout details"
                            ) { showPaymentSettings = true }
                        }
                    }

                    // MARK: Preferences
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Preferences")
                        FormCard {
                            settingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                subtitle: "Push and email preferences"
                            ) { showNotifications = true }
                        }
                    }

                    // MARK: Support
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Support")
                        FormCard {
                            VStack(spacing: 0) {
                                settingsRow(
                                    icon: "questionmark.circle.fill",
                                    title: "Help Center",
                                    subtitle: "FAQs and tutorials"
                                ) { showHelpCenter = true }
                                Divider().padding(.leading, 58)
                                settingsRow(
                                    icon: "bubble.left.fill",
                                    title: "Contact Support",
                                    subtitle: "Get help from our team"
                                ) { showContactSupport = true }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showRestaurantDetails) { RestaurantDetailsEditView() }
        .sheet(isPresented: $showLocationPickup)    { LocationPickupEditView() }
        .sheet(isPresented: $showPaymentSettings)   { PaymentSettingsView() }
        .sheet(isPresented: $showNotifications)     { NotificationsPreferencesView() }
        .sheet(isPresented: $showHelpCenter)        { HelpCenterView() }
        .sheet(isPresented: $showContactSupport)    { ContactSupportView() }
    }

    private func settingsRow(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            hapticFeedback(.light)
            action()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Listing View
struct EditListingView: View {
    let listing: FoodListing
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var quantity: String
    @State private var isFree: Bool
    @State private var originalPrice: String
    @State private var discountedPrice: String
    @State private var pickupStart: Date
    @State private var pickupEnd: Date
    @State private var availableUntilClose = false
    @State private var isSaving = false

    init(listing: FoodListing) {
        self.listing = listing
        _title           = State(initialValue: listing.title)
        _description     = State(initialValue: listing.description)
        _quantity        = State(initialValue: "\(listing.availableQuantity)")
        _isFree          = State(initialValue: listing.isFree)
        _originalPrice   = State(initialValue: String(format: "%.2f", listing.originalPrice))
        _discountedPrice = State(initialValue: String(format: "%.2f", listing.discountedPrice))
        _pickupStart     = State(initialValue: listing.pickupStartTime)
        _pickupEnd       = State(initialValue: listing.pickupEndTime)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Edit Listing",
                    subtitle: listing.title,
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // Photo row
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Photos")
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Theme.Colors.primaryGradientStart.opacity(0.06))
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    Theme.Colors.primaryGradientStart.opacity(0.35),
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                                )
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(Theme.Colors.primaryGradientStart.opacity(0.55))
                                Text("Tap to update photos")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Theme.Colors.secondaryLabel)
                            }
                        }
                        .frame(height: 130)
                    }

                    // Details
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Details")
                        FormCard {
                            VStack(spacing: 16) {
                                AuthLabeledField(label: "Title", placeholder: "e.g. Assorted Pastries", text: $title)
                                AuthLabeledField(label: "Description", placeholder: "Describe the food…", text: $description)
                                AuthLabeledField(
                                    label: "Quantity Available",
                                    placeholder: "Number of boxes",
                                    text: $quantity,
                                    keyboardType: .numberPad
                                )
                            }
                        }
                    }

                    // Pricing
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Pricing")
                        FormCard {
                            VStack(spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Offer for Free")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(Theme.Colors.label)
                                        Text("No payment required from customer")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(Theme.Colors.secondaryLabel)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $isFree)
                                        .tint(Theme.Colors.primaryGradientStart)
                                }
                                if !isFree {
                                    Divider()
                                    AuthLabeledField(
                                        label: "Original Price ($)",
                                        placeholder: "e.g. 12.00",
                                        text: $originalPrice,
                                        keyboardType: .decimalPad
                                    )
                                    AuthLabeledField(
                                        label: "Discounted Price ($)",
                                        placeholder: "e.g. 5.00",
                                        text: $discountedPrice,
                                        keyboardType: .decimalPad
                                    )
                                }
                            }
                        }
                    }

                    // Pickup Window
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Pickup Window")
                        FormCard {
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Available Until Close")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(Theme.Colors.label)
                                        Text("Pickup any time until store closes")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(Theme.Colors.secondaryLabel)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $availableUntilClose)
                                        .tint(Theme.Colors.primaryGradientStart)
                                }
                                if !availableUntilClose {
                                    Divider()
                                    DatePicker(
                                        "Pickup Start",
                                        selection: $pickupStart,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    DatePicker(
                                        "Pickup End",
                                        selection: $pickupEnd,
                                        in: pickupStart...,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                }
                            }
                        }
                    }

                    SaveButton(isSaving: $isSaving) { dismiss() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Restaurant Order Detail View
struct RestaurantOrderDetailView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    @State private var showMessage = false
    @State private var isMarkedPickedUp = false

    private var customerName: String   { order.customer?.name        ?? "Customer" }
    private var customerPhone: String  { order.customer?.phoneNumber  ?? "—" }
    private var customerNote: String   { order.notes                  ?? "No special instructions." }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Custom header (has status badge on right)
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.22))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "xmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        Spacer()
                        // Status pill
                        Text(isMarkedPickedUp ? "Completed" : order.status.rawValue)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(isMarkedPickedUp ? .white : order.status.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(isMarkedPickedUp ? Theme.Colors.primaryGradientStart : order.status.color.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                    Text("Order Details")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Code: \(order.pickupCode)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                        .padding(.bottom, 36)
                }
                .padding(.horizontal, 20)
                .background(Theme.Colors.primaryGradient)
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))

                VStack(spacing: 20) {
                    // Customer Info
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Customer")
                        FormCard {
                            VStack(spacing: 0) {
                                customerInfoRow(icon: "person.fill",   label: "Name",  value: customerName)
                                Divider().padding(.leading, 54)
                                customerInfoRow(icon: "phone.fill",    label: "Phone", value: customerPhone)
                                Divider().padding(.leading, 54)
                                customerInfoRow(icon: "note.text",     label: "Note",  value: customerNote)
                            }
                        }
                    }

                    // Order Items
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Order Items")
                        FormCard {
                            VStack(spacing: 0) {
                                if let listing = order.listing {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: listing.category.icon)
                                                .font(.system(size: 18))
                                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                        }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(listing.title)
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(Theme.Colors.label)
                                            Text("Qty: \(order.quantity)")
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(Theme.Colors.secondaryLabel)
                                        }
                                        Spacer()
                                        Text(listing.isFree ? "FREE" : "$\(String(format: "%.2f", order.totalAmount))")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundStyle(Theme.Colors.primaryGradient)
                                    }
                                    .padding(.vertical, 4)
                                }

                                Divider().padding(.top, 14)

                                HStack {
                                    Text("Total")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.Colors.label)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", order.totalAmount))")
                                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                                        .foregroundStyle(Theme.Colors.primaryGradient)
                                }
                                .padding(.top, 14)
                            }
                        }
                    }

                    // Pickup Details
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Pickup")
                        FormCard {
                            VStack(spacing: 0) {
                                pickupDetailRow(
                                    icon: "number",
                                    label: "Pickup Code",
                                    value: order.pickupCode,
                                    monospaced: true
                                )
                                Divider().padding(.leading, 54)
                                pickupDetailRow(
                                    icon: "clock.fill",
                                    label: "Window",
                                    value: "\(order.pickupWindowStart.formatted(date: .omitted, time: .shortened)) – \(order.pickupWindowEnd.formatted(date: .omitted, time: .shortened))"
                                )
                            }
                        }
                    }

                    // CTAs
                    VStack(spacing: 14) {
                        Button {
                            hapticFeedback(.success)
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                isMarkedPickedUp = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isMarkedPickedUp ? "checkmark.circle.fill" : "bag.badge.checkmark")
                                    .font(.system(size: 17, weight: .bold))
                                Text(isMarkedPickedUp ? "Order Completed!" : "Mark as Picked Up")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                isMarkedPickedUp
                                    ? LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
                                    : Theme.Colors.primaryGradient
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Theme.Colors.primaryGradientStart.opacity(isMarkedPickedUp ? 0 : 0.3), radius: 10, y: 5)
                        }
                        .disabled(isMarkedPickedUp)

                        Button {
                            hapticFeedback(.light)
                            showMessage = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Message Customer")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Theme.Colors.primaryGradientStart.opacity(0.4), lineWidth: 1.5)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showMessage) {
            MessageCustomerView(order: order)
        }
    }

    private func customerInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private func pickupDetailRow(icon: String, label: String, value: String, monospaced: Bool = false) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
            Spacer()
            if monospaced {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Theme.Colors.primaryGradient)
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Restaurant Details Edit
struct RestaurantDetailsEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var restaurantName = "Verde Bistro"
    @State private var cuisine = "Mediterranean"
    @State private var phone = "+1 (555) 234-5678"
    @State private var openTime  = Calendar.current.date(from: DateComponents(hour: 9,  minute: 0)) ?? Date()
    @State private var closeTime = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var isSaving = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Restaurant Details",
                    subtitle: "Update your restaurant's profile",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // Logo upload area
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Theme.Colors.primaryGradientStart.opacity(0.07))
                                .frame(width: 100, height: 100)
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    Theme.Colors.primaryGradientStart.opacity(0.35),
                                    style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                                )
                                .frame(width: 100, height: 100)
                            VStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Theme.Colors.primaryGradientStart.opacity(0.65))
                                Text("Logo")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(Theme.Colors.secondaryLabel)
                            }
                        }
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Basic Info")
                        FormCard {
                            VStack(spacing: 16) {
                                AuthLabeledField(
                                    label: "Restaurant Name",
                                    placeholder: "e.g. Verde Bistro",
                                    text: $restaurantName
                                )
                                AuthLabeledField(
                                    label: "Cuisine Type",
                                    placeholder: "e.g. Mediterranean, Italian",
                                    text: $cuisine
                                )
                                AuthLabeledField(
                                    label: "Phone Number",
                                    placeholder: "+1 (555) 000-0000",
                                    text: $phone,
                                    keyboardType: .phonePad
                                )
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Operating Hours")
                        FormCard {
                            VStack(spacing: 14) {
                                DatePicker("Opens", selection: $openTime, displayedComponents: .hourAndMinute)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                DatePicker("Closes", selection: $closeTime, in: openTime..., displayedComponents: .hourAndMinute)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                            }
                        }
                    }

                    SaveButton(isSaving: $isSaving) { dismiss() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Location & Pickup Edit
struct LocationPickupEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var street = "742 Evergreen Terrace"
    @State private var city = "Springfield"
    @State private var stateName = "CA"
    @State private var zip = "90210"
    @State private var pickupInstructions = "Enter through the side door. Ring bell for assistance."
    @State private var isSaving = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Location & Pickup",
                    subtitle: "Set your address and pickup details",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Address")
                        FormCard {
                            VStack(spacing: 16) {
                                AuthLabeledField(label: "Street Address", placeholder: "123 Main St", text: $street)
                                AuthLabeledField(label: "City", placeholder: "e.g. San Francisco", text: $city)
                                HStack(spacing: 12) {
                                    AuthLabeledField(label: "State", placeholder: "CA", text: $stateName)
                                    AuthLabeledField(
                                        label: "ZIP Code",
                                        placeholder: "94102",
                                        text: $zip,
                                        keyboardType: .numberPad
                                    )
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Pickup Instructions")
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Instructions")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                            TextEditor(text: $pickupInstructions)
                                .frame(height: 100)
                                .scrollContentBackground(.hidden)
                                .padding(14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            pickupInstructions.isEmpty
                                                ? Color.clear
                                                : Theme.Colors.primaryGradientStart.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                        }
                    }

                    SaveButton(isSaving: $isSaving) { dismiss() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Payment Settings
struct PaymentSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var bankName = ""
    @State private var accountHolder = ""
    @State private var accountNumber = ""
    @State private var routingNumber = ""
    @State private var isSaving = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Payment Settings",
                    subtitle: "Configure your payout details",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // Security info banner
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("Your payment information is encrypted and stored securely.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Theme.Colors.primaryGradientStart.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Bank Details")
                        FormCard {
                            VStack(spacing: 16) {
                                AuthLabeledField(label: "Bank Name", placeholder: "e.g. Chase Bank", text: $bankName)
                                AuthLabeledField(label: "Account Holder", placeholder: "Full legal name", text: $accountHolder)
                                AuthLabeledField(
                                    label: "Account Number",
                                    placeholder: "•••• •••• ••••",
                                    text: $accountNumber,
                                    keyboardType: .numberPad
                                )
                                AuthLabeledField(
                                    label: "Routing Number",
                                    placeholder: "9 digits",
                                    text: $routingNumber,
                                    keyboardType: .numberPad
                                )
                            }
                        }
                    }

                    SaveButton(isSaving: $isSaving) { dismiss() }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Notifications Preferences
struct NotificationsPreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var newOrders      = true
    @State private var reminders      = true
    @State private var confirmations  = true
    @State private var reviews        = false
    @State private var emailDigest    = true
    @State private var emailPromo     = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Notifications",
                    subtitle: "Choose how RePlate reaches you",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // Push
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Push Notifications")
                        FormCard {
                            VStack(spacing: 0) {
                                notifToggle(icon: "bag.fill",                         title: "New Orders",      subtitle: "Alert when a customer places an order",     isOn: $newOrders)
                                Divider().padding(.leading, 54)
                                notifToggle(icon: "clock.badge.exclamationmark.fill", title: "Reminders",       subtitle: "Before pickup window closes",               isOn: $reminders)
                                Divider().padding(.leading, 54)
                                notifToggle(icon: "checkmark.seal.fill",              title: "Confirmations",   subtitle: "Pickup confirmed by customer",              isOn: $confirmations)
                                Divider().padding(.leading, 54)
                                notifToggle(icon: "star.fill",                        title: "Reviews",         subtitle: "New customer review posted",               isOn: $reviews)
                            }
                        }
                    }

                    // Email
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Email")
                        FormCard {
                            VStack(spacing: 0) {
                                notifToggle(icon: "chart.bar.fill",  title: "Weekly Digest",  subtitle: "Your weekly impact report",   isOn: $emailDigest)
                                Divider().padding(.leading, 54)
                                notifToggle(icon: "megaphone.fill",  title: "Promotions",     subtitle: "Tips and product updates",    isOn: $emailPromo)
                            }
                        }
                    }

                    Button {
                        hapticFeedback(.success)
                        dismiss()
                    } label: {
                        Text("Save Preferences")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.Colors.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.32), radius: 10, y: 5)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }

    private func notifToggle(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(Theme.Colors.primaryGradientStart)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Help Center
struct HelpCenterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expanded: String? = nil
    @State private var showContact = false

    private let faqs: [(title: String, icon: String, items: [(q: String, a: String)])] = [
        (
            title: "Getting Started",
            icon: "star.circle.fill",
            items: [
                (
                    q: "How do I post my first listing?",
                    a: "Tap 'Post Surplus Food' on your dashboard. Fill in the food details, set a pickup window, and publish — it goes live instantly."
                ),
                (
                    q: "What types of food can I list?",
                    a: "Any safe, edible surplus: baked goods, prepared meals, produce, beverages, and packaged snacks."
                ),
            ]
        ),
        (
            title: "Managing Orders",
            icon: "list.bullet.clipboard.fill",
            items: [
                (
                    q: "How do I confirm a pickup?",
                    a: "When the customer arrives, ask for their pickup code and tap 'Mark as Picked Up' in the order details screen."
                ),
                (
                    q: "What if a customer doesn't show?",
                    a: "If a customer misses their window, mark the order as No Show. We'll notify the customer and release the item back to the listing."
                ),
            ]
        ),
        (
            title: "Payments",
            icon: "creditcard.fill",
            items: [
                (
                    q: "When do I get paid?",
                    a: "Payouts are processed every Monday for the previous week's completed orders. Funds arrive in 2–3 business days."
                ),
                (
                    q: "What fees does RePlate charge?",
                    a: "RePlate charges a 15% platform fee on paid listings. Free listings have no fee — giving away food is always free."
                ),
            ]
        ),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Help Center",
                    subtitle: "Answers to common questions",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // FAQ accordions
                    VStack(spacing: 14) {
                        ForEach(faqs, id: \.title) { category in
                            VStack(alignment: .leading, spacing: 0) {
                                Button {
                                    hapticFeedback(.light)
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        expanded = expanded == category.title ? nil : category.title
                                    }
                                } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: category.icon)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                        }
                                        Text(category.title)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(Theme.Colors.label)
                                        Spacer()
                                        Image(systemName: expanded == category.title ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Theme.Colors.secondaryLabel)
                                    }
                                    .padding(18)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if expanded == category.title {
                                    ForEach(category.items, id: \.q) { item in
                                        Divider().padding(.horizontal, 18)
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(item.q)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Theme.Colors.label)
                                            Text(item.a)
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundColor(Theme.Colors.secondaryLabel)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 14)
                                    }
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
                        }
                    }

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Quick Actions")
                        HStack(spacing: 14) {
                            helpQuickAction(icon: "play.rectangle.fill", label: "Video Tutorials") {}
                            helpQuickAction(icon: "message.fill",        label: "Contact Support") {
                                showContact = true
                            }
                        }
                    }

                    // Still need help?
                    VStack(spacing: 12) {
                        Text("Still need help?")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                        Text("Our support team typically responds within 2 hours during business hours.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .multilineTextAlignment(.center)
                        Button {
                            hapticFeedback(.light)
                            showContact = true
                        } label: {
                            Text("Get in Touch")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.Colors.primaryGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showContact) { ContactSupportView() }
    }

    private func helpQuickAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: { hapticFeedback(.light); action() }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
                Text(label)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Contact Support
struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory = "Technical Issue"
    @State private var subject = ""
    @State private var message = ""
    @State private var isSending = false
    @State private var showConfirmation = false

    private let categories = ["Technical Issue", "Payment Help", "Order Problem", "Feature Request", "Other"]

    private var canSend: Bool { !subject.trimmingCharacters(in: .whitespaces).isEmpty && !message.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Contact Support",
                    subtitle: "We'll get back to you shortly",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("Your Message")
                        FormCard {
                            VStack(spacing: 16) {
                                // Category menu
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Category")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Theme.Colors.secondaryLabel)
                                    Menu {
                                        ForEach(categories, id: \.self) { cat in
                                            Button(cat) { selectedCategory = cat }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedCategory)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundColor(Theme.Colors.label)
                                            Spacer()
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.Colors.secondaryLabel)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }

                                AuthLabeledField(label: "Subject", placeholder: "Brief description of your issue", text: $subject)

                                // Message editor
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Message")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Theme.Colors.secondaryLabel)
                                    TextEditor(text: $message)
                                        .frame(height: 120)
                                        .scrollContentBackground(.hidden)
                                        .padding(14)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    message.isEmpty ? Color.clear : Theme.Colors.primaryGradientStart.opacity(0.4),
                                                    lineWidth: 1.5
                                                )
                                        )
                                }
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        Button {
                            hapticFeedback(.success)
                            isSending = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                isSending = false
                                showConfirmation = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isSending { ProgressView().tint(.white).scaleEffect(0.85) }
                                Text(isSending ? "Sending…" : "Send Message")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.Colors.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Theme.Colors.primaryGradientStart.opacity(canSend ? 0.32 : 0), radius: 10, y: 5)
                        }
                        .disabled(!canSend || isSending)
                        .opacity(canSend ? 1 : 0.5)

                        Button("Cancel") { dismiss() }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .alert("Message Sent!", isPresented: $showConfirmation) {
            Button("Done") { dismiss() }
        } message: {
            Text("We've received your message and will respond within 2 business hours.")
        }
    }
}

// MARK: - Staff Accounts View
struct StaffAccountsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAddForm = false
    @State private var newName  = ""
    @State private var newEmail = ""
    @State private var newRole  = "Staff"
    private let roles = ["Staff", "Manager", "Admin"]

    // Internal model — not persisted
    @State private var staffMembers: [StaffMember] = [
        StaffMember(name: "Maria Garcia", email: "maria@verde.com", role: "Manager"),
        StaffMember(name: "Luca Rossi",   email: "luca@verde.com",  role: "Staff"),
    ]

    private struct StaffMember: Identifiable {
        let id = UUID()
        let name: String
        let email: String
        let role: String
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                SubScreenHeader(
                    title: "Staff Accounts",
                    subtitle: "Manage your team's access",
                    onDismiss: { dismiss() }
                )

                VStack(spacing: 24) {
                    // Info banner
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("Staff will receive an email invitation to download RePlate and join your restaurant.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Theme.Colors.primaryGradientStart.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    // Add form / button
                    if showAddForm {
                        addMemberForm
                    } else {
                        addMemberButton
                    }

                    // Staff list
                    if !staffMembers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionLabel("Team Members (\(staffMembers.count))")
                            VStack(spacing: 10) {
                                ForEach(staffMembers) { member in
                                    staffCard(member: member)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: Add button
    private var addMemberButton: some View {
        Button {
            hapticFeedback(.medium)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showAddForm = true }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: 38, height: 38)
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Add Staff Member")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                Spacer()
            }
            .padding(18)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color.black.opacity(0.07), radius: 10, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Inline add form
    private var addMemberForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("New Staff Member")
            FormCard {
                VStack(spacing: 16) {
                    AuthLabeledField(label: "Full Name", placeholder: "e.g. Jane Smith",     text: $newName)
                    AuthLabeledField(label: "Email",     placeholder: "jane@restaurant.com", text: $newEmail, keyboardType: .emailAddress)

                    // Role chips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Role")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        HStack(spacing: 10) {
                            ForEach(roles, id: \.self) { role in
                                Button {
                                    hapticFeedback(.light)
                                    newRole = role
                                } label: {
                                    Text(role)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(newRole == role ? .white : Theme.Colors.label)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(
                                            newRole == role
                                                ? Theme.Colors.primaryGradient
                                                : LinearGradient(
                                                    colors: [Color(.systemGray6)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                        )
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        Button("Cancel") {
                            hapticFeedback(.light)
                            withAnimation { showAddForm = false }
                            newName = ""; newEmail = ""; newRole = "Staff"
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        let canSend = !newName.trimmingCharacters(in: .whitespaces).isEmpty &&
                                      !newEmail.trimmingCharacters(in: .whitespaces).isEmpty

                        Button("Send Invite") {
                            guard canSend else { return }
                            hapticFeedback(.success)
                            let m = StaffMember(name: newName, email: newEmail, role: newRole)
                            withAnimation { staffMembers.append(m); showAddForm = false }
                            newName = ""; newEmail = ""; newRole = "Staff"
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .opacity(canSend ? 1 : 0.5)
                        .disabled(!canSend)
                    }
                }
            }
        }
    }

    // MARK: Staff card row
    private func staffCard(member: StaffMember) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(String(member.name.prefix(1)).uppercased())
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text(member.email)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
            Spacer()
            Text(member.role)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.Colors.primaryGradientStart.opacity(0.1))
                .clipShape(Capsule())

            Button {
                hapticFeedback(.light)
                withAnimation { staffMembers.removeAll { $0.id == member.id } }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 34, height: 34)
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
    }
}

// MARK: - Message Customer View
private struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromRestaurant: Bool
    let timestamp: Date
}

struct MessageCustomerView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I just placed an order for pickup.", isFromRestaurant: false, timestamp: Date().addingTimeInterval(-600)),
        ChatMessage(text: "Great, we're getting it ready for you now!", isFromRestaurant: true, timestamp: Date().addingTimeInterval(-540)),
        ChatMessage(text: "Should I enter through the main entrance?", isFromRestaurant: false, timestamp: Date().addingTimeInterval(-300)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header (no scroll, fixed at top)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.22))
                                .frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)

                Text(order.customer?.name ?? "Customer")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("Order #\(order.pickupCode)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 4)
                    .padding(.bottom, 22)
            }
            .padding(.horizontal, 20)
            .padding(.top, 44) // safe area
            .background(Theme.Colors.primaryGradient)
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))

            // Message list
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField("Type a message…", text: $messageText)
                    .font(.system(size: 15, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Button {
                    let trimmed = messageText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    hapticFeedback(.light)
                    let newMsg = ChatMessage(text: trimmed, isFromRestaurant: true, timestamp: Date())
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        messages.append(newMsg)
                    }
                    messageText = ""
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                messageText.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? Color(.systemGray4)
                                    : Theme.Colors.primaryGradientStart
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.07), radius: 8, y: -3)
            )
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromRestaurant { Spacer(minLength: 60) }

            VStack(alignment: message.isFromRestaurant ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(message.isFromRestaurant ? .white : Theme.Colors.label)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromRestaurant
                            ? Theme.Colors.primaryGradient
                            : LinearGradient(
                                colors: [Color(.systemBackground)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius:    message.isFromRestaurant ? 20 : 4,
                            bottomLeadingRadius: 20,
                            bottomTrailingRadius: message.isFromRestaurant ? 4 : 20,
                            topTrailingRadius:   20
                        )
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }

            if !message.isFromRestaurant { Spacer(minLength: 60) }
        }
    }
}
