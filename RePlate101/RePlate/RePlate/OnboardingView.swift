//
//  OnboardingView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//  Auth flow redesigned to match RePlate 2.0 Figma:
//    • AuthenticationView  → "Join the Movement" card-picker
//    • SignInView          → clean labeled form, no social buttons
//    • SignUpView          → account-type-aware (customer vs restaurant)
//

import SwiftUI

// MARK: - Reusable App Logo Mark
/// Green gradient square icon used as the app's logo mark throughout the UI.
struct RePlateIconView: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Theme.Colors.primaryGradient)
                .frame(width: size, height: size)
                .shadow(
                    color: Theme.Colors.primaryGradientStart.opacity(0.35),
                    radius: size * 0.15,
                    y: size * 0.07
                )
            Image(systemName: "fork.knife")
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Onboarding (Figma 2.0 — single-screen welcome)
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAuth   = false
    @State private var showSignIn = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Blob decorations
            Circle()
                .fill(LinearGradient(
                    colors: [
                        Theme.Colors.primaryGradientStart.opacity(0.35),
                        Theme.Colors.primaryGradientEnd.opacity(0.35)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -100, y: -100)

            Circle()
                .fill(LinearGradient(
                    colors: [
                        Theme.Colors.accent.opacity(0.30),
                        Theme.Colors.primaryGradientEnd.opacity(0.25)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 240, height: 240)
                .blur(radius: 50)
                .offset(x: 120, y: 400)

            VStack(spacing: 0) {
                Spacer()

                // Hero circle + sparkles badge
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.primaryGradient)
                            .frame(width: 192, height: 192)
                            .shadow(
                                color: Theme.Colors.primaryGradientStart.opacity(0.35),
                                radius: 24, y: 8
                            )
                        Image(systemName: "fork.knife")
                            .font(.system(size: 72, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .overlay(Circle().stroke(Theme.Colors.accent, lineWidth: 4))

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

                // Logo + wordmark + subtitle
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
                            .shadow(
                                color: Theme.Colors.primaryGradientStart.opacity(0.35),
                                radius: 12, y: 5
                            )
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
        .fullScreenCover(isPresented: $showAuth) { AuthenticationView() }
        .sheet(isPresented: $showSignIn)           { SignInView() }
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

// MARK: - Authentication View  (Figma 2.0 — "Join the Movement")
struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var showSignIn          = false
    @State private var showRestaurantSignUp = false
    @State private var showCustomerSignUp  = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            // Blob decoration
            Circle()
                .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: -80, y: -140)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Back button
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 42, height: 42)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                    // Heading
                    Text("Join the Movement")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.Colors.label)

                    Text("Choose your role in reducing food waste.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .padding(.top, 6)
                        .padding(.bottom, 36)

                    // Restaurant card
                    AccountTypePickerCard(
                        icon: "fork.knife",
                        title: "Restaurant",
                        description: "Post surplus food and track your impact.",
                        accentColor: Theme.Colors.primaryGradientStart
                    ) {
                        hapticFeedback(.medium)
                        showRestaurantSignUp = true
                    }
                    .padding(.bottom, 20)

                    // Customer card
                    AccountTypePickerCard(
                        icon: "person.fill",
                        title: "Customer",
                        description: "Discover and claim fresh surplus meals.",
                        accentColor: Theme.Colors.primaryGradientEnd
                    ) {
                        hapticFeedback(.medium)
                        showCustomerSignUp = true
                    }

                    // Footer
                    Text("You can always change this later in settings")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.tertiaryLabel)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 36)
                        .padding(.bottom, 16)

                    // Log in link
                    Button {
                        hapticFeedback(.light)
                        showSignIn = true
                    } label: {
                        (
                            Text("Already have an account?  ")
                                .foregroundColor(Theme.Colors.secondaryLabel)
                            + Text("Log In")
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                        )
                        .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showSignIn)            { SignInView() }
        .sheet(isPresented: $showRestaurantSignUp)  { SignUpView(accountType: .restaurant) }
        .sheet(isPresented: $showCustomerSignUp)    { SignUpView(accountType: .customer) }
    }
}

// MARK: - Account Type Picker Card  (Figma 2.0 image-style card)
private struct AccountTypePickerCard: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Gradient icon block (replaces photo in Figma)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 90, height: 90)
                .padding(.leading, 8)

                // Text block
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor.opacity(0.12))
                                .frame(width: 28, height: 28)
                            Image(systemName: icon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(accentColor)
                        }
                        Text(title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                    }
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 16)

                Spacer(minLength: 8)

                // Chevron in accent circle
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 34, height: 34)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(accentColor.opacity(0.25), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.07), radius: 14, y: 5)
            )
        }
        .buttonStyle(SpringyButtonStyle())
    }
}

// MARK: - Springy Button Style  (scale-on-press, shared by auth cards)
private struct SpringyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}

