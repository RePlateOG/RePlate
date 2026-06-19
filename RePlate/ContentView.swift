//
//  ContentView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                Group {
                    if !appState.hasCompletedOnboarding {
                        OnboardingView()
                    } else if !appState.isAuthenticated {
                        AuthenticationView()
                    } else {
                        MainTabView()
                    }
                }
            }
        }
        .preferredColorScheme(appState.colorScheme.colorScheme)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.5)) { showSplash = false }
            }
        }
    }
}

// MARK: - Splash Screen
struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Theme.Colors.primaryGradient.ignoresSafeArea()

            VStack(spacing: 20) {
                RePlateIconView(size: 110)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("RePlate")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(opacity)

                Text("Rescue food. Save the planet.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            // Permanent gradient backdrop — always fills the status-bar area so
            // there is never a white gap behind the clock / battery / signal icons
            // during page transitions or lazy-load pauses.
            Theme.Colors.primaryGradient
                .ignoresSafeArea()

            TabView(selection: $appState.selectedTab) {
                // Home
                if appState.currentUser?.accountType == .restaurant {
                    RestaurantDashboardView()
                        .tag(AppState.Tab.home)
                } else {
                    HomeView()
                        .tag(AppState.Tab.home)
                }

                // Search / Insights
                if appState.currentUser?.accountType == .restaurant {
                    RestaurantInsightsView()
                        .tag(AppState.Tab.search)
                } else {
                    SearchView()
                        .tag(AppState.Tab.search)
                }

                // Orders
                if appState.currentUser?.accountType == .restaurant {
                    RestaurantOrdersView()
                        .tag(AppState.Tab.orders)
                } else {
                    OrdersView()
                        .tag(AppState.Tab.orders)
                }

                // Messages
                MessagesView()
                    .tag(AppState.Tab.messages)

                // Profile
                if appState.currentUser?.accountType == .restaurant {
                    RestaurantProfileView()
                        .tag(AppState.Tab.profile)
                } else {
                    ProfileView()
                        .tag(AppState.Tab.profile)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Tab Bar
            CustomTabBar(selectedTab: $appState.selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: AppState.Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppState.Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                    hapticFeedback(.light)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.iconFilled : tab.icon)
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == tab ? Theme.Colors.primaryGradientStart : Theme.Colors.secondaryLabel)
                        
                        Text(tab.rawValue)
                            .font(Theme.Typography.caption2)
                            .foregroundColor(selectedTab == tab ? Theme.Colors.primaryGradientStart : Theme.Colors.secondaryLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.top, Theme.Spacing.sm)
        .padding(.bottom, Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.xl)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 18, y: -2)
        )
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
