//
//  AuthService.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/27/26.
//

import SwiftUI
import Combine

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        // Check for saved user
        loadSavedUser()
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock authentication
        if email.contains("@") && password.count >= 6 {
            let accountType: User.AccountType = email.contains("restaurant") ? .restaurant : .customer
            currentUser = User(
                id: UUID().uuidString,
                email: email,
                name: email.components(separatedBy: "@").first?.capitalized ?? "User",
                phoneNumber: nil,
                profileImageURL: nil,
                accountType: accountType,
                createdAt: Date(),
                verifiedRestaurant: accountType == .restaurant,
                mealsSaved: 0,
                co2Reduced: 0,
                foodRescued: 0
            )
            isAuthenticated = true
            saveUser()
            return true
        } else {
            errorMessage = "Invalid email or password"
            return false
        }
    }
    
    // MARK: - Sign Up
    func signUp(name: String, email: String, password: String, accountType: User.AccountType) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock registration
        if email.contains("@") && password.count >= 6 && !name.isEmpty {
            currentUser = User(
                id: UUID().uuidString,
                email: email,
                name: name,
                phoneNumber: nil,
                profileImageURL: nil,
                accountType: accountType,
                createdAt: Date(),
                verifiedRestaurant: accountType == .restaurant,
                mealsSaved: 0,
                co2Reduced: 0,
                foodRescued: 0
            )
            isAuthenticated = true
            saveUser()
            return true
        } else {
            errorMessage = "Please provide valid information"
            return false
        }
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Simulate Sign in with Apple
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        currentUser = User(
            id: UUID().uuidString,
            email: "apple.user@privaterelay.appleid.com",
            name: "Apple User",
            phoneNumber: nil,
            profileImageURL: nil,
            accountType: .customer,
            createdAt: Date(),
            verifiedRestaurant: false,
            mealsSaved: 0,
            co2Reduced: 0,
            foodRescued: 0
        )
        isAuthenticated = true
        saveUser()
        return true
    }
    
    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        clearSavedUser()
        hapticFeedback(.success)
    }
    
    // MARK: - Delete Account
    func deleteAccount() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        signOut()
        return true
    }
    
    // MARK: - Persistence
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func loadSavedUser() {
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func clearSavedUser() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}
