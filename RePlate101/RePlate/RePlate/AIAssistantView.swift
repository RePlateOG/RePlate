//
//  AIAssistantView.swift
//  RePlate
//

import SwiftUI
import Combine
import Supabase

// MARK: - Data Models

private struct AIRecommendation: Identifiable, Decodable {
    let id: String
    let title: String
    let price_label: String
    let reason: String
}

private struct AIResponse: Decodable {
    let greeting: String
    let recommendations: [AIRecommendation]
    let summary: String
}

private struct ChatMessage: Identifiable {
    let id = UUID()
    let isUser: Bool
    let text: String
    let recommendations: [AIRecommendation]
    let timestamp = Date()
}

// MARK: - ViewModel

@MainActor
private class AIAssistantViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabaseFunctionURL = URL(
        string: "https://qubatmvrhcvllqwakcgk.supabase.co/functions/v1/ai-food-assistant"
    )!

    func send() async {
        let query = inputText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty, !isLoading else { return }
        inputText = ""
        isLoading = true
        errorMessage = nil

        messages.append(ChatMessage(isUser: true, text: query, recommendations: []))

        do {
            guard let token = supabase.auth.currentSession?.accessToken else {
                throw URLError(.userAuthenticationRequired)
            }

            var req = URLRequest(url: supabaseFunctionURL)
            req.httpMethod = "POST"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(["query": query])

            let (data, _) = try await URLSession.shared.data(for: req)
            let response = try JSONDecoder().decode(AIResponse.self, from: data)

            let reply = "\(response.greeting)\n\n\(response.summary)"
            messages.append(ChatMessage(
                isUser: false,
                text: reply,
                recommendations: response.recommendations
            ))
        } catch {
            messages.append(ChatMessage(
                isUser: false,
                text: "Sorry, I ran into a hiccup. Try again in a moment.",
                recommendations: []
            ))
        }
        isLoading = false
    }

    func sendSuggestion(_ text: String) {
        inputText = text
        Task { await send() }
    }
}

// MARK: - Main View

struct AIAssistantView: View {
    @StateObject private var vm = AIAssistantViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @FocusState private var inputFocused: Bool

    private let suggestions = [
        "Something vegan tonight",
        "Healthy under $8",
        "Surprise me!",
        "Free food near me",
        "High protein options",
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                // Welcome card (shown when empty)
                                if vm.messages.isEmpty {
                                    welcomeCard
                                        .padding(.horizontal, 20)
                                        .padding(.top, 20)
                                    suggestionChips
                                }

                                ForEach(vm.messages) { message in
                                    AIMessageBubble(message: message)
                                        .padding(.horizontal, 20)
                                        .id(message.id)
                                }

                                if vm.isLoading {
                                    TypingIndicator()
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 120)
                        }
                        .onChange(of: vm.messages.count) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(vm.messages.last?.id, anchor: .bottom)
                            }
                        }
                        .onChange(of: vm.isLoading) {
                            if vm.isLoading {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("typing", anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Input bar (pinned to bottom)
                inputBar
            }
            .navigationTitle("Ask RePlate AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.Colors.secondaryLabel)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }

    // MARK: - Welcome card
    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 44, height: 44)
                    Text("✨")
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("RePlate AI")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Text("Powered by Claude")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.primaryGradientStart)
                }
            }
            Text("Tell me what you're craving and I'll find the best surplus food deals near you — vegan, budget-friendly, whatever you need.")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(Theme.Colors.secondaryLabel)
                .lineSpacing(4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Suggestion chips
    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { text in
                    Button {
                        hapticFeedback(.light)
                        vm.sendSuggestion(text)
                    } label: {
                        Text(text)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Theme.Colors.primaryGradientStart.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Theme.Colors.primaryGradientStart.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Input bar
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                TextField("Ask me anything about food nearby...", text: $vm.inputText, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.system(size: 15, design: .rounded))
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit { Task { await vm.send() } }

                Button {
                    hapticFeedback(.medium)
                    inputFocused = false
                    Task { await vm.send() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                (vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isLoading)
                                    ? AnyShapeStyle(Color(.systemGray4))
                                    : AnyShapeStyle(LinearGradient(
                                        colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
    }
}

// MARK: - Message Bubble

private struct AIMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            if !message.isUser {
                // AI avatar + message
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 32, height: 32)
                        Text("✨")
                            .font(.system(size: 16))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.text)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                            )
                        // Recommendation cards
                        if !message.recommendations.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(message.recommendations) { rec in
                                    RecommendationCard(rec: rec)
                                }
                            }
                        }
                    }
                }
            } else {
                // User message (right-aligned)
                HStack {
                    Spacer()
                    Text(message.text)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                        )
                        .frame(maxWidth: 280, alignment: .trailing)
                }
            }
        }
    }
}

// MARK: - Recommendation Card

private struct RecommendationCard: View {
    let rec: AIRecommendation

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.Colors.primaryGradientStart.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text("🍱")
                    .font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(rec.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.Colors.label)
                    Spacer()
                    Text(rec.price_label)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(rec.price_label == "FREE"
                            ? Theme.Colors.primaryGradientStart
                            : Theme.Colors.label)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(rec.price_label == "FREE"
                                    ? Theme.Colors.primaryGradientStart.opacity(0.12)
                                    : Color(.systemGray6))
                        )
                }
                Text(rec.reason)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(Theme.Colors.secondaryLabel)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.Colors.primaryGradientStart.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Theme.Colors.primaryGradientStart, Theme.Colors.primaryGradientEnd],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                Text("✨")
                    .font(.system(size: 16))
            }
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Theme.Colors.secondaryLabel)
                        .frame(width: 8, height: 8)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
            )
        }
        .id("typing")
        .onAppear { phase = 2 }
    }
}
