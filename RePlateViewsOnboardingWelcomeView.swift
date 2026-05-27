//
//  WelcomeView.swift
//  RePlate
//
//  Welcome/splash screen with animations
//

import SwiftUI

struct WelcomeView: View {
    @State private var animateGradient = false
    @State private var animateLogo = false
    @State private var showContent = false
    
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Animated background
            Color.primaryGradient
                .hueRotation(.degrees(animateGradient ? 10 : 0))
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateGradient = true
                    }
                }
            
            VStack(spacing: Spacing.xxxl) {
                Spacer()
                
                // Logo and title
                VStack(spacing: Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color.primaryGradient)
                    }
                    .scaleEffect(animateLogo ? 1.0 : 0.5)
                    .opacity(animateLogo ? 1.0 : 0.0)
                    
                    VStack(spacing: Spacing.xs) {
                        Text("RePlate")
                            .font(.displayLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Save Food. Save Money. Save the Planet.")
                            .font(.titleMedium)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                }
                
                Spacer()
                
                // Stats
                HStack(spacing: Spacing.xl) {
                    StatPill(icon: "fork.knife", value: "1M+", label: "Meals Saved")
                    StatPill(icon: "leaf.fill", value: "500T", label: "CO₂ Reduced")
                    StatPill(icon: "building.2.fill", value: "5K+", label: "Restaurants")
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                
                // CTA Button
                RPButton("Get Started", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, Spacing.xl)
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                    .frame(height: Spacing.xl)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateLogo = true
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                showContent = true
            }
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.titleMedium)
                .foregroundColor(.white)
            
            Text(value)
                .font(.titleLarge)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.labelSmall)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .background(
            Color.white.opacity(0.2)
                .cornerRadius(CornerRadius.lg)
        )
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView {
            print("Continue tapped")
        }
    }
}