// MARK: - Sign In View  (Figma 2.0 — clean labeled form)
struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @State private var email    = ""
    @State private var password = ""
    @State private var isLoading  = false
    @State private var showError  = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Heading
                    Text("Welcome Back")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                        .padding(.top, 32)

                    Text("Sign in to your RePlate account")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .padding(.top, 6)
                        .padding(.bottom, 40)

                    // Form
                    VStack(spacing: 20) {
                        AuthLabeledField(
                            label: "Email",
                            placeholder: "you@example.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        .textInputAutocapitalization(.never)

                        AuthLabeledField(
                            label: "Password",
                            placeholder: "Your password",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .padding(.bottom, 12)

                    // Forgot password
                    Button("Forgot Password?") {}
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.bottom, 32)

                    // Sign in button
                    Button {
                        Task { await signIn() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(
                            color: Theme.Colors.primaryGradientStart.opacity(0.30),
                            radius: 12, y: 5
                        )
                    }
                    .disabled(isLoading)

                    // Demo hint
                    Text("Demo: use any email/password\n(use \"restaurant@…\" for a restaurant account)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.tertiaryLabel)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
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
}

// MARK: - Sign Up View  (Figma 2.0 — account-type-aware)
struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let accountType: User.AccountType

    // Shared fields
    @State private var name            = ""
    @State private var email           = ""
    @State private var password        = ""
    // Restaurant-only extras (collected in UI; stored for future profile update)
    @State private var address         = ""
    @State private var businessHours   = ""
    @State private var phoneNumber     = ""
    // Customer only
    @State private var agreedToTerms   = false
    // UI
    @State private var isLoading       = false
    @State private var showError       = false
    @State private var errorMessage    = ""

    private var isCustomer: Bool { accountType == .customer }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Subheading
                    Text(isCustomer
                         ? "Join RePlate and start saving food"
                         : "Register your restaurant with RePlate")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .padding(.top, 8)
                        .padding(.bottom, 28)

                    // ── Customer: photo upload circle ─────────────────
                    if isCustomer {
                        customerPhotoUpload
                            .padding(.bottom, 28)
                    } else {
                        restaurantLogoUpload
                            .padding(.bottom, 24)
                    }

                    // ── Form fields ───────────────────────────────────
                    VStack(spacing: 18) {
                        AuthLabeledField(
                            label: isCustomer ? "Full Name" : "Restaurant Name",
                            placeholder: isCustomer ? "Your name" : "e.g., Bella's Italian Kitchen",
                            text: $name
                        )

                        if !isCustomer {
                            AuthLabeledField(
                                label: "Address",
                                placeholder: "123 Main St, City, State",
                                text: $address
                            )
                            AuthLabeledField(
                                label: "Business Hours",
                                placeholder: "e.g., Mon–Fri 9AM–9PM",
                                text: $businessHours
                            )
                            AuthLabeledField(
                                label: "Phone Number",
                                placeholder: "(555) 123-4567",
                                text: $phoneNumber,
                                keyboardType: .phonePad
                            )
                        }

                        AuthLabeledField(
                            label: "Email",
                            placeholder: "you@example.com",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        .textInputAutocapitalization(.never)

                        AuthLabeledField(
                            label: "Password",
                            placeholder: "Create a secure password",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .padding(.bottom, 24)

                    // ── Special action button ─────────────────────────
                    if isCustomer {
                        locationPermissionButton
                            .padding(.bottom, 8)
                        Text("We need your location to show surplus food near you")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 24)
                    } else {
                        verifyBusinessButton
                            .padding(.bottom, 24)
                    }

                    // ── Create account button ─────────────────────────
                    Button {
                        Task { await signUp() }
                    } label: {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isCustomer ? "Create Customer Account" : "Create Business Account")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(
                            color: Theme.Colors.primaryGradientStart.opacity(0.30),
                            radius: 12, y: 5
                        )
                    }
                    .disabled(isLoading)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle(isCustomer ? "Create Account" : "Create Business Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
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

    // MARK: - Customer Photo Upload
    private var customerPhotoUpload: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 96, height: 96)
                Circle()
                    .strokeBorder(
                        Color(.systemGray4),
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )
                    .frame(width: 96, height: 96)
                Image(systemName: "camera.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            Text("Add Photo")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Restaurant Logo Upload
    private var restaurantLogoUpload: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Restaurant Logo")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.Colors.secondaryLabel)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color(.systemGray4),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                    )
                VStack(spacing: 10) {
                    Image(systemName: "arrow.up.to.line")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Theme.Colors.tertiaryLabel)
                    Text("Tap to upload logo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
            .frame(height: 130)
        }
    }

    // MARK: - Location Permission Button (customer)
    private var locationPermissionButton: some View {
        Button {} label: {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("Allow Location Access")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(Theme.Colors.label)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Verify Business Button (restaurant)
    private var verifyBusinessButton: some View {
        Button {} label: {
            HStack(spacing: 10) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("Verify Business (Optional)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(Theme.Colors.label)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Sign Up Logic
    func signUp() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            showError = true
            return
        }
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
}

// MARK: - Auth Labeled Field  (label above + bordered input — Figma pattern)
struct AuthLabeledField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.Colors.secondaryLabel)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        text.isEmpty
                            ? Color.clear
                            : Theme.Colors.primaryGradientStart.opacity(0.4),
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - Legacy / Preserved Structs
// AccountTypeButton, SocialSignInButton, CheckboxToggleStyle kept for
// backward compatibility with any code that may reference them.

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
                isSelected
                    ? Theme.Colors.primaryGradient
                    : LinearGradient(
                        colors: [Theme.Colors.secondaryBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
            .cornerRadius(Theme.CornerRadius.xxl)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xxl)
                    .stroke(
                        isSelected ? Color.clear : Theme.Colors.primaryGradientStart.opacity(0.3),
                        lineWidth: 2
                    )
            )
        }
    }
}

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

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(
                systemName: configuration.isOn ? "checkmark.square.fill" : "square"
            )
            .foregroundColor(
                configuration.isOn
                    ? Theme.Colors.primaryGradientStart
                    : Theme.Colors.secondaryLabel
            )
            .onTapGesture {
                configuration.isOn.toggle()
                hapticFeedback(.light)
            }
            configuration.label
        }
    }
}
