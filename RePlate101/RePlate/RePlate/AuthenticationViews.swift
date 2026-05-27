//
//  AuthenticationViews.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/27/26.
//

import SwiftUI

// MARK: - Account Type Selection
struct AccountTypeSelectionView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedType: User.AccountType?
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // App Icon
                RePlateIconView(size: 90)
                
                // Wordmark
                Text("RePlate")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "118b50"), Color(hex: "5db996")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Label
                Text("I am a…")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                
                // Account Type Cards
                VStack(spacing: 16) {
                    AccountTypeCard(
                        type: .customer,
                        icon: "person.fill",
                        title: "Customer",
                        subtitle: "Discover great deals on surplus food",
                        isSelected: selectedType == .customer
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedType = .customer
                        }
                        hapticFeedback(.light)
                    }
                    
                    AccountTypeCard(
                        type: .restaurant,
                        icon: "fork.knife",
                        title: "Restaurant",
                        subtitle: "Reduce waste and reach more customers",
                        isSelected: selectedType == .restaurant
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedType = .restaurant
                        }
                        hapticFeedback(.light)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button {
                        hapticFeedback(.medium)
                        showSignUp = true
                    } label: {
                        Text("Sign Up")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Group {
                                    if selectedType != nil {
                                        LinearGradient(
                                            colors: [Color(hex: "118b50"), Color(hex: "5db996")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(999)
                    }
                    .disabled(selectedType == nil)
                    
                    Button {
                        hapticFeedback(.light)
                        showSignIn = true
                    } label: {
                        Text("Already have an account? Sign In")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "118b50"))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showSignUp) {
            if let type = selectedType {
                SignUpView(accountType: type)
            }
        }
    }
}

// MARK: - Account Type Card
struct AccountTypeCard: View {
    let type: User.AccountType
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "118b50"), Color(hex: "5db996")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                    } else {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 56, height: 56)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "118b50"))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "f9f9f9"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: "118b50") : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// NOTE: SignInView, SignUpView, SocialSignInButton, CheckboxToggleStyle
// are defined in OnboardingView.swift (use AppState environment object).
// Removed duplicates here to avoid "Invalid redeclaration" build errors.
