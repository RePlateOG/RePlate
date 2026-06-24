//
//  MenuScannerView.swift
//  RePlate
//
//  OCR-powered menu scanning using Apple Vision + heuristic parsing.
//  No external API required — everything runs on-device.
//
//  TODO: For higher accuracy, pipe rawText to a Supabase Edge Function
//        that calls OpenAI to produce structured JSON before parsing.
//

import SwiftUI
import PhotosUI
import Vision
import Combine

// MARK: - Scanned Menu Item

struct ScannedMenuItem: Identifiable {
    let id = UUID()
    var name: String
    var price: String
    var description: String
    var category: FoodListing.FoodCategory
    var isSelected: Bool = true
}

// MARK: - OCR Engine (no actor isolation — runs on background threads)

private enum MenuScannerEngine {
    static func recognizeText(in image: UIImage) throws -> [String] {
        guard let cg = image.cgImage else {
            throw NSError(domain: "MenuScanner", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Could not read image data"])
        }
        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        try handler.perform([request])
        return (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
    }

    static func parseMenu(from lines: [String]) -> [ScannedMenuItem] {
        let pricePattern = try? NSRegularExpression(
            pattern: #"[\$£€]?\s*\d{1,3}[.,]\d{2}|\d{1,3}\s*[\$£€]"#
        )
        var items: [ScannedMenuItem] = []
        var i = 0
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            guard !line.isEmpty else { i += 1; continue }
            let nsRange = NSRange(line.startIndex..., in: line)
            let lineHasPrice = pricePattern?.firstMatch(in: line, range: nsRange) != nil
            let isHeader = line == line.uppercased() && line.count < 35 && !lineHasPrice
            if isHeader { i += 1; continue }

            if lineHasPrice,
               let match = pricePattern?.firstMatch(in: line, range: nsRange),
               let range = Range(match.range, in: line) {

                let rawPrice = String(line[range])
                    .replacingOccurrences(of: "$", with: "")
                    .replacingOccurrences(of: "£", with: "")
                    .replacingOccurrences(of: "€", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                    .trimmingCharacters(in: .whitespaces)

                var name = String(line[..<range.lowerBound])
                    .replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .trimmingCharacters(in: .whitespaces)
                if name.isEmpty { name = line }

                var desc = ""
                if i + 1 < lines.count {
                    let next = lines[i + 1].trimmingCharacters(in: .whitespaces)
                    let nextRange = NSRange(next.startIndex..., in: next)
                    let nextHasPrice = pricePattern?.firstMatch(in: next, range: nextRange) != nil
                    let nextIsHeader = next == next.uppercased() && next.count < 35
                    if !nextHasPrice && !nextIsHeader && next.count > 5 {
                        desc = next
                        i += 1
                    }
                }
                items.append(ScannedMenuItem(name: name, price: rawPrice,
                                             description: desc, category: inferCategory(from: name)))
            }
            i += 1
        }
        return items
    }

    static func inferCategory(from name: String) -> FoodListing.FoodCategory {
        let s = name.lowercased()
        if s.contains("cake") || s.contains("dessert") || s.contains("ice cream") ||
           s.contains("pudding") || s.contains("brownie") || s.contains("cheesecake") { return .desserts }
        if s.contains("coffee") || s.contains("tea") || s.contains("juice") ||
           s.contains("smoothie") || s.contains("lemonade") || s.contains("chai") { return .beverages }
        if s.contains("bread") || s.contains("muffin") || s.contains("croissant") ||
           s.contains("pastry") || s.contains("bagel") || s.contains("scone") { return .bakery }
        if s.contains("salad") || s.contains("fruit") || s.contains("greens") ||
           s.contains("avocado") || s.contains("veggie") { return .produce }
        if s.contains("chips") || s.contains("fries") || s.contains("popcorn") ||
           s.contains("nachos") { return .snacks }
        if s.contains("curry") || s.contains("naan") || s.contains("tikka") ||
           s.contains("biryani") || s.contains("masala") || s.contains("paneer") ||
           s.contains("samosa") { return .indian }
        if s.contains("pasta") || s.contains("pizza") || s.contains("risotto") ||
           s.contains("lasagna") || s.contains("bruschetta") { return .italian }
        if s.contains("sushi") || s.contains("ramen") || s.contains("tempura") ||
           s.contains("miso") || s.contains("teriyaki") { return .japanese }
        if s.contains("taco") || s.contains("burrito") || s.contains("quesadilla") ||
           s.contains("guacamole") { return .mexican }
        if s.contains("burger") || s.contains("hot dog") || s.contains("bbq") ||
           s.contains("wings") { return .american }
        if s.contains("dumpling") || s.contains("dim sum") || s.contains("fried rice") ||
           s.contains("wonton") { return .chinese }
        if s.contains("pad thai") || s.contains("tom yum") || s.contains("spring roll") { return .thai }
        if s.contains("bulgogi") || s.contains("bibimbap") || s.contains("kimchi") { return .korean }
        return .meals
    }
}

// MARK: - Observable Service (main actor)

@MainActor
final class MenuScannerService: ObservableObject {
    @Published var items: [ScannedMenuItem] = []
    @Published var isScanning = false
    @Published var scanError: String?
    @Published var hasScanned = false

    func scan(image: UIImage) {
        isScanning = true
        scanError = nil
        hasScanned = false
        items = []

        Task {
            do {
                async let lines = Task.detached(priority: .userInitiated) {
                    try MenuScannerEngine.recognizeText(in: image)
                }.value
                let resolved = try await lines
                let parsed = await Task.detached(priority: .userInitiated) {
                    MenuScannerEngine.parseMenu(from: resolved)
                }.value
                items = parsed
                hasScanned = true
                isScanning = false
            } catch {
                scanError = error.localizedDescription
                isScanning = false
            }
        }
    }
}

// MARK: - Main View

struct MenuScannerView: View {
    let onImport: ([ScannedMenuItem]) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = MenuScannerService()

    @State private var pickerItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showSuccess = false

    private var selectedCount: Int { scanner.items.filter(\.isSelected).count }

    var body: some View {
        ZStack {
            Theme.Colors.pageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                scannerHeader
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        imagePickerSection
                        if scanner.isScanning {
                            scanningIndicator
                        } else if let err = scanner.scanError {
                            errorCard(err)
                        } else if !scanner.items.isEmpty {
                            resultsSection
                        } else if capturedImage != nil && scanner.hasScanned {
                            noResultsCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 130)
                }
            }

            if !scanner.items.isEmpty && !scanner.isScanning {
                VStack {
                    Spacer()
                    importCTA
                }
            }

            if showSuccess { successOverlay }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $capturedImage)
        }
        .onChange(of: capturedImage) { _, img in
            if let img { scanner.scan(image: img) }
        }
        .onChange(of: pickerItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    capturedImage = img
                    scanner.scan(image: img)
                }
            }
        }
    }

    // MARK: Header

    private var scannerHeader: some View {
        ZStack(alignment: .top) {
            UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36)
                .fill(Theme.Colors.primaryGradient)
                .ignoresSafeArea(edges: .top)
                .frame(height: 148)

            HStack(alignment: .center) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.18))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: 3) {
                    Text("Scan Menu")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Auto-extract dishes & prices")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)
        }
    }

    // MARK: Image Picker

    private var imagePickerSection: some View {
        VStack(spacing: 12) {
            // Preview or placeholder
            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .strokeBorder(Theme.Colors.primaryGradientStart.opacity(0.35), lineWidth: 1.5)
                    )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Theme.Colors.primaryGradientStart.opacity(0.06))
                        .frame(height: 180)
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [8, 5])
                        )
                        .foregroundColor(Theme.Colors.primaryGradientStart.opacity(0.3))
                        .frame(height: 180)
                    VStack(spacing: 12) {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 46, weight: .thin))
                            .foregroundStyle(Theme.Colors.primaryGradient)
                        Text("Take or upload a photo of your menu")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button { showCamera = true } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Theme.Colors.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Library", systemImage: "photo.on.rectangle.angled")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Theme.Colors.primaryGradientStart.opacity(0.10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Theme.Colors.primaryGradientStart.opacity(0.25), lineWidth: 1.5)
                                )
                        )
                }
            }
        }
    }

    // MARK: Scanning Spinner

    private var scanningIndicator: some View {
        VStack(spacing: 18) {
            ScannerSpinner()
                .frame(width: 68, height: 68)
            Text("Reading your menu…")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            Text("Vision is extracting text from the photo")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 14, y: 4)
        )
    }

    // MARK: Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(scanner.items.count) items detected")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    Text("Edit names, prices or categories before importing")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
                Spacer()
                Button {
                    let allOn = scanner.items.allSatisfy(\.isSelected)
                    for idx in scanner.items.indices { scanner.items[idx].isSelected = !allOn }
                } label: {
                    Text(scanner.items.allSatisfy(\.isSelected) ? "None" : "All")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }

            ForEach($scanner.items) { $item in
                ScannedItemCard(item: $item)
            }
        }
    }

    // MARK: Import CTA

    private var importCTA: some View {
        Button {
            guard selectedCount > 0 else { return }
            hapticFeedback(.medium)
            onImport(scanner.items.filter(\.isSelected))
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSuccess = true }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add \(selectedCount) Item\(selectedCount == 1 ? "" : "s") to Listings")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                selectedCount > 0
                    ? AnyShapeStyle(Theme.Colors.primaryGradient)
                    : AnyShapeStyle(Color(.systemGray4))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Theme.Colors.primaryGradientStart.opacity(selectedCount > 0 ? 0.3 : 0), radius: 12, y: 5)
        }
        .disabled(selectedCount == 0)
        .padding(.horizontal, 20)
        .padding(.bottom, 38)
        .padding(.top, 12)
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: selectedCount)
    }

    // MARK: States

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 38, weight: .medium))
                .foregroundColor(.orange)
            Text("Scan failed")
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
            Button { capturedImage = nil; scanner.scanError = nil } label: {
                Text("Try Again")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 3))
    }

    private var noResultsCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "text.slash")
                .font(.system(size: 38, weight: .light))
                .foregroundColor(Theme.Colors.secondaryLabel)
            Text("No menu items detected")
                .font(.system(size: 17, weight: .bold, design: .rounded))
            Text("Try a clearer photo with better lighting. Make sure prices are visible (e.g. $12.99).")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .multilineTextAlignment(.center)
            Button { capturedImage = nil; scanner.hasScanned = false } label: {
                Text("Try Another Photo")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.primaryGradientStart)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 22).fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 3))
    }

    // MARK: Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryGradient)
                        .frame(width: 96, height: 96)
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Listings Added!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(selectedCount) item\(selectedCount == 1 ? "" : "s") added to your active listings")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { dismiss() }
        }
    }
}

