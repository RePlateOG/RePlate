//
//  AuthenticationViewModel.swift
//  RePlate
//
//  Handles authentication logic
//

import SwiftUI
import AuthenticationServices

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userType: UserType?
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var phone = ""
    
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    
    // MARK: - Sign In with Apple
    func signInWithApple(authorization: ASAuthorization) async {
        isLoading = true
        error = nil
        
        do {
            // TODO: Integrate with Firebase/Supabase
            // For now, simulate success
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Create mock user
            let user = User(
                id: UUID().uuidString,
                email: "user@apple.com",
                name: name.isEmpty ? "Apple User" : name,
                userType: userType ?? .customer,
                createdAt: Date(),
                isVerified: true,
                mealsSaved: 0,
                co2Reduced: 0,
                foodRescued: 0
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            HapticManager.shared.success()
        } catch {
            self.error = error.localizedDescription
            showError = true
            isLoading = false
            HapticManager.shared.error()
        }
    }
    
    // MARK: - Email Sign In
    func signInWithEmail() async {
        guard validateSignIn() else { return }
        
        isLoading = true
        error = nil
        
        do {
            // TODO: Integrate with Firebase/Supabase
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: "User",
                userType: userType ?? .customer,
                createdAt: Date(),
                isVerified: true,
                mealsSaved: 0,
                co2Reduced: 0,
                foodRescued: 0
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            HapticManager.shared.success()
        } catch {
            self.error = error.localizedDescription
            showError = true
            isLoading = false
            HapticManager.shared.error()
        }
    }
    
    // MARK: - Email Sign Up
    func signUpWithEmail() async {
        guard validateSignUp() else { return }
        
        isLoading = true
        error = nil
        
        do {
            // TODO: Integrate with Firebase/Supabase
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            let user = User(
                id: UUID().uuidString,
                email: email,
                name: name,
                phone: phone.isEmpty ? nil : phone,
                userType: userType ?? .customer,
                createdAt: Date(),
                isVerified: false,
                mealsSaved: 0,
                co2Reduced: 0,
                foodRescued: 0
            )
            
            currentUser = user
            isAuthenticated = true
            isLoading = false
            
            HapticManager.shared.success()
        } catch {
            self.error = error.localizedDescription
            showError = true
            isLoading = false
            HapticManager.shared.error()
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        userType = nil
        clearFields()
    }
    
    // MARK: - Validation
    private func validateSignIn() -> Bool {
        if email.isEmpty || password.isEmpty {
            error = "Please fill in all fields"
            showError = true
            return false
        }
        
        if !email.contains("@") {
            error = "Please enter a valid email"
            showError = true
            return false
        }
        
        return true
    }
    
    private func validateSignUp() -> Bool {
        if email.isEmpty || password.isEmpty || name.isEmpty {
            error = "Please fill in all required fields"
            showError = true
            return false
        }
        
        if !email.contains("@") {
            error = "Please enter a valid email"
            showError = true
            return false
        }
        
        if password.count < 6 {
            error = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            error = "Passwords do not match"
            showError = true
            return false
        }
        
        return true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        phone = ""
        error = nil
    }
}
