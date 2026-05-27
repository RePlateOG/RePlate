//
//  ProfileView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Profile Header
                    profileHeader
                    
                    // Impact Stats
                    if let user = viewModel.user {
                        impactStatsSection(user: user)
                    }
                    
                    // Menu Items
                    menuSection
                    
                    // About
                    aboutSection
                    
                    // Sign Out
                    signOutButton
                }
                .padding(.bottom, 100)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Profile")
            .task {
                await viewModel.loadProfile()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(viewModel.user?.name.prefix(1).uppercased() ?? "U")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .background(Circle().fill(Theme.Colors.background))
                }
            }
            
            VStack(spacing: 4) {
                Text(viewModel.user?.name ?? "User")
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.label)
                
                Text(viewModel.user?.email ?? "")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.secondaryLabel)
                
                if let type = viewModel.user?.accountType {
                    HStack(spacing: 4) {
                        Image(systemName: type.icon)
                        Text(type.displayName)
                    }
                    .font(Theme.Typography.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primaryGradient)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
    }
    
    // MARK: - Impact Stats
    private func impactStatsSection(user: User) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Your Impact")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                StatCard(
                    icon: "fork.knife",
                    value: "\(user.mealsSaved)",
                    label: "Meals Saved",
                    gradient: true
                )
                
                StatCard(
                    icon: "leaf.fill",
                    value: String(format: "%.1f kg", user.co2Reduced),
                    label: "CO₂ Reduced",
                    gradient: true
                )
                
                StatCard(
                    icon: "scalemass.fill",
                    value: String(format: "%.1f lbs", user.foodRescued),
                    label: "Food Rescued",
                    gradient: true
                )
                
                StatCard(
                    icon: "heart.fill",
                    value: "\(user.mealsSaved)",
                    label: "Good Deeds",
                    gradient: true
                )
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            Button {
                // Share impact
                hapticFeedback()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Your Impact")
                }
                .font(Theme.Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.primaryGradient)
                .cornerRadius(Theme.CornerRadius.xl)
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("Account")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            VStack(spacing: 0) {
                MenuButton(
                    icon: "person",
                    title: "Edit Profile",
                    action: {
                        showEditProfile = true
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "bell",
                    title: "Notifications",
                    action: {
                        showSettings = true
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "creditcard",
                    title: "Payment Methods",
                    action: {
                        // Payment methods action
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "gearshape",
                    title: "Settings",
                    action: {
                        showSettings = true
                    }
                )
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text("About")
                    .font(Theme.Typography.title3)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
            }
            .padding(.horizontal, Theme.Spacing.lg)
            
            VStack(spacing: 0) {
                MenuButton(
                    icon: "info.circle",
                    title: "About RePlate",
                    action: {
                        // About action
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "doc.text",
                    title: "Terms of Service",
                    action: {
                        // Terms action
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "lock.shield",
                    title: "Privacy Policy",
                    action: {
                        // Privacy action
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                
                MenuButton(
                    icon: "arrow.down.doc",
                    title: "Export Data",
                    action: {
                        Task {
                            await viewModel.exportData()
                        }
                    }
                )
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
            .padding(.horizontal, Theme.Spacing.lg)
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button {
            appState.signOut()
        } label: {
            Text("Sign Out")
                .font(Theme.Typography.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.md)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.xl)
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            action()
        }) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                    .frame(width: 28)
                
                Text(title)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.label)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .padding(Theme.Spacing.md)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Avatar
                    Button {
                        // Change photo
                    } label: {
                        VStack(spacing: Theme.Spacing.sm) {
                            Circle()
                                .fill(Theme.Colors.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(name.prefix(1).uppercased())
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text("Change Photo")
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.lg)
                    
                    // Form
                    VStack(spacing: Theme.Spacing.md) {
                        CustomTextField(
                            placeholder: "Name",
                            text: $name,
                            icon: "person"
                        )
                        
                        CustomTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope"
                        )
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        CustomTextField(
                            placeholder: "Phone Number (Optional)",
                            text: $phoneNumber,
                            icon: "phone"
                        )
                        .keyboardType(.phonePad)
                    }
                    
                    PrimaryButton("Save Changes", isLoading: isLoading) {
                        Task {
                            await save()
                        }
                    }
                    .padding(.top, Theme.Spacing.md)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadProfile()
                name = viewModel.user?.name ?? ""
                email = viewModel.user?.email ?? ""
                phoneNumber = viewModel.user?.phoneNumber ?? ""
            }
        }
    }
    
    func save() async {
        isLoading = true
        await viewModel.updateProfile(name: name, email: email, phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber)
        isLoading = false
        dismiss()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var notificationsEnabled = true
    @State private var pushNotificationsEnabled = true
    @State private var emailNotificationsEnabled = true
    @State private var newListingsNotifications = true
    @State private var orderUpdatesNotifications = true
    @State private var impactMilestonesNotifications = true
    @State private var showDeleteAccountConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Appearance
                    appearanceSection
                    
                    Divider()
                    
                    // Notifications
                    notificationsSection
                    
                    Divider()
                    
                    // Privacy
                    privacySection
                    
                    Divider()
                    
                    // Danger Zone
                    dangerZoneSection
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAccountConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Appearance")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: Theme.Spacing.sm) {
                ForEach(AppState.ColorSchemePreference.allCases, id: \.self) { preference in
                    Button {
                        appState.saveColorSchemePreference(preference)
                        hapticFeedback()
                    } label: {
                        HStack {
                            Text(preference.rawValue)
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.label)
                            
                            Spacer()
                            
                            if appState.colorScheme == preference {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                        }
                        .padding(Theme.Spacing.md)
                        .background(Theme.Colors.secondaryBackground)
                        .cornerRadius(Theme.CornerRadius.md)
                    }
                }
            }
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Notifications")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: 0) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .padding(Theme.Spacing.md)
                
                if notificationsEnabled {
                    Divider()
                    
                    Toggle("Push Notifications", isOn: $pushNotificationsEnabled)
                        .padding(Theme.Spacing.md)
                    
                    Divider()
                    
                    Toggle("Email Notifications", isOn: $emailNotificationsEnabled)
                        .padding(Theme.Spacing.md)
                    
                    Divider()
                    
                    Toggle("New Listings", isOn: $newListingsNotifications)
                        .padding(Theme.Spacing.md)
                    
                    Divider()
                    
                    Toggle("Order Updates", isOn: $orderUpdatesNotifications)
                        .padding(Theme.Spacing.md)
                    
                    Divider()
                    
                    Toggle("Impact Milestones", isOn: $impactMilestonesNotifications)
                        .padding(Theme.Spacing.md)
                }
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Privacy & Data")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.label)
            
            VStack(spacing: 0) {
                Button {
                    // View privacy policy
                } label: {
                    HStack {
                        Text("Privacy Policy")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.label)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                    .padding(Theme.Spacing.md)
                }
                
                Divider()
                
                Button {
                    // Export data
                } label: {
                    HStack {
                        Text("Export My Data")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.label)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.down.doc")
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                    .padding(Theme.Spacing.md)
                }
            }
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xl)
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Danger Zone")
                .font(Theme.Typography.headline)
                .foregroundColor(.red)
            
            Button {
                showDeleteAccountConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Account")
                        .font(Theme.Typography.body)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.md)
                .background(Color.red)
                .cornerRadius(Theme.CornerRadius.xl)
            }
        }
    }
    
    func deleteAccount() async {
        await ProfileViewModel().deleteAccount()
        dismiss()
    }
}
