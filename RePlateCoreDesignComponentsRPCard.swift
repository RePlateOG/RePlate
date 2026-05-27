//
//  RPCard.swift
//  RePlate
//
//  Reusable glassmorphic card component
//

import SwiftUI

struct RPCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let hasShadow: Bool
    let hasGlassmorphism: Bool
    
    init(
        padding: CGFloat = Spacing.md,
        cornerRadius: CGFloat = CornerRadius.xxl,
        hasShadow: Bool = true,
        hasGlassmorphism: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.hasShadow = hasShadow
        self.hasGlassmorphism = hasGlassmorphism
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    if hasGlassmorphism {
                        GlassmorphicBackground()
                    } else {
                        Color.cardBackground
                    }
                }
            )
            .cornerRadius(cornerRadius)
            .shadow(
                color: hasShadow ? Shadow.medium.color : .clear,
                radius: Shadow.medium.radius,
                x: Shadow.medium.x,
                y: Shadow.medium.y
            )
    }
}

struct GlassmorphicBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color.white.opacity(0.1)
            } else {
                Color.white.opacity(0.7)
            }
            
            BlurView(style: colorScheme == .dark ? .dark : .light)
        }
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - Preview
struct RPCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryGradient
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                RPCard {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Standard Card")
                            .font(.titleMedium)
                        Text("This is a standard card with shadow")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                RPCard(hasGlassmorphism: true) {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Glassmorphic Card")
                            .font(.titleMedium)
                        Text("This card has glassmorphism effect")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
        }
    }
}