// MARK: - Scanned Item Card

struct ScannedItemCard: View {
    @Binding var item: ScannedMenuItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Include toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                    item.isSelected.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(item.isSelected
                            ? AnyShapeStyle(Theme.Colors.primaryGradient)
                            : AnyShapeStyle(Color(.systemGray5)))
                        .frame(width: 28, height: 28)
                    if item.isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 10) {
                // Dish name
                TextField("Dish name", text: $item.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(item.isSelected ? Theme.Colors.label : Theme.Colors.secondaryLabel)

                // Price + category row
                HStack(spacing: 6) {
                    Text("$")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                    TextField("0.00", text: $item.price)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .keyboardType(.decimalPad)
                        .frame(width: 72)

                    Spacer()

                    // Category picker
                    Menu {
                        ForEach(FoodListing.FoodCategory.allCases, id: \.self) { cat in
                            Button { item.category = cat } label: {
                                Label(cat.rawValue, systemImage: cat.icon)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(item.category.rawValue)
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                        )
                    }
                }

                // Description (if present)
                if !item.description.isEmpty {
                    TextField("Description (optional)", text: $item.description)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.Colors.secondaryLabel)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(item.isSelected ? 0.07 : 0.03), radius: 10, y: 3)
        )
        .opacity(item.isSelected ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.18), value: item.isSelected)
    }
}

// MARK: - Spinner

private struct ScannerSpinner: View {
    @State private var angle = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.primaryGradientStart.opacity(0.15), lineWidth: 5)
            Circle()
                .trim(from: 0.08, to: 0.78)
                .stroke(
                    AngularGradient(
                        colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(angle))
            Image(systemName: "text.viewfinder")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Theme.Colors.primaryGradientStart)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
    }
}

// MARK: - Camera Picker

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        init(_ parent: CameraPickerView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage { parent.image = img }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}
