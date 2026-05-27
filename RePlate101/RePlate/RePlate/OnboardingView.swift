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

// MARK: - Onboarding
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var showAuth = false

    // Page 0 is the welcome/splash; pages 1-3 are feature pages
    let featurePages: [OnboardingPage] = [
        OnboardingPage(icon: "leaf.fill",             title: "Save Food, Save Planet",  description: "Connect with local restaurants to rescue surplus food at amazing prices"),
        OnboardingPage(icon: "dollarsign.circle.fill", title: "Great Deals Daily",       description: "Get delicious meals at up to 70% off — or even free"),
        OnboardingPage(icon: "heart.fill",             title: "Make an Impact",          description: "Every meal saved reduces food waste and helps the environment")
    ]

    // Total pages including the welcome splash
    private var totalPages: Int { featurePages.count + 1 }

    var body: some View {
        ZStack {
            Theme.Colors.primaryGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip (hidden on welcome page)
                HStack {
                    Spacer()
                    if currentPage > 0 {
                        Button("Skip") { showAuth = true }
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                    } else {
                        Color.clear.frame(height: 44).padding()
                    }
                }

                // Pages (welcome + features)
                TabView(selection: $currentPage) {
                    // Page 0 — Welcome / splash
                    welcomePage
                        .tag(0)

                    ForEach(0..<featurePages.count, id: \.self) { i in
                        OnboardingPageView(page: featurePages[i])
                            .tag(i + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Dot indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.white : Color.white.opacity(0.35))
                            .frame(width: i == currentPage ? 20 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, Theme.Spacing.md)

                // Action button
                VStack(spacing: Theme.Spacing.md) {
                    if currentPage == totalPages - 1 {
                        Button { showAuth = true } label: { ctaLabel("Get Started") }
                    } else if currentPage == 0 {
                        VStack(spacing: Theme.Spacing.sm) {
                            Button { showAuth = true } label: { ctaLabel("Get Started") }
                            Button("Already have an account? Sign In") { showAuth = true }
                                .font(Theme.Typography.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                        }
                    } else {
                        Button { withAnimation { currentPage += 1 } } label: { ctaLabel("Continue") }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
        }
        .fullScreenCover(isPresented: $showAuth) { AuthenticationView() }
    }

    private func ctaLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.Typography.headline)
            .foregroundColor(Theme.Colors.primaryGradientStart)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.white)
            .cornerRadius(Theme.CornerRadius.xxl)
    }

    // MARK: Welcome page
    private var welcomePage: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // App icon + wordmark
            VStack(spacing: Theme.Spacing.lg) {
                RePlateIconView(size: 100)

                VStack(spacing: Theme.Spacing.xs) {
                    Text("RePlate")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Reducing food waste,\none delicious meal at a time.")
                        .font(Theme.Typography.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            // Feature highlights
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                welcomeFeature(icon: "leaf.fill",             color: Theme.Colors.accent, title: "Eco-Friendly",  subtitle: "Reduce your carbon footprint")
                welcomeFeature(icon: "fork.knife",            color: .white,              title: "Fresh Food",    subtitle: "Quality surplus at low cost")
                welcomeFeature(icon: "person.2.fill",         color: Theme.Colors.accent, title: "Community",     subtitle: "Help local businesses thrive")
            }
            .padding(.horizontal, Theme.Spacing.xl)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    private func welcomeFeature(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(Theme.Typography.headline).foregroundColor(.white)
                Text(subtitle).font(Theme.Typography.caption).foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 160, height: 160)
                Image(systemName: page.icon)
                    .font(.system(size: 72, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: Theme.Spacing.md) {
                Text(page.title)
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(Theme.Typography.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }

            Spacer()
        }
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
