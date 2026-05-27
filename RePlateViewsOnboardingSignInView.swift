//
//  SignInView.swift
//  RePlate
//
//  Sign in screen with multiple auth options
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    @State private var showSignUp = false
    @Environment(\.colorScheme) var colorScheme
    
    init(viewModel: AuthenticationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                VStack(spacing: Spacing.md) {
                    Text("Welcome Back")
                        .font(.displayMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Sign in to continue")
                        .font(.bodyLarge)
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, Spacing.xxxxl)
                
                // Sign in with Apple
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email, .fullName]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            Task {
                                await viewModel.signInWithApple(authorization: authorization)
                            }
                        case .failure(let error):
                            viewModel.error = error.localizedDescription
                            viewModel.showError = true
                        }
                    }
                )
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 56)
                .cornerRadius(CornerRadius.xxl)
                .padding(.horizontal)
                
                // Divider
                HStack(spacing: Spacing.md) {
                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                    
                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 1)
                }
                .padding(.horizontal, Spacing.xl)
                
                // Email/Password fields
                VStack(spacing: Spacing.md) {
                    RPTextField(
                        "Email",
                        placeholder: "Enter your email",
                        text: $viewModel.email,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    
                    RPTextField(
                        "Password",
                        placeholder: "Enter your password",
                        text: $viewModel.password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                }
                .padding(.horizontal)
                
                // Forgot password
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        // TODO: Implement forgot password
                        HapticManager.shared.light()
                    }
                    .font(.labelLarge)
                    .foregroundColor(.primaryGradientStart)
                }
                .padding(.horizontal, Spacing.xl)
                
                // Sign in button
                RPButton(
                    "Sign In",
                    icon: "arrow.right",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.signInWithEmail()
                    }
                }
                .padding(.horizontal)
                
                // Sign up link
                HStack(spacing: Spacing.xxs) {
                    Text("Don't have an account?")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                    
                    Button("Sign Up") {
                        HapticManager.shared.light()
                        showSignUp = true
                    }
                    .font(.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGradientStart)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
        .background(Color.background.ignoresSafeArea())
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(viewModel: AuthenticationViewModel())
    }
}
