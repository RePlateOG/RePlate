//
//  PostSurplusView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/30/26.
//  Playful 5-step surplus-food posting flow.
//

import SwiftUI

// MARK: - Post Surplus View
struct PostSurplusView: View {
    @Environment(\.dismiss) var dismiss

    // MARK: Step state
    @State private var step         = 1   // 1 … 5
    @State private var title        = ""
    @State private var foodType     = ""
    @State private var quantity     = 1
    @State private var price        = ""
    @State private var isFree       = false
    @State private var pickupWindow = ""
    @State private var isPosting    = false

    // MARK: Static data
    private struct FoodType: Identifiable {
        let id = UUID()
        let name: String
        let emoji: String
    }

    private let foodTypes: [FoodType] = [
        .init(name: "Meals",   emoji: "🍱"),
        .init(name: "Bakery",  emoji: "🥐"),
        .init(name: "Veggie",  emoji: "🥗"),
        .init(name: "Drinks",  emoji: "🧃"),
        .init(name: "Mixed",   emoji: "🥡"),
        .init(name: "Produce", emoji: "🍎"),
    ]
    private let pickupOptions = [
        "Until Close",
        "6:00 PM – 9:00 PM",
        "7:00 PM – 10:00 PM",
        "Custom",
    ]

    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            stepHeader

