//
//  RootView.swift
//  RePlate
//
//  Root navigation and authentication flow
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showWelcome = true
    @State private var showUserTypeSelection = false
    @State private var showSignIn = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                // Authenticated views
                MainTabView(userType: user.userType)
                    .transition(.opacity)
            } else {
                // Onboarding flow
                if showWelcome {
                    WelcomeView {
                        withAnimation {
                            showWelcome = false
                            showUserTypeSelection = true
                        }
                    }
                    .transition(.opacity)
                } else if showUserTypeSelection {
                    UserTypeSelectionView(selectedType: $authViewModel.userType) {
                        withAnimation {
                            showUserTypeSelection = false
                            showSignIn = true
                        }
                    }
                    .transition(.slide)
                } else if showSignIn {
                    SignInView(viewModel: authViewModel)
                        .transition(.slide)
                }
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    let userType: UserType
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch userType {
                case .customer:
                    customerTabContent
                case .restaurant:
                    restaurantTabContent
                }
            }
            
            // Custom tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                tabs: userType == .customer ? customerTabs : restaurantTabs
            )
        }
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private var customerTabContent: some View {
        switch selectedTab {
        case 0:
            CustomerHomeView()
        case 1:
            OrdersView()
        case 2:
            ImpactView()
        case 3:
            ProfileView()
        default:
            CustomerHomeView()
        }
    }
    
    @ViewBuilder
    private var restaurantTabContent: some View {
        switch selectedTab {
        case 0:
            RestaurantDashboardView()
        case 1:
            RestaurantOrdersView()
        case 2:
            ImpactView()
        case 3:
            ProfileView()
        default:
            RestaurantDashboardView()
        }
    }
    
    private var customerTabs: [TabItem] {
        [
            TabItem(icon: "house.fill", title: "Home"),
            TabItem(icon: "bag.fill", title: "Orders"),
            TabItem(icon: "leaf.fill", title: "Impact"),
            TabItem(icon: "person.fill", title: "Profile")
        ]
    }
    
    private var restaurantTabs: [TabItem] {
        [
            TabItem(icon: "square.grid.2x2.fill", title: "Dashboard"),
            TabItem(icon: "list.bullet.clipboard.fill", title: "Orders"),
            TabItem(icon: "leaf.fill", title: "Impact"),
            TabItem(icon: "person.fill", title: "Profile")
        ]
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabBarButton(
                    icon: tab.icon,
                    title: tab.title,
                    isSelected: selectedTab == index
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
        .background(
            ZStack {
                BlurView(style: .systemMaterial)
                Color.cardBackground.opacity(0.8)
            }
            .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(Color.divider)
                .frame(height: 0.5),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .primaryGradientStart : .textTertiary)
                    .frame(height: 24)
                
                Text(title)
                    .font(.labelSmall)
                    .foregroundColor(isSelected ? .primaryGradientStart : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

struct TabItem {
    let icon: String
    let title: String
}

// MARK: - Placeholder Views
struct OrdersView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Orders")
                        .font(.displaySmall)
                        .fontWeight(.bold)
                    
                    EmptyStateView(
                        icon: "bag",
                        title: "No orders yet",
                        message: "Your claimed food items will appear here"
                    )
                }
                .padding()
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct ImpactView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Your Impact")
                        .font(.displaySmall)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Impact cards
                    VStack(spacing: Spacing.md) {
                        ImpactCard(
                            icon: "fork.knife",
                            value: "42",
                            label: "Meals Saved",
                            color: .primaryGradientStart
                        )
                        
                        ImpactCard(
                            icon: "leaf.fill",
                            value: "127 lbs",
                            label: "CO₂ Reduced",
                            color: .success
                        )
                        
                        ImpactCard(
                            icon: "scale.3d",
                            value: "84 lbs",
                            label: "Food Rescued",
                            color: .info
                        )
                    }
                    .padding(.horizontal)
                    
                    // Community impact
                    RPCard {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Community Impact")
                                .font(.titleMedium)
                                .fontWeight(.semibold)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("1.2M+")
                                        .font(.headlineMedium)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryGradientStart)
                                    Text("Total meals saved")
                                        .font(.bodySmall)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("5,432")
                                        .font(.headlineMedium)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryGradientStart)
                                    Text("Active users")
                                        .font(.bodySmall)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct ImpactCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        RPCard {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.titleLarge)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(value)
                        .font(.headlineSmall)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text(label)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Profile header
                    VStack(spacing: Spacing.md) {
                        Circle()
                            .fill(Color.primaryGradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(authViewModel.currentUser?.name.prefix(1).uppercased() ?? "U")
                                    .font(.displaySmall)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(authViewModel.currentUser?.name ?? "User")
                            .font(.headlineSmall)
                            .fontWeight(.bold)
                        
                        Text(authViewModel.currentUser?.email ?? "")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, Spacing.xl)
                    
                    // Settings sections
                    VStack(spacing: Spacing.md) {
                        SettingsSection(title: "Account") {
                            SettingsRow(icon: "person.fill", title: "Edit Profile", showChevron: true) {}
                            SettingsRow(icon: "bell.fill", title: "Notifications", showChevron: true) {}
                            SettingsRow(icon: "creditcard.fill", title: "Payment Methods", showChevron: true) {}
                        }
                        
                        SettingsSection(title: "Preferences") {
                            SettingsRow(icon: "moon.fill", title: "Appearance", showChevron: true) {}
                            SettingsRow(icon: "globe", title: "Language", showChevron: true) {}
                        }
                        
                        SettingsSection(title: "Support") {
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help Center", showChevron: true) {}
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", showChevron: true) {}
                            SettingsRow(icon: "lock.shield.fill", title: "Privacy Policy", showChevron: true) {}
                        }
                        
                        SettingsSection(title: "Data") {
                            SettingsRow(icon: "arrow.down.doc.fill", title: "Export Data", showChevron: true) {}
                            SettingsRow(icon: "trash.fill", title: "Delete Account", showChevron: true, isDestructive: true) {}
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign out button
                    RPButton("Sign Out", style: .destructive) {
                        authViewModel.signOut()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, Layout.tabBarHeight + Spacing.md)
                }
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.labelLarge)
                .foregroundColor(.textSecondary)
                .padding(.horizontal, Spacing.md)
            
            RPCard(padding: 0) {
                content
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = false
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.shared.light()
            action()
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.titleSmall)
                    .foregroundColor(isDestructive ? .error : .primaryGradientStart)
                    .frame(width: 24)
                
                Text(title)
                    .font(.bodyLarge)
                    .foregroundColor(isDestructive ? .error : .textPrimary)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.labelMedium)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        
        if showChevron {
            Divider()
                .padding(.leading, Spacing.md + 24 + Spacing.md)
        }
    }
}

struct RestaurantDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Dashboard")
                        .font(.displaySmall)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    EmptyStateView(
                        icon: "square.grid.2x2",
                        title: "Restaurant Dashboard",
                        message: "Your restaurant analytics and listings will appear here"
                    )
                }
                .padding(.top)
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct RestaurantOrdersView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Orders")
                        .font(.displaySmall)
                        .fontWeight(.bold)
                    
                    EmptyStateView(
                        icon: "list.bullet.clipboard",
                        title: "No orders yet",
                        message: "Customer orders will appear here"
                    )
                }
                .padding()
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(AppSettings())
    }
}
