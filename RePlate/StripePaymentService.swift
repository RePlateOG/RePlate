//
//  StripePaymentService.swift
//  RePlate
//
//  To activate real Stripe payments:
//  1. Add https://github.com/stripe/stripe-ios (product: StripePaymentSheet) in Xcode.
//  2. Uncomment the `import StripePaymentSheet` line below.
//  3. In RePlateApp.swift, uncomment STPAPIClient.shared.publishableKey = StripeConfig.publishableKey
//  4. Deploy the Edge Functions (see STRIPE_SETUP.md).
//

import SwiftUI
import Foundation
import Combine

// Uncomment after adding the Stripe Swift package in Xcode:
// import StripePaymentSheet

// MARK: - Payment Result
enum PaymentResult {
    case completed(paymentIntentId: String)
    case canceled
    case failed(Error)
}

// MARK: - Payment Service
@MainActor
class StripePaymentService: ObservableObject {
    static let shared = StripePaymentService()

    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Create Order + Launch PaymentSheet
    // Call this when a customer taps "Pay $X".
    // orderId must already exist in Supabase with status = pending.
    func startPayment(
        orderId: String,
        supabaseToken: String,
        from viewController: UIViewController,
        completion: @escaping (PaymentResult) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (clientSecret, amountCents) = try await fetchPaymentIntent(
                    orderId: orderId,
                    supabaseToken: supabaseToken
                )

                await MainActor.run {
                    self.isLoading = false
                    // TODO: present PaymentSheet — uncomment after adding Stripe SDK:
                    // self.presentPaymentSheet(clientSecret: clientSecret, from: viewController, completion: completion)

                    // Stub: simulate success for UI testing until SDK is added
                    print("[Stripe stub] Would present PaymentSheet for \(amountCents) cents, secret: \(clientSecret.prefix(20))...")
                    completion(.completed(paymentIntentId: "pi_stub_\(orderId.prefix(8))"))
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(.failed(error))
                }
            }
        }
    }

    // MARK: - Fetch PaymentIntent from Edge Function
    private func fetchPaymentIntent(orderId: String, supabaseToken: String) async throws -> (clientSecret: String, amountCents: Int) {
        // OWASP A03: validate orderId format before touching the network
        guard Validators.isUUID(orderId) else {
            throw PaymentError.serverError("Invalid order identifier.")
        }

        guard let url = URL(string: StripeConfig.createPaymentIntentURL) else {
            throw PaymentError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(supabaseToken)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
        // OWASP A05: 30-second timeout prevents indefinite hangs on slow/malicious endpoints
        request.timeoutInterval = 30
        request.httpBody = try JSONSerialization.data(withJSONObject: ["orderId": orderId])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PaymentError.networkError
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        // Free listing — no payment sheet needed
        if json["free"] as? Bool == true {
            throw PaymentError.listingIsFree
        }

        // Surface rate-limit errors so the UI can show a helpful message
        if httpResponse.statusCode == 429 {
            throw PaymentError.serverError("Too many requests. Please try again in a moment.")
        }

        guard httpResponse.statusCode == 200,
              let clientSecret = json["clientSecret"] as? String,
              let amountCents  = json["amountCents"]  as? Int else {
            let msg = json["error"] as? String ?? "Unknown error"
            throw PaymentError.serverError(msg)
        }

        return (clientSecret, amountCents)
    }

    // MARK: - Present PaymentSheet (uncomment after adding Stripe SDK)
    /*
    private func presentPaymentSheet(
        clientSecret: String,
        from viewController: UIViewController,
        completion: @escaping (PaymentResult) -> Void
    ) {
        STPAPIClient.shared.publishableKey = StripeConfig.publishableKey

        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = "RePlate"
        config.allowsDelayedPaymentMethods = false

        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
        paymentSheet.present(from: viewController) { result in
            switch result {
            case .completed:
                // Extract PaymentIntent id from client secret (format: pi_xxx_secret_yyy)
                let piId = clientSecret.components(separatedBy: "_secret_").first ?? clientSecret
                completion(.completed(paymentIntentId: piId))
            case .canceled:
                completion(.canceled)
            case .failed(let error):
                completion(.failed(error))
            }
        }
    }
    */

    // MARK: - Save Payment Method (display-only, no raw card data)
    // Call after a successful payment to save brand + last4 for display in Profile.
    // SECURITY: never pass or store raw card numbers — Stripe handles card tokenization.
    func savePaymentMethod(
        userId: String,
        brand: String,
        last4: String,
        expMonth: Int,
        expYear: Int,
        supabaseToken: String
    ) async {
        // TODO: POST to Supabase payment_methods table via supabase-swift client
        // Example (uncomment after adding supabase-swift package):
        // try? await supabase
        //     .from("payment_methods")
        //     .upsert([
        //         "user_id": userId,
        //         "type": "card",
        //         "brand": brand,
        //         "last4": last4,
        //         "exp_month": expMonth,
        //         "exp_year": expYear,
        //         "is_default": true
        //     ])
        //     .execute()
        print("[Stripe] Would save payment method: \(brand) \u{2022}\u{2022}\u{2022}\u{2022}\(last4) to Supabase")
    }
}

// MARK: - Payment Errors
enum PaymentError: LocalizedError {
    case invalidURL
    case networkError
    case serverError(String)
    case listingIsFree

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Payment service URL is invalid."
        case .networkError: return "Network error. Please try again."
        case .serverError(let msg): return "Payment error: \(msg)"
        case .listingIsFree: return "This listing is free — no payment required."
        }
    }
}
