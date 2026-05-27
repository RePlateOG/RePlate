//
//  OnboardingView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

// MARK: - Reusable App Logo Mark
/// The green gradient square icon used as the app's logo mark throughout the UI.
struct RePlateIconView: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Theme.Colors.primaryGradient)
                .frame(width: size, height: size)
                .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.35), radius: size * 0.15, y: size * 0.07)

            Image(systemName: "fork.knife")
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Onboarding  (Figma 2.0 — single-screen welcome)
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAuth   = false
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // ── Blob decorations ──────────────────────────────────
            // Top-left blob
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.primaryGradientStart.opacity(0.35),
                            Theme.Colors.primaryGradientEnd.opacity(0.35)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -100, y: -100)

            // Bottom-right blob
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.Colors.accent.opacity(0.30),
                            Theme.Colors.primaryGradientEnd.opacity(0.25)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 50)
                .offset(x: 120, y: 400)

            // ── Content ───────────────────────────────────────────
            VStack(spacing: 0) {
                Spacer()

                // Hero circle + sparkles badge
                ZStack(alignment: .topTrailing) {
                    // Circle hero (gradient with fork icon)
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.primaryGradient)
                            .frame(width: 192, height: 192)
                            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.35),
                                    radius: 24, y: 8)
                        Image(systemName: "fork.knife")
                            .font(.system(size: 72, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .overlay(
                        Circle()
                            .stroke(Theme.Colors.accent, lineWidth: 4)
                    )

                    // Sparkles badge
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 52, height: 52)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                    .offset(x: 8, y: -8)
                }
                .padding(.bottom, 32)

                // Logo icon + wordmark + subtitle
                VStack(spacing: 12) {
                    RePlateIconView(size: 64)

                    Text("RePlate")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryGradient)

                    Text("Reducing food waste, one delicious meal at a time.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)

                // Feature rows
                VStack(spacing: 14) {
                    WelcomeFeatureRow(
                        icon: "leaf.fill",
                        iconBackground: Theme.Colors.primaryGradientStart,
                        title: "Eco-Friendly",
                        subtitle: "Reduce your carbon footprint"
                    )
                    WelcomeFeatureRow(
                        icon: "fork.knife",
                        iconBackground: Theme.Colors.primaryGradientEnd,
                        title: "Fresh Food",
                        subtitle: "Quality surplus at low cost"
                    )
                    WelcomeFeatureRow(
                        icon: "heart.fill",
                        iconBackground: Theme.Colors.accent,
                        title: "Community",
                        subtitle: "Help local businesses thrive",
                        iconForeground: Theme.Colors.primaryGradientStart
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        hapticFeedback(.medium)
                        showAuth = true
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.35),
                                    radius: 12, y: 5)
                    }

                    Button {
                        hapticFeedback(.light)
                        showSignIn = true
                    } label: {
                        Text("Log In")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .fullScreenCover(isPresented: $showAuth)   { AuthenticationView() }
        .sheet(isPresented: $showSignIn)            { SignInView() }
    }
}

// MARK: - Welcome Feature Row
private struct WelcomeFeatureRow: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let subtitle: String
    var iconForeground: Color = .white

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconForeground)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSignIn = false
    @State private var showSignUp = false
    @State private var selectedAccountType: User.AccountType?
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // Logo
                VStack(spacing: Theme.Spacing.md) {
                    RePlateIconView(size: 80)

                    Text("RePlate")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                }
                .padding(.bottom, Theme.Spacing.xl)
                
                // Account type selection
                VStack(spacing: Theme.Spacing.md) {
                    Text("I am a...")
                        .font(Theme.Typography.title3)
                        .foregroundColor(Theme.Colors.label)
                    
                    HStack(spacing: Theme.Spacing.md) {
                        ForEach(User.AccountType.allCases, id: \.self) { type in
                            AccountTypeButton(
                                type: type,
                                isSelected: selectedAccountType == type
                            ) {
                                selectedAccountType = type
                                hapticFeedback()
                            }
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.lg)
                
                Spacer()
                
                // Auth buttons
                VStack(spacing: Theme.Spacing.md) {
                    PrimaryButton("Sign Up") {
                        showSignUp = true
                    }
                    .disabled(selectedAccountType == nil)
                    .opacity(selectedAccountType == nil ? 0.5 : 1)
                    
                    Button("Already have an account? Sign In") {
                        showSignIn = true
                    }
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                }
                .padding(Theme.Spacing.lg)
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
        }
        .sheet(isPresented: $showSignUp) {
            if let accountType = selectedAccountType {
                SignUpView(accountType: accountType)
            }
        }
    }
}

