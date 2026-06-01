//
//  RestaurantInsightsView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/30/26.
//  Analytics & impact dashboard for restaurant accounts.
//

import SwiftUI
import Charts

// MARK: - Restaurant Insights View
struct RestaurantInsightsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedPeriod = 0 // 0 = This Week, 1 = This Month

    // MARK: Chart data
    private var chartData: [(day: String, meals: Int)] {
        selectedPeriod == 0
            ? [("Mon",8),("Tue",12),("Wed",7),("Thu",15),("Fri",22),("Sat",18),("Sun",10)]
            : [("W1",45),("W2",62),("W3",58),("W4",71)]
    }
    private var totalMeals:   Int    { chartData.map(\.meals).reduce(0, +) }
    private var totalRevenue: Double { Double(totalMeals) * 4.8 }
    private var totalCO2:     Double { Double(totalMeals) * 1.3 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                gradientHeader
                mainContent
            }
            .padding(.bottom, 100)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGray6).opacity(0.3))
    }

    // MARK: - Gradient Header
    private var gradientHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Insights")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("Track your impact & performance")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Button { hapticFeedback(.light) } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Period pill picker
            HStack(spacing: 0) {
                ForEach(["This Week", "This Month"], id: \.self) { period in
                    let idx = period == "This Week" ? 0 : 1
                    Button {
                        hapticFeedback(.light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedPeriod = idx
                        }
                    } label: {
                        Text(period)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(selectedPeriod == idx
                                ? Theme.Colors.primaryGradientStart
                                : .white.opacity(0.7))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(selectedPeriod == idx ? Color.white : Color.clear)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(4)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 20)
        .background(Theme.Colors.primaryGradient)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 24) {
            chartCard
                .padding(.horizontal, 20)
                .offset(y: -24)
                .padding(.bottom, -24)

            statsGrid
                .padding(.horizontal, 20)

            feedbackCard
                .padding(.horizontal, 20)

            exportSection
                .padding(.horizontal, 20)
        }
        .padding(.top, 36)
    }

    // MARK: - Chart Card
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalMeals)")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text("Meals Rescued")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                    Text("+12%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                }
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.Colors.primaryGradientStart.opacity(0.1))
                .clipShape(Capsule())
            }

            Chart {
                ForEach(chartData, id: \.day) { point in
                    AreaMark(
                        x: .value("Day",   point.day),
                        y: .value("Meals", point.meals)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.Colors.primaryGradientStart.opacity(0.3),
                                Theme.Colors.primaryGradientStart.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Day",   point.day),
                        y: .value("Meals", point.meals)
                    )
                    .foregroundStyle(Theme.Colors.primaryGradientStart)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Day",   point.day),
                        y: .value("Meals", point.meals)
                    )
                    .foregroundStyle(Theme.Colors.primaryGradientStart)
                    .symbolSize(28)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.Colors.secondaryLabel)
                }
            }
            .frame(height: 140)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 6)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 14
        ) {
            insightStatCell(icon: "bag.fill",               value: "\(totalMeals)",                  label: "Meals Saved",  accent: false)
            insightStatCell(icon: "dollarsign.circle.fill", value: "$\(Int(totalRevenue))",          label: "Revenue",      accent: true)
            insightStatCell(icon: "leaf.fill",              value: "\(Int(totalCO2))kg",             label: "CO₂ Saved",    accent: false)
            insightStatCell(icon: "star.fill",              value: "4.8",                            label: "Avg Rating",   accent: true)
        }
    }

    private func insightStatCell(
        icon: String, value: String, label: String, accent: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            accent
                                ? Theme.Colors.accent.opacity(0.35)
                                : Theme.Colors.primaryGradientStart.opacity(0.12)
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(
                            accent
                                ? Theme.Colors.primaryGradientEnd
                                : Theme.Colors.primaryGradientStart
                        )
                }
                Spacer()
                Text(label.uppercased())
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .tracking(0.4)
                    .multilineTextAlignment(.trailing)
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.label)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
    }

    // MARK: - Feedback Card
    private var feedbackCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Customer Feedback")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                    Text("4.8")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                }
            }

            VStack(spacing: 12) {
                ratingBar(label: "Freshness",   value: 0.95)
                ratingBar(label: "Pickup Exp.", value: 0.88)
                ratingBar(label: "Value",       value: 0.92)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    private func ratingBar(label: String, value: Double) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .frame(width: 76, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: geo.size.width * value, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(Int(value * 100))%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .frame(width: 36, alignment: .trailing)
        }
    }

    // MARK: - Export Section
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXPORT REPORTS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .tracking(0.8)
                .padding(.horizontal, 4)

            HStack(spacing: 14) {
                exportCard(
                    icon: "doc.richtext.fill",
                    iconColor: .red,
                    title: "Impact PDF",
                    subtitle: "Share your environmental impact"
                )
                exportCard(
                    icon: "tablecells.fill",
                    iconColor: Theme.Colors.primaryGradientStart,
                    title: "Sales CSV",
                    subtitle: "Revenue and order history"
                )
            }
        }
    }

    private func exportCard(
        icon: String, iconColor: Color, title: String, subtitle: String
    ) -> some View {
        Button { hapticFeedback(.light) } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
