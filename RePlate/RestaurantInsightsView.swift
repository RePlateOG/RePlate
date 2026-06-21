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
    @State private var selectedPeriod  = 0 // 0 = This Week, 1 = This Month
    @State private var showAllReviews  = false

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
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showAllReviews) { AllReviewsSheet() }
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
                let shareText = "RePlate Impact Report: \(totalMeals) meals rescued, $\(Int(totalRevenue)) revenue, \(Int(totalCO2)) kg CO₂ saved."
                ShareLink(item: shareText) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white.opacity(0.2))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.3), lineWidth: 1))
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

            ratingsCard
                .padding(.horizontal, 20)

            recentReviewsSection
                .padding(.horizontal, 20)

            communityImpactCard
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

    // MARK: - Ratings Card
    private var ratingsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Customer Ratings")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.label)

            HStack(alignment: .center, spacing: 20) {
                // Big average
                VStack(spacing: 6) {
                    Text("4.8")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.Colors.primaryGradient)
                    HStack(spacing: 3) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)
                        }
                    }
                    Text("238 reviews")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                .frame(width: 100)

                // Distribution bars
                VStack(spacing: 8) {
                    starDistBar(stars: 5, proportion: 0.85)
                    starDistBar(stars: 4, proportion: 0.12)
                    starDistBar(stars: 3, proportion: 0.03)
                    starDistBar(stars: 2, proportion: 0.00)
                    starDistBar(stars: 1, proportion: 0.00)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
    }

    private func starDistBar(stars: Int, proportion: Double) -> some View {
        HStack(spacing: 8) {
            Text("\(stars)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .frame(width: 10)
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundColor(.orange)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: geo.size.width * proportion, height: 6)
                }
            }
            .frame(height: 6)

            Text(proportion > 0 ? "\(Int(proportion * 100))%" : "0%")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .frame(width: 28, alignment: .trailing)
        }
    }

    // MARK: - Recent Reviews Section
    private struct ReviewData: Identifiable {
        let id = UUID()
        let name: String
        let initials: String
        let stars: Int
        let comment: String
        let date: String
        let avatarColor: Color
    }

    private let recentReviews: [ReviewData] = [
        .init(name: "Sarah J.", initials: "SJ", stars: 5,
              comment: "Food was fresh and ready exactly on time! Will definitely order again.",
              date: "2 days ago",
              avatarColor: Color(hex: "5db996")),
        .init(name: "Mike C.",  initials: "MC", stars: 5,
              comment: "Amazing value. Got 6 croissants for $2.50. This app is a game changer!",
              date: "5 days ago",
              avatarColor: Color(hex: "118b50")),
        .init(name: "Emily D.", initials: "ED", stars: 4,
              comment: "Good quantity and really helpful staff at pickup. Minor wait but worth it.",
              date: "1 week ago",
              avatarColor: Color(hex: "3aa76d")),
    ]

    private var recentReviewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Reviews")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
                Spacer()
                Button {
                    hapticFeedback(.light)
                    showAllReviews = true
                } label: {
                    Text("See All")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }

            VStack(spacing: 12) {
                ForEach(recentReviews) { review in
                    reviewCard(review)
                }
            }
        }
    }

    private func reviewCard(_ review: ReviewData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Avatar circle
                ZStack {
                    Circle()
                        .fill(review.avatarColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text(review.initials)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(review.avatarColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(review.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    HStack(spacing: 3) {
                        ForEach(0..<review.stars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                Text(review.date)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }

            Text(review.comment)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 3)
    }

    // MARK: - Community Impact Card
    private var communityImpactCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Community Impact")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("RePlate platform totals")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }
            }

            HStack(spacing: 0) {
                communityStatColumn(value: "12,487", label: "Meals\nRescued",    icon: "bag.fill")
                Divider()
                    .frame(width: 1, height: 56)
                    .background(.white.opacity(0.3))
                    .padding(.horizontal, 4)
                communityStatColumn(value: "23,156", label: "lbs Food\nSaved",  icon: "scalemass.fill")
                Divider()
                    .frame(width: 1, height: 56)
                    .background(.white.opacity(0.3))
                    .padding(.horizontal, 4)
                communityStatColumn(value: "15,234", label: "kg CO₂\nPrevented", icon: "leaf.fill")
            }
        }
        .padding(22)
        .background(Theme.Colors.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: Theme.Colors.primaryGradientStart.opacity(0.3), radius: 16, y: 8)
    }

    private func communityStatColumn(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
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
        let exportText: String = {
            if title.contains("CSV") {
                return "Date,Meals,Revenue\n" + chartData.map { "\($0.day),\($0.meals),$\(String(format:"%.2f",Double($0.meals)*4.8))" }.joined(separator: "\n")
            }
            return "RePlate Impact Report\nMeals Rescued: \(totalMeals)\nRevenue: $\(Int(totalRevenue))\nCO₂ Saved: \(Int(totalCO2))kg\nAvg Rating: 4.8/5"
        }()
        return ShareLink(item: exportText, subject: Text(title), message: Text(subtitle)) {
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

// MARK: - All Reviews Sheet
private struct AllReviewsSheet: View {
    @Environment(\.dismiss) var dismiss

    private struct Review: Identifiable {
        let id = UUID(); let name: String; let initials: String
        let stars: Int; let comment: String; let date: String; let color: Color
    }
    private let reviews: [Review] = [
        .init(name:"Sarah J.",  initials:"SJ", stars:5, comment:"Food was fresh and ready exactly on time! Will definitely order again.", date:"2 days ago",  color:Color(hex:"5db996")),
        .init(name:"Mike C.",   initials:"MC", stars:5, comment:"Amazing value. Got 6 croissants for $2.50. This app is a game changer!", date:"5 days ago",  color:Color(hex:"118b50")),
        .init(name:"Emily D.",  initials:"ED", stars:4, comment:"Good quantity and really helpful staff at pickup. Minor wait but worth it.", date:"1 week ago", color:Color(hex:"3aa76d")),
        .init(name:"James K.",  initials:"JK", stars:5, comment:"Incredible food at an unbeatable price. The portions were huge!", date:"1 week ago",  color:.orange),
        .init(name:"Priya M.",  initials:"PM", stars:5, comment:"Staff was super friendly and the food was still warm. Highly recommend.", date:"2 weeks ago", color:.purple),
        .init(name:"Carlos R.", initials:"CR", stars:4, comment:"Great deal. The salad was fresh and filling. Would order again.", date:"2 weeks ago", color:.pink),
    ]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(reviews) { r in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(r.color.opacity(0.2)).frame(width: 40, height: 40)
                                    Text(r.initials).font(.system(size: 13, weight: .black, design: .rounded)).foregroundColor(r.color)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(r.name).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Theme.Colors.label)
                                    HStack(spacing: 3) {
                                        ForEach(0..<r.stars, id:\.self) { _ in
                                            Image(systemName:"star.fill").font(.system(size:10)).foregroundColor(.orange)
                                        }
                                    }
                                }
                                Spacer()
                                Text(r.date).font(.system(size:11, weight:.medium, design:.rounded)).foregroundColor(Theme.Colors.tertiaryLabel)
                            }
                            Text(r.comment).font(.system(size:13, weight:.medium, design:.rounded)).foregroundColor(Theme.Colors.secondaryLabel).lineSpacing(2).fixedSize(horizontal:false, vertical:true)
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius:22))
                        .shadow(color:Color.black.opacity(0.05), radius:8, y:3)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("All Reviews")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