struct AccountTypeButton: View {
    let type: User.AccountType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : Theme.Colors.primaryGradientStart)
                
                Text(type.displayName)
                    .font(Theme.Typography.headline)
                    .foregroundColor(isSelected ? .white : Theme.Colors.label)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                isSelected ?
                Theme.Colors.primaryGradient :
                LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(Theme.CornerRadius.xxl)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xxl)
                    .stroke(isSelected ? Color.clear : Theme.Colors.primaryGradientStart.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

// MARK: - Sign In View
struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        RePlateIconView(size: 64)

                        Text("Welcome Back")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.label)

                        Text("Sign in to continue")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.lg)
                    
                    // Form
                    VStack(spacing: Theme.Spacing.md) {
                        CustomTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope"
                        )
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        CustomTextField(
                            placeholder: "Password",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )
                        
                        Button("Forgot Password?") {
                            // Handle password reset
                        }
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Sign in button
                    PrimaryButton("Sign In", isLoading: isLoading) {
                        Task {
                            await signIn()
                        }
                    }
                    .padding(.top, Theme.Spacing.md)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Theme.Colors.tertiaryLabel)
                            .frame(height: 1)
                        Text("or")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        Rectangle()
                            .fill(Theme.Colors.tertiaryLabel)
                            .frame(height: 1)
                    }
                    .padding(.vertical, Theme.Spacing.md)
                    
                    // Social sign in
                    VStack(spacing: Theme.Spacing.md) {
                        SocialSignInButton(
                            title: "Continue with Apple",
                            icon: "apple.logo",
                            action: {
                                Task {
                                    await signInWithApple()
                                }
                            }
                        )
                        
                        SocialSignInButton(
                            title: "Continue with Google",
                            icon: "g.circle.fill",
                            action: {
                                Task {
                                    await signInWithGoogle()
                                }
                            }
                        )
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        let success = await AuthService.shared.signIn(email: email, password: password)
        if success {
            appState.isAuthenticated = true
            appState.currentUser = AuthService.shared.currentUser
            appState.completeOnboarding()
            dismiss()
        } else {
            errorMessage = AuthService.shared.errorMessage ?? "Invalid email or password"
            showError = true
        }
    }
    
    func signInWithApple() async {
        // Implement Sign in with Apple
    }
    
    func signInWithGoogle() async {
        // Implement Google Sign-In
    }
}

// MARK: - Sign Up View
struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let accountType: User.AccountType
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var agreedToTerms = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(spacing: Theme.Spacing.sm) {
                        RePlateIconView(size: 64)

                        Text("Create Account")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Colors.label)

                        Text("Join as a \(accountType.displayName)")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.lg)
                    
                    // Form
                    VStack(spacing: Theme.Spacing.md) {
                        CustomTextField(
                            placeholder: accountType == .restaurant ? "Restaurant Name" : "Full Name",
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
                            placeholder: "Password",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )
                        
                        CustomTextField(
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            icon: "lock",
                            isSecure: true
                        )
                        
                        // Terms acceptance
                        Toggle(isOn: $agreedToTerms) {
                            HStack(spacing: 4) {
                                Text("I agree to the")
                                    .font(Theme.Typography.caption)
                                Button("Terms of Service") {
                                    // Show terms
                                }
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                Text("and")
                                    .font(Theme.Typography.caption)
                                Button("Privacy Policy") {
                                    // Show privacy policy
                                }
                                .font(Theme.Typography.caption)
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                            .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                    
                    // Sign up button
                    PrimaryButton("Create Account", isLoading: isLoading) {
                        Task {
                            await signUp()
                        }
                    }
                    .disabled(!agreedToTerms)
                    .opacity(agreedToTerms ? 1 : 0.5)
                    .padding(.top, Theme.Spacing.md)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func signUp() async {
        guard validateForm() else { return }

        isLoading = true
        defer { isLoading = false }

        let success = await AuthService.shared.signUp(
            name: name,
            email: email,
            password: password,
            accountType: accountType
        )
        if success {
            appState.isAuthenticated = true
            appState.currentUser = AuthService.shared.currentUser
            appState.completeOnboarding()
            dismiss()
        } else {
            errorMessage = AuthService.shared.errorMessage ?? "Could not create account"
            showError = true
        }
    }
    
    func validateForm() -> Bool {
        if name.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        if password.count < 8 {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return false
        }
        
        return true
    }
}

// MARK: - Social Sign In Button
struct SocialSignInButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                Text(title)
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(Theme.Colors.label)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.xxl)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xxl)
                    .stroke(Theme.Colors.tertiaryLabel, lineWidth: 1)
            )
        }
    }
}

// MARK: - Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Theme.Colors.primaryGradientStart : Theme.Colors.secondaryLabel)
                .onTapGesture {
                    configuration.isOn.toggle()
                    hapticFeedback(.light)
                }
            
            configuration.label
        }
    }
}
