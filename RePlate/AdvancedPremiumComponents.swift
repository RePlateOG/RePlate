//
//  AdvancedPremiumComponents.swift
//  RePlate - Advanced Premium UI Components
//
//  Created by Jyotika Sadani on 5/27/26.
//

import SwiftUI
import MapKit
import Combine

// MARK: - Premium Search Bar
struct PremiumSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    let placeholder: String
    let onSearch: () -> Void
    
    init(text: Binding<String>, placeholder: String = "Search food...", onSearch: @escaping () -> Void = {}) {
        self._text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isFocused ? Theme.Colors.primaryGradient : LinearGradient(colors: [Theme.Colors.secondaryLabel], startPoint: .top, endPoint: .bottom))
                
                TextField(placeholder, text: $text)
                    .font(Theme.Typography.body)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(onSearch)
                
                if !text.isEmpty {
                    Button {
                        withAnimation(Theme.Animation.fast) {
                            text = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Colors.tertiaryLabel)
                    }
                }
            }
            .padding(Theme.Spacing.base)
            .background(Theme.Colors.secondaryBackground)
            .cornerRadius(Theme.CornerRadius.base)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.base)
                    .stroke(isFocused ? Theme.Colors.primaryGradientStart : Color.clear, lineWidth: 2)
            )
            .animation(Theme.Animation.springSnappy, value: isFocused)
            
            if isFocused {
                Button("Cancel") {
                    isFocused = false
                    text = ""
                }
                .font(Theme.Typography.callout)
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(Theme.Animation.springSnappy, value: isFocused)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, isSelected: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            action()
        }) {
            HStack(spacing: Theme.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(Theme.Typography.subheadlineMedium)
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.label)
            .padding(.horizontal, Theme.Spacing.base)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                Group {
                    if isSelected {
                        Theme.Colors.primaryGradient
                    } else {
                        LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .cornerRadius(Theme.CornerRadius.pill)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.pill)
                    .stroke(isSelected ? Color.clear : Theme.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Premium Map Preview
struct PremiumMapPreview: View {
    let coordinate: CLLocationCoordinate2D
    let restaurantName: String
    let showFullMap: () -> Void

    @State private var position: MapCameraPosition

    init(coordinate: CLLocationCoordinate2D, restaurantName: String, showFullMap: @escaping () -> Void) {
        self.coordinate = coordinate
        self.restaurantName = restaurantName
        self.showFullMap = showFullMap
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }

    var body: some View {
        Button(action: showFullMap) {
            ZStack(alignment: .topTrailing) {
                Map(position: $position) {
                    Marker(restaurantName, coordinate: coordinate)
                        .tint(Theme.Colors.primaryGradientStart)
                }
                .frame(height: 200)
                .cornerRadius(Theme.CornerRadius.card)
                .allowsHitTesting(false)

                // Overlay gradient for better contrast
                LinearGradient(
                    colors: [Color.black.opacity(0.3), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                .cornerRadius(Theme.CornerRadius.card)

                // Expand button
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(Theme.Spacing.sm)
                    .background(.ultraThinMaterial)
                    .cornerRadius(Theme.CornerRadius.xs)
                    .padding(Theme.Spacing.compactSpacing)
            }
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14))
                    Text("Tap to open in Maps")
                        .font(Theme.Typography.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xs)
                .background(.ultraThinMaterial)
                .cornerRadius(Theme.CornerRadius.xs)
                .padding(Theme.Spacing.compactSpacing)
            }
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Rating Display
struct RatingDisplay: View {
    let rating: Double
    let totalReviews: Int
    let style: DisplayStyle
    
    enum DisplayStyle {
        case compact
        case detailed
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: starIcon(for: index))
                        .font(.system(size: style == .compact ? 11 : 14))
                        .foregroundColor(Theme.Colors.warning)
                }
            }
            
            if style == .detailed {
                Text(String(format: "%.1f", rating))
                    .font(Theme.Typography.subheadlineMedium)
                    .foregroundColor(Theme.Colors.label)
                
                Text("•")
                    .foregroundColor(Theme.Colors.tertiaryLabel)
                
                Text("\(totalReviews) reviews")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            } else {
                Text(String(format: "%.1f", rating))
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
        }
    }
    
    private func starIcon(for index: Int) -> String {
        let position = Double(index) + 0.5
        if rating >= position + 0.5 {
            return "star.fill"
        } else if rating >= position {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Time Remaining Badge
struct TimeRemainingBadge: View {
    let expiresAt: Date
    @State private var timeRemaining: String = ""
    @State private var isUrgent: Bool = false
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.system(size: 11))
            Text(timeRemaining)
                .font(Theme.Typography.captionSemibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xxs)
        .background(isUrgent ? Theme.Colors.error : Theme.Colors.warning)
        .cornerRadius(Theme.CornerRadius.xs)
        .onAppear(perform: updateTimeRemaining)
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let interval = expiresAt.timeIntervalSinceNow
        isUrgent = interval < 1800 // Less than 30 minutes
        
        if interval <= 0 {
            timeRemaining = "Expired"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            timeRemaining = "\(minutes)m left"
        } else {
            let hours = Int(interval / 3600)
            timeRemaining = "\(hours)h left"
        }
    }
}

// MARK: - Impact Progress Ring
struct ImpactProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // Icon
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(value)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.label)
                }
            }
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(Theme.Animation.springSmooth.delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Verification Badge
struct VerificationBadge: View {
    let isVerified: Bool
    
    var body: some View {
        if isVerified {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Colors.info)
                Text("Verified")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.info)
            }
            .padding(.horizontal, Theme.Spacing.xs)
            .padding(.vertical, 2)
            .background(Theme.Colors.infoLight)
            .cornerRadius(Theme.CornerRadius.xs)
        }
    }
}

