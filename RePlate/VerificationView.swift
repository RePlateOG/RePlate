//
//  VerificationView.swift
//  RePlate
//
//  Restaurant verification workflow: mandatory before posting food.
//  Covers business documentation, compliance agreements, and submission.
//

import SwiftUI

// MARK: - Verification Status (extend User model usage)
enum RestaurantVerificationStatus: String, Codable {
    case unverified   = "Not Started"
    case pending      = "Under Review"
    case verified     = "Verified"
    case rejected     = "Rejected"

    var icon: String {
        switch self {
        case .unverified: return "exclamationmark.shield"
        case .pending:    return "clock.badge.checkmark"
        case .verified:   return "checkmark.seal.fill"
        case .rejected:   return "xmark.seal.fill"
        }
    }
    var color: Color {
        switch self {
        case .unverified: return .orange
        case .pending:    return Color(hex: "5db996")
        case .verified:   return Color(hex: "118b50")
        case .rejected:   return .red
        }
    }
}

// MARK: - Verification Gate View
/// Shown when a restaurant tries to post without completing verification.
struct VerificationGateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showVerification = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.orange)
                }
                .padding(.top, 40)

                Text("Verification Required")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text("You must complete restaurant verification before creating listings or accepting orders.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 32)

            // What you unlock
            VStack(alignment: .leading, spacing: 12) {
                Text("AFTER VERIFICATION YOU CAN:")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
                    .tracking(1.0)
                    .padding(.horizontal, 24)

                ForEach([
                    ("paperplane.fill",       "Post surplus food listings"),
                    ("bag.fill",              "Accept and manage orders"),
                    ("checkmark.seal.fill",   "Display a verified badge"),
                    ("chart.bar.fill",        "Access analytics & insights"),
                ], id: \.0) { icon, text in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "118b50").opacity(0.12))
                                .frame(width: 36, height: 36)
                            Image(systemName: icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "118b50"))
                        }
                        Text(text)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "118b50").opacity(0.6))
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    hapticFeedback(.medium)
                    showVerification = true
                } label: {
                    Text("Start Verification")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color(hex: "118b50").opacity(0.35), radius: 12, y: 5)
                }

                Button { dismiss() } label: {
                    Text("Maybe Later")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .frame(maxWidth: .infinity).frame(height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(Theme.Colors.pageBackground)
        .sheet(isPresented: $showVerification) { RestaurantVerificationView() }
    }
}

