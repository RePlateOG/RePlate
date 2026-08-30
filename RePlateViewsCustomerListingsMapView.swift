//
//  ListingsMapView.swift
//  RePlate
//
//  Map view showing nearby listings
//

import SwiftUI
import MapKit

struct ListingsMapView: View {
    let listings: [Listing]
    @Binding var selectedListing: Listing?
    let userLocation: CLLocationCoordinate2D?
    
    @State private var region: MKCoordinateRegion
    
    init(listings: [Listing], selectedListing: Binding<Listing?>, userLocation: CLLocationCoordinate2D?) {
        self.listings = listings
        self._selectedListing = selectedListing
        self.userLocation = userLocation
        
        let center = userLocation ?? CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        _region = State(initialValue: MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: listings) { listing in
            MapAnnotation(coordinate: listing.restaurantLocation.coordinate) {
                ListingMapMarker(listing: listing) {
                    HapticManager.shared.light()
                    selectedListing = listing
                }
            }
        }
    }
}

struct ListingMapMarker: View {
    let listing: Listing
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Circle()
                        .fill(listing.isFree ? Color.success : Color.primaryGradientStart)
                        .frame(width: 44, height: 44)
                    
                    if listing.isFree {
                        Image(systemName: "gift.fill")
                            .font(.titleSmall)
                            .foregroundColor(.white)
                    } else {
                        Text("$\(Int(listing.discountedPrice))")
                            .font(.labelLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                // Pointer triangle
                Triangle()
                    .fill(Color.white)
                    .frame(width: 12, height: 8)
                    .offset(y: -1)
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var viewModel: CustomerHomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Distance
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Distance")
                            .font(.titleSmall)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Up to \(String(format: "%.1f", viewModel.maxDistance)) mi")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                        }
                        
                        Slider(value: $viewModel.maxDistance, in: 0.5...25, step: 0.5)
                            .tint(Color.primaryGradientStart)
                    }
                    
                    Divider()
                    
                    // Price
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Price")
                            .font(.titleSmall)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Up to $\(String(format: "%.0f", viewModel.maxPrice))")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                            
                            Spacer()
                        }
                        
                        Slider(value: $viewModel.maxPrice, in: 0...100, step: 5)
                            .tint(Color.primaryGradientStart)
                        
                        Toggle("Free items only", isOn: $viewModel.showFreeOnly)
                            .font(.bodyMedium)
                            .tint(Color.primaryGradientStart)
                    }
                    
                    Divider()
                    
                    // Category
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Category")
                            .font(.titleSmall)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: Spacing.sm) {
                            ForEach(FoodCategory.allCases, id: \.self) { category in
                                FilterCategoryButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    HapticManager.shared.selection()
                                    if viewModel.selectedCategory == category {
                                        viewModel.selectedCategory = nil
                                    } else {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        HapticManager.shared.light()
                        viewModel.resetFilters()
                    }
                    .foregroundColor(.primaryGradientStart)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        HapticManager.shared.light()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGradientStart)
                }
            }
        }
    }
}

struct FilterCategoryButton: View {
    let category: FoodCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(category.icon)
                    .font(.bodyMedium)
                
                Text(category.rawValue)
                    .font(.labelMedium)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ? Color.primaryGradient : AnyShapeStyle(Color.secondaryBackground)
            )
            .cornerRadius(CornerRadius.lg)
        }
    }
}

// MARK: - Preview
struct ListingsMapView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsMapView(
            listings: [],
            selectedListing: .constant(nil),
            userLocation: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        )
    }
}