// MARK: - Premium Segmented Control
struct PremiumSegmentedControl: View {
    @Binding var selectedIndex: Int
    let items: [String]
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                Button {
                    withAnimation(Theme.Animation.springSnappy) {
                        selectedIndex = index
                    }
                    hapticFeedback(.light)
                } label: {
                    Text(items[index])
                        .font(Theme.Typography.calloutMedium)
                        .foregroundColor(selectedIndex == index ? .white : Theme.Colors.label)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(
                            Group {
                                if selectedIndex == index {
                                    Theme.Colors.primaryGradient
                                        .matchedGeometryEffect(id: "segment", in: animation)
                                }
                            }
                        )
                        .cornerRadius(Theme.CornerRadius.xs)
                }
            }
        }
        .padding(4)
        .background(Theme.Colors.secondaryBackground)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Quantity Stepper
struct QuantityStepper: View {
    @Binding var quantity: Int
    let min: Int
    let max: Int
    
    init(quantity: Binding<Int>, min: Int = 1, max: Int = 10) {
        self._quantity = quantity
        self.min = min
        self.max = max
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.base) {
            Button {
                if quantity > min {
                    withAnimation(Theme.Animation.springBouncy) {
                        quantity -= 1
                    }
                    hapticFeedback(.light)
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(quantity > min ? Theme.Colors.primaryGradientStart : Theme.Colors.tertiaryLabel)
                    .frame(width: 40, height: 40)
                    .background(Theme.Colors.secondaryBackground)
                    .cornerRadius(Theme.CornerRadius.xs)
            }
            .disabled(quantity <= min)
            
            Text("\(quantity)")
                .font(Theme.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.label)
                .frame(minWidth: 40)
            
            Button {
                if quantity < max {
                    withAnimation(Theme.Animation.springBouncy) {
                        quantity += 1
                    }
                    hapticFeedback(.light)
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(quantity < max ? .white : Theme.Colors.tertiaryLabel)
                    .frame(width: 40, height: 40)
                    .background(
                        Group {
                            if quantity < max {
                                Theme.Colors.primaryGradient
                            } else {
                                LinearGradient(colors: [Theme.Colors.secondaryBackground], startPoint: .leading, endPoint: .trailing)
                            }
                        }
                    )
                    .cornerRadius(Theme.CornerRadius.xs)
            }
            .disabled(quantity >= max)
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Share Button
struct ShareButton: View {
    let items: [Any]
    
    init(items: [Any]) {
        self.items = items
    }
    
    var body: some View {
        Button {
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootViewController.view
                rootViewController.present(activityVC, animated: true)
            }
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Colors.label)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.secondaryBackground)
                .cornerRadius(Theme.CornerRadius.xs)
        }
        .buttonStyle(PremiumScaleButtonStyle())
    }
}

// MARK: - Premium Pull-to-Refresh Indicator (Custom)
struct PremiumRefreshIndicator: View {
    @Binding var isRefreshing: Bool
    
    var body: some View {
        if isRefreshing {
            HStack(spacing: Theme.Spacing.sm) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.Colors.primaryGradientStart))
                Text("Refreshing...")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.secondaryLabel)
            }
            .padding(Theme.Spacing.md)
            .transition(.opacity)
        }
    }
}

// MARK: - Bottom Sheet
struct BottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                // Dimmed background
                Theme.Colors.overlay
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(Theme.Animation.springSmooth) {
                            isPresented = false
                        }
                    }
                
                // Sheet
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle
                        Capsule()
                            .fill(Theme.Colors.tertiaryLabel)
                            .frame(width: 36, height: 5)
                            .padding(.top, Theme.Spacing.compactSpacing)
                            .padding(.bottom, Theme.Spacing.base)
                        
                        // Content
                        content
                            .padding(.bottom, Theme.Spacing.xl)
                    }
                    .background(Theme.Colors.background)
                    .cornerRadius(Theme.CornerRadius.sheet, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.2), radius: 24, y: -8)
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(Theme.Animation.springSmooth, value: isPresented)
    }
}

// MARK: - Rounded Corners Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Animated Number
struct AnimatedNumber: View {
    let value: Double
    let format: String
    
    @State private var displayValue: Double = 0
    
    init(value: Double, format: String = "%.0f") {
        self.value = value
        self.format = format
    }
    
    var body: some View {
        Text(String(format: format, displayValue))
            .onAppear {
                withAnimation(Theme.Animation.springSmooth.delay(0.2)) {
                    displayValue = value
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(Theme.Animation.springSmooth) {
                    displayValue = newValue
                }
            }
    }
}
