//
//  PaymentMethodsView.swift
//  RePlate
//
//  Displays saved payment methods (brand + last4 only).
//  SECURITY: No raw card data is ever stored or displayed here.
//

import SwiftUI

struct PaymentMethodsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    // TODO: load from Supabase payment_methods table
    // For now shows mock saved methods or empty state
    private var savedMethods: [PaymentMethod] {
        appState.savedPaymentMethods
    }

    var body: some View {
        NavigationView {
            Group {
                if savedMethods.isEmpty {
                    emptyState
                } else {
                    methodsList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 44))
                .foregroundStyle(Theme.Colors.primaryGradient)
            Text("No Payment Methods")
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text("Your saved payment details will appear here after your first purchase.")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            // SECURITY: Stripe handles card entry; we only store brand + last4
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                Text("Secured by Stripe — card numbers never stored")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var methodsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(savedMethods) { method in
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                                .frame(width: 48, height: 48)
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(method.displayName)
                                .font(.system(size: 15, weight: .semibold))
                            if let exp = method.expiryDisplay {
                                Text("Expires \(exp)")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.Colors.secondaryLabel)
                            }
                        }
                        Spacer()
                        if method.isDefault {
                            Text("Default")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.Colors.primaryGradientStart.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                }
            }
            .padding(20)
        }
    }
}
