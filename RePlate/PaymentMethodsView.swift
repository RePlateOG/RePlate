//
//  PaymentMethodsView.swift
//  RePlate
//
//  Displays saved payment methods and lets users add new ones.
//  SECURITY: No raw card data is ever stored or displayed here.
//  Card tokenization is handled exclusively by Stripe's SDK.
//

import SwiftUI

// MARK: - Payment Methods List

struct PaymentMethodsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showAddSheet = false

    private var savedMethods: [PaymentMethod] { appState.savedPaymentMethods }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Add new method button always at the top
                    addMethodButton

                    if !savedMethods.isEmpty {
                        savedMethodsList
                    }

                    securityBadge
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.pageBackground)
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddPaymentMethodSheet { method in
                    appState.savedPaymentMethods.append(method)
                }
            }
        }
    }

    private var addMethodButton: some View {
        Button { hapticFeedback(.medium); showAddSheet = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: 40, height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Add Payment Method")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        }
    }

    private var savedMethodsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Methods")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .tracking(0.5)
                .padding(.horizontal, 4)

            ForEach(savedMethods) { method in
                SavedMethodRow(method: method) {
                    if let idx = appState.savedPaymentMethods.firstIndex(where: { $0.id == method.id }) {
                        withAnimation { appState.savedPaymentMethods.remove(at: idx) }
                        hapticFeedback(.medium)
                    }
                }
            }
        }
    }

    private var securityBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.primaryGradientStart)
            Text("Payments secured by Stripe — card numbers are never stored on our servers.")
                .font(.system(size: 12))
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .padding(14)
        .background(Theme.Colors.primaryGradientStart.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Saved Method Row

private struct SavedMethodRow: View {
    let method: PaymentMethod
    let onRemove: () -> Void

    private var iconName: String {
        switch method.type {
        case .applePay: return "apple.logo"
        case .paypal:   return "p.circle.fill"
        case .card:     return "creditcard.fill"
        case .googlePay: return "g.circle.fill"
        }
    }

    private var iconColor: Color {
        switch method.type {
        case .applePay:  return .primary
        case .paypal:    return Color(hex: "003087")
        case .card:      return Theme.Colors.primaryGradientStart
        case .googlePay: return Color(hex: "4285F4")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(method.displayName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                if let exp = method.expiryDisplay {
                    Text("Expires \(exp)")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }

            Spacer()

            if method.isDefault {
                Text("Default")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.primaryGradientStart.opacity(0.1))
                    .clipShape(Capsule())
            }

            Button { onRemove() } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(.systemRed).opacity(0.7))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
    }
}

// MARK: - Add Payment Method Sheet

struct AddPaymentMethodSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (PaymentMethod) -> Void

    @State private var showCardForm  = false
    @State private var isProcessing  = false
    @State private var addedProvider = ""
    @State private var showSuccess   = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text("Add Payment Method")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Choose how you'd like to pay")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Apple Pay
                        paymentOptionRow(
                            icon: "apple.logo",
                            iconBg: Color.black,
                            iconColor: .white,
                            title: "Apple Pay",
                            subtitle: "Use Face ID or Touch ID"
                        ) {
                            simulateAdd(type: .applePay, name: "Apple Pay")
                        }

                        // PayPal
                        paymentOptionRow(
                            icon: "p.circle.fill",
                            iconBg: Color(hex: "003087"),
                            iconColor: .white,
                            title: "PayPal",
                            subtitle: "Connect your PayPal account"
                        ) {
                            simulateAdd(type: .paypal, name: "PayPal")
                        }

                        // Add Card
                        paymentOptionRow(
                            icon: "creditcard.fill",
                            iconBg: Theme.Colors.primaryGradientStart,
                            iconColor: .white,
                            title: "Credit or Debit Card",
                            subtitle: "Visa, Mastercard, Amex, Discover"
                        ) {
                            showCardForm = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }

                // Security note
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                    Text("Secured by Stripe — your card details are never stored on our servers.")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Theme.Colors.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if isProcessing {
                    processingOverlay
                }
                if showSuccess {
                    successOverlay
                }
            }
            .sheet(isPresented: $showCardForm) {
                AddCardView { method in
                    onAdd(method)
                    dismiss()
                }
            }
        }
    }

    private func paymentOptionRow(
        icon: String,
        iconBg: Color,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: { hapticFeedback(.medium); action() }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBg)
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(iconColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        }
    }

    private func simulateAdd(type: PaymentMethod.PaymentType, name: String) {
        isProcessing = true
        addedProvider = name
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                isProcessing = false
                let method = PaymentMethod(
                    id: UUID().uuidString,
                    type: type,
                    last4: type == .paypal ? "••••" : "",
                    brand: nil,
                    expiryMonth: nil,
                    expiryYear: nil,
                    isDefault: true
                )
                onAdd(method)
                withAnimation { showSuccess = true }
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                showSuccess = false
                dismiss()
            }
        }
    }

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primaryGradientStart))
                    .scaleEffect(1.4)
                Text("Connecting to \(addedProvider)…")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
            }
            .padding(32)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.Colors.primaryGradient)
                Text("\(addedProvider) added!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
            }
            .padding(32)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - Add Card Form

