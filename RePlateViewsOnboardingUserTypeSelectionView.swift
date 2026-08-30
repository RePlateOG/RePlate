//
//  UserTypeSelectionView.swift
//  RePlate
//
//  Account type selection screen
//

import SwiftUI

struct UserTypeSelectionView: View {
    @Binding var selectedType: UserType?
    let onContinue: () -> Void
    
    @State private var animateCards = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            VStack(spacing: Spacing.md) {
                Text("Join RePlate")
                    .font(.displayMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("How would you like to use RePlate?")
                    .font(.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xxxl)
            
            Spacer()
            
            // User type cards
            VStack(spacing: Spacing.lg) {
                UserTypeCard(
                    icon: "fork.knife.circle.fill",
                    title: "I'm a Customer",
                    description: "Find and claim discounted surplus food from local restaurants",
                    isSelected: selectedType == .customer,
                    gradient: Color.primaryGradient
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedType = .customer
                    }
                }
                .offset(x: animateCards ? 0 : -400)
                
                UserTypeCard(
                    icon: "building.2.circle.fill",
                    title: "I'm a Restaurant",
                    description: "Post surplus food, reduce waste, and reach local customers",
                    isSelected: selectedType == .restaurant,
                    gradient: LinearGradient(
                        colors: [Color.accent, Color.primaryGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                ) {
                    HapticManager.shared.selection()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedType = .restaurant
                    }
                }
                .offset(x: animateCards ? 0 : 400)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue button
            RPButton(
                "Continue",
                icon: "arrow.right",
                isDisabled: selectedType == nil
            ) {
                onContinue()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }
}

struct UserTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let isSelected: Bool
    let gradient: LinearGradient
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? gradient : LinearGradient(colors: [Color.secondaryBackground], startPoint: .top, endPoint: .bottom))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .white : .textSecondary)
                }
                
                // Text
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(description)
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Checkmark
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.titleLarge)
                    .foregroundColor(isSelected ? .primaryGradientStart : .textTertiary)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xxl)
                    .fill(Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.xxl)
                            .stroke(
                                isSelected ? Color.primaryGradientStart : Color.divider,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? Color.primaryGradientStart.opacity(0.2) : Color.clear,
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct UserTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UserTypeSelectionView(selectedType: .constant(nil)) {
            print("Continue")
        }
    }
}
