//
//  SignUpView.swift
//  RePlate
//
//  Sign up screen
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    VStack(spacing: Spacing.md) {
                        Text("Create Account")
                            .font(.displaySmall)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text("Join RePlate and start saving")
                            .font(.bodyLarge)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.top, Spacing.lg)
                    
                    // Form fields
                    VStack(spacing: Spacing.md) {
                        RPTextField(
                            "Full Name",
                            placeholder: "Enter your name",
                            text: $viewModel.name,
                            icon: "person.fill"
                        )
                        
                        RPTextField(
                            "Email",
                            placeholder: "Enter your email",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        
                        RPTextField(
                            "Phone (Optional)",
                            placeholder: "Enter your phone number",
                            text: $viewModel.phone,
                            icon: "phone.fill",
                            keyboardType: .phonePad
                        )
                        
                        RPTextField(
                            "Password",
                            placeholder: "Create a password",
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        
                        RPTextField(
                            "Confirm Password",
                            placeholder: "Re-enter your password",
                            text: $viewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal)
                    
                    // Terms
                    Text("By signing up, you agree to our [Terms of Service](https://replate.app/terms) and [Privacy Policy](https://replate.app/privacy)")
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                    
                    // Sign up button
                    RPButton(
                        "Create Account",
                        icon: "checkmark.circle.fill",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            await viewModel.signUpWithEmail()
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sign in link
                    HStack(spacing: Spacing.xxs) {
                        Text("Already have an account?")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                        
                        Button("Sign In") {
                            HapticManager.shared.light()
                            dismiss()
                        }
                        .font(.bodyMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryGradientStart)
                    }
                    .padding(.bottom, Spacing.xl)
                }
            }
            .background(Color.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.shared.light()
                        dismiss()
                    }
                    .foregroundColor(.primaryGradientStart)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error ?? "An unknown error occurred")
            }
        }
    }
}

// MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewModel: AuthenticationViewModel())
    }
}
