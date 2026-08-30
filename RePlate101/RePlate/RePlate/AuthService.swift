//
//  AuthService.swift
//  RePlate
//

import SwiftUI
import Combine
import Supabase
import AuthenticationServices

@MainActor
class RePlateAuthService: NSObject, ObservableObject {
    static let shared = RePlateAuthService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Apple Sign In state — all accessed on MainActor only.
    private var appleContinuation: CheckedContinuation<AppleSignInResult, Error>?
    private var appleNonce: String?
    // Strong reference keeps ASAuthorizationController alive until delegate fires.
    private var appleAuthController: ASAuthorizationController?

    // The current Supabase JWT — used to authenticate Edge Function calls.
    var accessToken: String? {
        supabase.auth.currentSession?.accessToken
    }

    private override init() {
        super.init()
        Task { await restoreSession() }
    }

    // MARK: - Restore session on launch

    private func restoreSession() async {
        do {
            // supabase.auth.session auto-refreshes the access token before returning.
            // It throws if no session exists or if the refresh token has expired —
            // no manual isExpired guard needed here.
            let session = try await supabase.auth.session
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        } catch {
            // No saved session or refresh failed — user must sign in again.
        }
    }

    // MARK: - Email / Password Sign In

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
            return true
        } catch {
            errorMessage = authErrorMessage(error)
            return false
        }
    }

    // MARK: - Email / Password Sign Up

    func signUp(name: String, email: String, password: String, accountType: User.AccountType) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "name": .string(name),
                    "account_type": .string(accountType.rawValue)
                ]
            )
            let userId = response.user.id.uuidString

            if response.session != nil {
                // Session exists (email confirmation disabled) — load profile from DB.
                try? await Task.sleep(nanoseconds: 500_000_000)
                await loadProfile(userId: userId)
            } else {
                // Email confirmation required — no session yet. Build user from signup
                // metadata so routing (customer vs restaurant) works immediately.
                currentUser = User(
                    id: userId,
                    email: email,
                    name: name,
                    phoneNumber: nil,
                    profileImageURL: nil,
                    accountType: accountType,
                    createdAt: Date(),
                    verifiedRestaurant: false,
                    stripeAccountId: nil,
                    mealsSaved: 0,
                    co2Reduced: 0,
                    foodRescued: 0
                )
            }
            isAuthenticated = true
            return true
        } catch {
            errorMessage = authErrorMessage(error)
            return false
        }
    }

    // MARK: - Sign In with Apple

    func signInWithApple() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await performAppleSignIn()
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: result.idToken,
                    nonce: result.nonce
                )
            )
            // Create profile if first sign-in (trigger handles it, but race-condition guard)
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
            return true
        } catch {
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue { return false }
            errorMessage = authErrorMessage(error)
            return false
        }
    }

    // MARK: - Sign In with Google (Supabase OAuth via ASWebAuthenticationSession)

    func signInWithGoogle() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let redirectURL = URL(string: "com.JyotikaMithil.RePlate://auth-callback")!
            let session = try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: redirectURL
            )
            await loadProfile(userId: session.user.id.uuidString)
            isAuthenticated = true
            return true
        } catch {
            if (error as NSError).domain == ASWebAuthenticationSessionErrorDomain,
               (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                return false
            }
            errorMessage = authErrorMessage(error)
            return false
        }
    }

    // MARK: - Sign In with Yahoo (not supported — Yahoo is not an OAuth provider in Supabase)

    func signInWithYahoo() async -> Bool {
        errorMessage = "Yahoo sign-in is not supported. Please use Google, Apple, or email."
        return false
    }

    // MARK: - Sign Out

    func signOut() {
        Task {
            try? await supabase.auth.signOut()
        }
        currentUser = nil
        isAuthenticated = false
        hapticFeedback(.success)
    }

    // MARK: - Delete Account

    func deleteAccount() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        guard let userId = currentUser?.id else { return false }

        do {
            // Delete profile row first (cascade will remove related data per RLS policy)
            try await supabase.from("profiles").delete().eq("id", value: userId).execute()
            // The auth user deletion must be done server-side (Edge Function or Supabase dashboard)
            // For now sign out; full deletion can be wired to a delete-account Edge Function.
            signOut()
            return true
        } catch {
            errorMessage = "Account deletion failed. Please contact support."
            return false
        }
    }

    // MARK: - Profile Update

    func updateCurrentUser(name: String, email: String, phoneNumber: String?) {
        guard var user = currentUser else { return }
        user.name = name
        user.email = email
        user.phoneNumber = phoneNumber
        currentUser = user

        Task {
            guard let userId = currentUser?.id else { return }
            var fields: [String: String] = ["name": name]
            if let phone = phoneNumber { fields["phone_number"] = phone }
            _ = try? await supabase.from("profiles")
                .update(fields)
                .eq("id", value: userId)
                .execute()
        }
    }

    // MARK: - Load profile from database

    func loadProfile(userId: String) async {
        do {
            let profile: ProfileRow = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            currentUser = User(
                id: userId,
                email: supabase.auth.currentSession?.user.email ?? "",
                name: profile.name,
                phoneNumber: profile.phoneNumber,
                profileImageURL: profile.profileImageURL,
                accountType: User.AccountType(rawValue: profile.accountType) ?? .customer,
                createdAt: profile.createdAt,
                verifiedRestaurant: profile.verifiedRestaurant,
                stripeAccountId: profile.stripeAccountId,
                mealsSaved: profile.mealsSaved,
                co2Reduced: profile.coReduced,
                foodRescued: profile.foodRescued
            )
        } catch {
            // Profile doesn't exist yet (new user before trigger fires) — build minimal user
            if let authUser = supabase.auth.currentSession?.user {
                currentUser = User(
                    id: authUser.id.uuidString,
                    email: authUser.email ?? "",
                    name: authUser.userMetadata["name"]?.stringValue
                        ?? authUser.email?.components(separatedBy: "@").first
                        ?? "User",
                    phoneNumber: nil,
                    profileImageURL: nil,
                    accountType: User.AccountType(
                        rawValue: authUser.userMetadata["account_type"]?.stringValue ?? ""
                    ) ?? .customer,
                    createdAt: Date(),
                    verifiedRestaurant: false,
                    stripeAccountId: nil,
                    mealsSaved: 0,
                    co2Reduced: 0,
                    foodRescued: 0
                )
            }
        }
    }

    // MARK: - Helpers

    private func authErrorMessage(_ error: Error) -> String {
        #if DEBUG
        // Always show raw error in debug so we can diagnose Supabase responses.
        return "Auth error: \(error.localizedDescription)"
        #else
        let msg = error.localizedDescription.lowercased()
        if msg.contains("email not confirmed") || msg.contains("not confirmed") {
            return "Please confirm your email address before signing in. Check your inbox for a confirmation link."
        }
        if msg.contains("invalid login") || msg.contains("wrong password") {
            return "Invalid email or password."
        }
        if msg.contains("already") || msg.contains("registered") {
            return "An account with this email already exists."
        }
        if msg.contains("network") || msg.contains("connection") || msg.contains("offline") {
            return "No internet connection. Please try again."
        }
        if msg.contains("user not found") || msg.contains("no user") {
            return "No account found with that email. Please sign up first."
        }
        return "Something went wrong. Please try again."
        #endif
    }
}