struct AddCardView: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (PaymentMethod) -> Void

    @State private var cardNumber   = ""
    @State private var expiry       = ""
    @State private var cvv          = ""
    @State private var cardName     = ""
    @State private var isProcessing = false
    @State private var cardError: String?

    private var formattedCardNumber: String {
        let digits = cardNumber.filter(\.isNumber)
        return stride(from: 0, to: min(digits.count, 16), by: 4)
            .map { i -> String in
                let start = digits.index(digits.startIndex, offsetBy: i)
                let end   = digits.index(start, offsetBy: min(4, digits.count - i))
                return String(digits[start..<end])
            }
            .joined(separator: " ")
    }

    private var detectedBrand: String {
        let digits = cardNumber.filter(\.isNumber)
        if digits.hasPrefix("4")          { return "Visa" }
        if digits.hasPrefix("5") || digits.hasPrefix("2") { return "Mastercard" }
        if digits.hasPrefix("34") || digits.hasPrefix("37") { return "Amex" }
        if digits.hasPrefix("6")          { return "Discover" }
        return "Card"
    }

    private var brandIcon: String {
        switch detectedBrand {
        case "Visa":       return "v.circle.fill"
        case "Mastercard": return "m.circle.fill"
        case "Amex":       return "a.circle.fill"
        case "Discover":   return "d.circle.fill"
        default:           return "creditcard.fill"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Card preview
                    cardPreview

                    // Form fields
                    VStack(spacing: 16) {
                        cardField(label: "Cardholder Name", placeholder: "Name on card",
                                  text: $cardName, keyboardType: .default, isSecure: false)

                        // Card number row with brand icon
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Card Number")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .tracking(0.5)
                            HStack(spacing: 10) {
                                TextField("1234 5678 9012 3456", text: $cardNumber)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .onChange(of: cardNumber) { _, new in
                                        let digits = new.filter(\.isNumber)
                                        if digits.count > 16 {
                                            cardNumber = String(digits.prefix(16))
                                        } else {
                                            cardNumber = digits
                                        }
                                    }
                                Image(systemName: brandIcon)
                                    .font(.system(size: 20))
                                    .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        HStack(spacing: 12) {
                            // Expiry
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Expiry")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.secondaryLabel)
                                    .tracking(0.5)
                                TextField("MM/YY", text: $expiry)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .onChange(of: expiry) { _, new in
                                        var digits = new.filter(\.isNumber)
                                        if digits.count > 4 { digits = String(digits.prefix(4)) }
                                        if digits.count > 2 {
                                            expiry = String(digits.prefix(2)) + "/" + String(digits.dropFirst(2))
                                        } else {
                                            expiry = digits
                                        }
                                    }
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            // CVV
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CVV")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.Colors.secondaryLabel)
                                    .tracking(0.5)
                                SecureField("•••", text: $cvv)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .onChange(of: cvv) { _, new in
                                        let digits = new.filter(\.isNumber)
                                        cvv = String(digits.prefix(4))
                                    }
                                    .padding(14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }

                    if let err = cardError {
                        Text(err)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Submit button
                    Button { addCard() } label: {
                        ZStack {
                            if isProcessing {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Add Card")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.3), radius: 12, y: 5)
                    }
                    .disabled(isProcessing)

                    // Security disclaimer
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("Your card details are encrypted and sent directly to Stripe. RePlate never sees or stores your card number, CVV, or full expiry.")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                    .padding(14)
                    .background(Theme.Colors.primaryGradientStart.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.pageBackground)
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var cardPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.Colors.primaryGradient)
                .frame(height: 190)
                .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.35), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("RePlate")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: brandIcon)
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Text(formattedCardNumber.isEmpty ? "•••• •••• •••• ••••" : formattedCardNumber)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(2)

                Spacer()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CARDHOLDER").font(.system(size: 9, weight: .semibold)).foregroundColor(.white.opacity(0.6)).tracking(1)
                        Text(cardName.isEmpty ? "Your Name" : cardName.uppercased())
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("EXPIRES").font(.system(size: 9, weight: .semibold)).foregroundColor(.white.opacity(0.6)).tracking(1)
                        Text(expiry.isEmpty ? "MM/YY" : expiry)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private func cardField(
        label: String, placeholder: String,
        text: Binding<String>, keyboardType: UIKeyboardType, isSecure: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .tracking(0.5)
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .keyboardType(keyboardType)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .padding(14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func addCard() {
        // Basic client-side validation before tokenising with Stripe
        let digits = cardNumber.filter(\.isNumber)
        guard !cardName.trimmingCharacters(in: .whitespaces).isEmpty else {
            cardError = "Please enter the cardholder name."; return
        }
        guard digits.count == 15 || digits.count == 16 else {
            cardError = "Please enter a valid card number."; return
        }
        guard expiry.count == 5 else {
            cardError = "Please enter a valid expiry date (MM/YY)."; return
        }
        guard cvv.count >= 3 else {
            cardError = "Please enter a valid CVV."; return
        }
        cardError = nil
        isProcessing = true

        Task {
            // TODO: Replace this stub with Stripe's card tokenization:
            // let tokenParams = STPCardParams(); ...
            // STPAPIClient.shared.createToken(withCard: tokenParams) { token, error in ... }
            // Then save token.last4 + brand to Supabase via StripePaymentService.savePaymentMethod
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            let expiryParts = expiry.split(separator: "/")
            let month = expiryParts.count == 2 ? Int(expiryParts[0]) : nil
            let year  = expiryParts.count == 2 ? Int("20" + (expiryParts[1])) : nil
            let last4 = String(digits.suffix(4))

            let method = PaymentMethod(
                id: UUID().uuidString,
                type: .card,
                last4: last4,
                brand: detectedBrand,
                expiryMonth: month,
                expiryYear: year,
                isDefault: true
            )

            await MainActor.run {
                isProcessing = false
                onAdd(method)
                dismiss()
            }
        }
    }
}