// MARK: - Restaurant Verification View
struct RestaurantVerificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentSection = 0   // 0=docs, 1=info, 2=agreements
    @State private var showSubmitConfirm = false
    @State private var submitted = false

    // Section 0 — Document uploads
    @State private var uploadedLicense    = false
    @State private var uploadedFoodPermit = false
    @State private var uploadedHealth     = false
    @State private var uploadedTax        = false
    @State private var uploadedID         = false

    // Section 1 — Business info
    @State private var legalName  = ""
    @State private var bizAddress = ""
    @State private var bizPhone   = ""
    @State private var bizEmail   = ""

    // Section 2 — Agreements
    @State private var agreeTerms       = false
    @State private var agreeFoodSafety  = false
    @State private var agreeLiability   = false
    @State private var agreePlatform    = false
    @State private var agreePickup      = false
    @State private var agreeAccurate    = false

    private var allDocsUploaded: Bool {
        uploadedLicense && uploadedFoodPermit && uploadedHealth && uploadedTax && uploadedID
    }
    private var infoComplete: Bool {
        !legalName.isEmpty && !bizAddress.isEmpty && !bizPhone.isEmpty && !bizEmail.isEmpty
    }
    private var allAgreements: Bool {
        agreeTerms && agreeFoodSafety && agreeLiability && agreePlatform && agreePickup && agreeAccurate
    }
    private var canSubmit: Bool { allDocsUploaded && infoComplete && allAgreements }

    var body: some View {
        if submitted {
            submittedView
        } else {
            NavigationView {
                VStack(spacing: 0) {
                    sectionPicker
                    ScrollView(showsIndicators: false) {
                        Group {
                            switch currentSection {
                            case 0: documentSection
                            case 1: businessInfoSection
                            default: agreementsSection
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 60)
                    }
                }
                .background(Color(.systemBackground))
                .navigationTitle("Restaurant Verification")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if canSubmit {
                            Button {
                                hapticFeedback(.medium)
                                showSubmitConfirm = true
                            } label: {
                                Text("Submit")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "118b50"))
                            }
                        }
                    }
                }
                .alert("Submit Verification", isPresented: $showSubmitConfirm) {
                    Button("Submit", role: .none) {
                        hapticFeedback(.success)
                        withAnimation { submitted = true }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("By submitting, you confirm all information is accurate and legally binding. RePlate will review within 1–2 business days.")
                }
            }
        }
    }

    // MARK: Section picker
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(["Documents", "Business Info", "Agreements"], id: \.self) { section in
                let idx = ["Documents", "Business Info", "Agreements"].firstIndex(of: section) ?? 0
                Button {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { currentSection = idx }
                } label: {
                    Text(section)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(currentSection == idx ? Theme.Colors.primaryGradientStart : Theme.Colors.secondaryLabel)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(currentSection == idx ? Color(.systemBackground) : Color.clear)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).shadow(color: Color.black.opacity(0.04), radius: 4, y: 2))
    }

    // MARK: Section 0 — Document Uploads
    private var documentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "Business Documentation",
                subtitle: "Upload all required documents. Accepted formats: PDF, JPG, PNG."
            )

            uploadRow("Business License",           "doc.text.fill",   $uploadedLicense)
            uploadRow("Food Service Permit",        "cross.fill",      $uploadedFoodPermit)
            uploadRow("Health Inspection Report",   "heart.text.square.fill", $uploadedHealth)
            uploadRow("Tax Documentation (EIN)",    "building.columns.fill",  $uploadedTax)
            uploadRow("Government-Issued ID",       "person.text.rectangle.fill", $uploadedID)

            legalNote("All documents are encrypted and stored securely. They are only used for verification purposes and are not shared with customers.")
        }
    }

    private func uploadRow(_ label: String, _ icon: String, _ uploaded: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(uploaded.wrappedValue ? Color(hex: "118b50").opacity(0.12) : Color(.systemGray6))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(uploaded.wrappedValue ? Color(hex: "118b50") : Theme.Colors.secondaryLabel)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text(uploaded.wrappedValue ? "Uploaded" : "Required")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(uploaded.wrappedValue ? Color(hex: "118b50") : .orange)
            }
            Spacer()
            Button {
                hapticFeedback(.light)
                uploaded.wrappedValue = true
            } label: {
                Text(uploaded.wrappedValue ? "Replace" : "Upload")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(uploaded.wrappedValue ? Theme.Colors.secondaryLabel : .white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(uploaded.wrappedValue
                        ? AnyShapeStyle(Color(.systemGray5))
                        : AnyShapeStyle(Theme.Colors.primaryGradient))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
    }

    // MARK: Section 1 — Business Info
    private var businessInfoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "Restaurant Information",
                subtitle: "This information will appear on your public profile and in legal agreements."
            )

            verificationField("Legal Business Name", placeholder: "Exactly as registered", text: $legalName)
            verificationField("Business Address", placeholder: "123 Main St, City, State, ZIP", text: $bizAddress)
            verificationField("Business Phone", placeholder: "(555) 123-4567", text: $bizPhone, keyboard: .phonePad)
            verificationField("Business Email", placeholder: "info@yourrestaurant.com", text: $bizEmail, keyboard: .emailAddress)

            legalNote("Ensure your legal business name exactly matches your business registration documents.")
        }
    }

    private func verificationField(
        _ label: String, placeholder: String, text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(Theme.Colors.tertiaryLabel).tracking(1.0)
            TextField(placeholder, text: text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .keyboardType(keyboard)
                .padding(.horizontal, 18).padding(.vertical, 16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(!text.wrappedValue.isEmpty ? Color(hex: "118b50").opacity(0.4) : Color.clear, lineWidth: 1.5))
        }
    }

    // MARK: Section 2 — Agreements
    private var agreementsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(
                title: "Compliance Agreements",
                subtitle: "You must acknowledge all agreements to complete verification."
            )

            agreementRow(
                title: "Terms of Service",
                detail: "I have read and agree to the RePlate Terms of Service, including all policies governing restaurant participation.",
                binding: $agreeTerms
            )
            agreementRow(
                title: "Food Safety Requirements",
                detail: "I confirm that all food posted on RePlate meets applicable food safety standards and is handled, stored, and labeled in compliance with local health regulations.",
                binding: $agreeFoodSafety
            )
            agreementRow(
                title: "Liability Acknowledgement",
                detail: "I acknowledge that RePlate is not liable for disputes between my restaurant and customers. I accept full responsibility for the safety and quality of food I list.",
                binding: $agreeLiability
            )
            agreementRow(
                title: "Platform Policies",
                detail: "I agree to comply with RePlate's community standards, anti-fraud policies, and all posting guidelines.",
                binding: $agreePlatform
            )
            agreementRow(
                title: "Pickup Policies",
                detail: "I agree to honour all confirmed orders and maintain accurate pickup windows. I understand that failure to do so may result in account suspension.",
                binding: $agreePickup
            )
            agreementRow(
                title: "Accuracy Certification",
                detail: "I certify that all information provided during verification is true, accurate, and complete to the best of my knowledge.",
                binding: $agreeAccurate
            )

            if canSubmit {
                Button {
                    hapticFeedback(.medium)
                    showSubmitConfirm = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Submit for Review")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Theme.Colors.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color(hex: "118b50").opacity(0.35), radius: 12, y: 5)
                }
                .padding(.top, 8)
            }

            legalNote("Submitting false information may result in permanent account termination and legal action. All agreements are legally binding.")
        }
    }

    private func agreementRow(title: String, detail: String, binding: Binding<Bool>) -> some View {
        Button {
            hapticFeedback(.light)
            binding.wrappedValue.toggle()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(binding.wrappedValue ? Theme.Colors.primaryGradientStart : Color(.systemGray5))
                        .frame(width: 28, height: 28)
                    if binding.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text(detail)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(binding.wrappedValue ? Color(hex: "118b50").opacity(0.06) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18)
                .stroke(binding.wrappedValue ? Color(hex: "118b50").opacity(0.3) : Color(.systemGray5), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: Submitted View
    private var submittedView: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "118b50").opacity(0.4), radius: 20, y: 8)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(spacing: 12) {
                Text("Submitted for Review")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text("We'll review your verification within 1–2 business days and notify you by email.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            VStack(spacing: 10) {
                reviewStep("1", text: "Documents reviewed by our team")
                reviewStep("2", text: "Business information validated")
                reviewStep("3", text: "Verification approved & badge applied")
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .shadow(color: Color.black.opacity(0.07), radius: 14, y: 5)
            .padding(.horizontal, 24)
            Spacer()
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Theme.Colors.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color(hex: "118b50").opacity(0.35), radius: 12, y: 5)
            }
            .padding(.horizontal, 24).padding(.bottom, 48)
        }
        .background(Color(.systemBackground))
    }

    private func reviewStep(_ step: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .frame(width: 30, height: 30)
                Text(step)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.label)
            Spacer()
        }
    }

    // MARK: Helpers
    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.label)
            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
    }

    private func legalNote(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.secondaryLabel)
            Text(text)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .lineSpacing(2)
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