            ScrollView(showsIndicators: false) {
                currentStep
                    .id(step)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 56)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        )
                    )
            }
        }
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: step)
    }

    // MARK: - Header
    private var stepHeader: some View {
        HStack(alignment: .center) {
            Button {
                hapticFeedback(.light)
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                        .frame(width: 44, height: 44)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Text("New Surplus")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)

                HStack(spacing: 6) {
                    ForEach(1 ... 4, id: \.self) { s in
                        Capsule()
                            .fill(s <= min(step, 4)
                                  ? Theme.Colors.primaryGradientStart
                                  : Color(.systemGray5))
                            .frame(width: 28, height: 5)
                    }
                }
            }

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(Color(.systemBackground)
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 4))
    }

    // MARK: - Step dispatcher
    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 1: step1Photos
        case 2: step2Details
        case 3: step3Price
        case 4: step4Pickup
        default: step5Review
        }
    }

    // MARK: - Step 1 · Photos
    private var step1Photos: some View {
        VStack(spacing: 28) {
            stepTitle(title: "Show it off! 📸",
                      subtitle: "Add a photo to make it appetizing.")

            // Dashed upload zone
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.04))
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Theme.Colors.primaryGradientStart.opacity(0.22),
                            style: StrokeStyle(lineWidth: 2, dash: [10, 6]))

                VStack(spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 6)
                            .frame(width: 88, height: 88)
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(Theme.Colors.primaryGradient)
                    }
                    Text("Upload Photo")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text("Let the customers see the goods")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                .padding(.vertical, 44)
            }

            // Camera / Gallery buttons
            VStack(spacing: 12) {
                Button { hapticFeedback(.medium) } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                Button { hapticFeedback(.light) } label: {
                    Label("Choose from Gallery",
                          systemImage: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
            }

            // Lime "Next Step" CTA (step-1 only accent style)
            Button { advance() } label: {
                HStack(spacing: 8) {
                    Text("Next Step")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .black))
                }
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.15), radius: 10, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Step 2 · Details
    private var step2Details: some View {
        VStack(spacing: 28) {
            stepTitle(title: "The Details 🍱",
                      subtitle: "What's on the menu today?")

            VStack(spacing: 20) {
                // Title field
                stepFieldBlock(label: "TITLE") {
                    TextField("e.g., Fresh Morning Croissants", text: $title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }

                // Category chips
                stepFieldBlock(label: "CATEGORY") {
                    LazyVGrid(
                        columns: [GridItem(.flexible()),
                                  GridItem(.flexible()),
                                  GridItem(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(foodTypes) { ft in
                            Button {
                                hapticFeedback(.light)
                                foodType = ft.name
                            } label: {
                                VStack(spacing: 6) {
                                    Text(ft.emoji).font(.system(size: 26))
                                    Text(ft.name.uppercased())
                                        .font(.system(size: 9, weight: .black, design: .rounded))
                                        .tracking(0.5)
                                        .foregroundColor(foodType == ft.name ? .white : Theme.Colors.label)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(foodType == ft.name
                                            ? Theme.Colors.primaryGradient
                                            : LinearGradient(colors: [Color(.systemBackground)],
                                                             startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(foodType == ft.name ? Color.clear : Color(.systemGray4),
                                                lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                // Quantity stepper
                stepFieldBlock(label: "HOW MANY?") {
                    HStack {
                        Button {
                            hapticFeedback(.light)
                            if quantity > 1 { quantity -= 1 }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
                                    .frame(width: 56, height: 56)
                                Image(systemName: "minus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                        }
                        Spacer()
                        Text("\(quantity)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                        Spacer()
                        Button {
                            hapticFeedback(.light)
                            quantity += 1
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
                                    .frame(width: 56, height: 56)
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                }
            }

            navRow { advance() }
        }
    }

    // MARK: - Step 3 · Price
    private var step3Price: some View {
        VStack(spacing: 28) {
            stepTitle(title: "The Price 💰",
                      subtitle: "Set a fair price for your surplus.")

            VStack(spacing: 16) {
                // Free toggle card
                Button {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isFree.toggle()
                        if isFree { price = "" }
                    }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isFree ? Theme.Colors.primaryGradient
                                      : LinearGradient(colors: [Color(.systemGray6)],
                                                       startPoint: .leading, endPoint: .trailing))
                                .frame(width: 48, height: 48)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 20))
                                .foregroundColor(isFree ? .white : Theme.Colors.secondaryLabel)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Offer for Free")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(isFree ? Theme.Colors.primaryGradientStart : Theme.Colors.label)
                            Text("Pure community impact")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(isFree ? Theme.Colors.primaryGradientEnd : Theme.Colors.secondaryLabel)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(isFree ? Theme.Colors.primaryGradientStart : Color(.systemGray5))
                                .frame(width: 26, height: 26)
                            if isFree {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(20)
                    .background(isFree ? Theme.Colors.accent.opacity(0.4) : Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(isFree
                                    ? Theme.Colors.primaryGradientStart.opacity(0.4)
                                    : Color(.systemGray4),
                                    lineWidth: 1.5)
                    )
                    .shadow(color: isFree
                            ? Theme.Colors.primaryGradientStart.opacity(0.15)
                            : Color.black.opacity(0.04),
                            radius: 10, y: 4)
                }
                .buttonStyle(PlainButtonStyle())

                if !isFree {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PRICE")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                            .tracking(1.2)

                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                                    .frame(width: 46, height: 46)
                                Image(systemName: "dollarsign")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Theme.Colors.primaryGradientStart)
                            }
                            TextField("0.00", text: $price)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 26))

                        // AI tip banner
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "b45309"))
                            Text("Pro Tip: 60% off original price sells fastest!")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "92400e"))
                                .tracking(0.3)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(hex: "fefce8"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "fde68a"), lineWidth: 1)
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            navRow { advance() }
        }
    }

    // MARK: - Step 4 · Pickup
    private var step4Pickup: some View {
        VStack(spacing: 28) {
            stepTitle(title: "Pickup Time ⏰",
                      subtitle: "When should they come by?")

            VStack(spacing: 12) {
                ForEach(pickupOptions, id: \.self) { option in
                    let selected = pickupWindow == option
                    Button {
                        hapticFeedback(.light)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            pickupWindow = option
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selected ? .white.opacity(0.22) : Color(.systemGray6))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(selected ? .white : Theme.Colors.secondaryLabel)
                            }
                            Text(option)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(selected ? .white : Theme.Colors.label)
                            Spacer()
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(selected
                                    ? Theme.Colors.primaryGradient
                                    : LinearGradient(colors: [Color(.systemBackground)],
                                                     startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(selected ? Color.clear : Color(.systemGray4), lineWidth: 1)
                        )
                        .shadow(color: selected
                                ? Theme.Colors.primaryGradientStart.opacity(0.25)
                                : Color.black.opacity(0.04),
                                radius: 10, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            navRow { advance() }
        }
    }

    // MARK: - Step 5 · Review
    private var step5Review: some View {
        VStack(spacing: 28) {
            // Sparkle + copy
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Theme.Colors.accent.opacity(0.5))
                        .frame(width: 80, height: 80)
                        .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.2),
                                radius: 12, y: 6)
                    Image(systemName: "sparkles")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(Theme.Colors.primaryGradient)
                }
                Text("Ready to Rescue!")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text("Review your listing one last time.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }

            // Preview card
            VStack(alignment: .leading, spacing: 0) {
                // Image placeholder
                ZStack {
                    Color(.systemGray6)
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundColor(Color(.systemGray4))
                        Text("IMAGE PREVIEW")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(Color(.systemGray4))
                            .tracking(1.2)
                    }
                }
                .frame(height: 170)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(title.isEmpty ? "Untitled Listing" : title)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(Theme.Colors.label)
                            Text((foodType.isEmpty ? "General" : foodType).uppercased())
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundColor(Theme.Colors.primaryGradientStart)
                                .tracking(0.8)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Theme.Colors.primaryGradientStart.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(isFree ? "Free" : (price.isEmpty ? "$0.00" : "$\(price)"))
                                .font(.system(size: 26, weight: .heavy, design: .rounded))
                                .foregroundStyle(Theme.Colors.primaryGradient)
                            Text("Qty: \(quantity)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Colors.secondaryLabel)
                        }
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                        Text("Pickup: \(pickupWindow.isEmpty ? "Not set" : pickupWindow)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(20)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: Color.black.opacity(0.08), radius: 18, y: 6)

            // Edit / Confirm
            HStack(spacing: 14) {
                Button("Edit") {
                    hapticFeedback(.light)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { step = 4 }
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 24))

                Button {
                    hapticFeedback(.success)
                    isPosting = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                } label: {
                    HStack(spacing: 8) {
                        if isPosting {
                            ProgressView().tint(.white).scaleEffect(0.85)
                        }
                        Text(isPosting ? "Posting…" : "Confirm & Post 🚀")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.Colors.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.3), radius: 12, y: 6)
                }
                .disabled(isPosting)
            }
        }
    }

    // MARK: - Shared helpers

    private func stepTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.label)
            Text(subtitle)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func stepFieldBlock<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(Theme.Colors.tertiaryLabel)
                .tracking(1.2)
            content()
        }
    }

    private func navRow(onNext: @escaping () -> Void) -> some View {
        HStack(spacing: 14) {
            Button { goBack() } label: {
                Text("Back")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            Button {
                onNext()
            } label: {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.Colors.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.3), radius: 10, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func advance() {
        hapticFeedback(.light)
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { step += 1 }
    }

    private func goBack() {
        hapticFeedback(.light)
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { step -= 1 }
    }
}