// MARK: - Profile row (Decodable from Supabase)

private struct ProfileRow: Decodable {
    let name: String
    let accountType: String
    let stripeAccountId: String?
    let phoneNumber: String?
    let profileImageURL: String?
    let verifiedRestaurant: Bool
    let mealsSaved: Int
    let coReduced: Double
    let foodRescued: Double
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case name
        case accountType = "account_type"
        case stripeAccountId = "stripe_account_id"
        case phoneNumber = "phone_number"
        case profileImageURL = "profile_image_url"
        case verifiedRestaurant = "verified_restaurant"
        case mealsSaved = "meals_saved"
        case coReduced = "co2_reduced"
        case foodRescued = "food_rescued"
        case createdAt = "created_at"
    }
}

// MARK: - Sign in with Apple helpers

private struct AppleSignInResult {
    let idToken: String
    let nonce: String
}

extension RePlateAuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private func performAppleSignIn() async throws -> AppleSignInResult {
        let nonce = randomNonceString()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        // Retain the controller on self so it is not released after
        // performRequests() returns but before the delegate fires.
        appleAuthController = controller

        return try await withCheckedThrowingContinuation { continuation in
            self.appleContinuation = continuation
            self.appleNonce = nonce
            DispatchQueue.main.async {
                controller.performRequests()
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = appleNonce,
            let continuation = appleContinuation
        else { return }

        appleContinuation = nil
        appleNonce = nil
        appleAuthController = nil
        continuation.resume(returning: AppleSignInResult(idToken: idToken, nonce: nonce))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        guard let continuation = appleContinuation else { return }
        appleContinuation = nil
        appleNonce = nil
        appleAuthController = nil
        continuation.resume(throwing: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // .keyWindow is the correct API on iOS 15+; the old .windows approach is deprecated.
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow ?? UIWindow()
    }
}
