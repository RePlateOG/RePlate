//
//  MessagesView.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @State private var selectedConversation: Conversation?

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header matching other tabs
            messagesHeader

            // Content
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.conversations.isEmpty {
                    emptyView
                } else {
                    conversationsList
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Theme.Colors.pageBackground)
        .task {
            // Pre-populate synchronously from MockData, then do async refresh
            if viewModel.conversations.isEmpty {
                viewModel.conversations = MockData.sampleConversations
            }
            await viewModel.loadConversations()
        }
        .refreshable {
            await viewModel.loadConversations()
        }
        .sheet(item: $selectedConversation) { conversation in
            ConversationView(conversation: conversation)
        }
    }

    // MARK: - Gradient Header (matches OrdersView style)
    private var messagesHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Messages")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(
                        viewModel.conversations.isEmpty
                            ? "No conversations yet"
                            : "\(viewModel.conversations.count) conversation\(viewModel.conversations.count == 1 ? "" : "s")"
                    )
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                let unread = viewModel.conversations.filter { $0.unreadCount > 0 }.count
                if unread > 0 {
                    ZStack {
                        Circle()
                            .fill(Theme.Colors.accent)
                            .frame(width: 44, height: 44)
                        Text("\(unread)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 20)
        .background(Theme.Colors.primaryGradient)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 40, bottomTrailingRadius: 40))
    }

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonView()
                        .frame(height: 80)
                        .padding(.horizontal, Theme.Spacing.lg)
                }
            }
            .padding(.vertical, Theme.Spacing.md)
        }
    }

    private var emptyView: some View {
        EmptyStateView(
            icon: "message",
            title: "No Messages",
            message: "Your conversations with restaurants will appear here"
        )
    }

    private var conversationsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: []) {
                ForEach(viewModel.conversations) { conversation in
                    Button {
                        selectedConversation = conversation
                        hapticFeedback(.light)
                    } label: {
                        ConversationRow(conversation: conversation)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if conversation.id != viewModel.conversations.last?.id {
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation

    private var initials: String {
        let name = conversation.order?.restaurant?.name ?? "?"
        return String(name.prefix(1)).uppercased()
    }

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Circular gradient avatar with first-letter initials
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .frame(width: 50, height: 50)
                Text(initials)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let restaurant = conversation.order?.restaurant {
                        Text(restaurant.name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.Colors.label)
                    }

                    Spacer()

                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                    }
                }

                HStack {
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage.content)
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .lineLimit(1)
                    }

                    Spacer()

                    if conversation.unreadCount > 0 {
                        // Small filled green dot for unread count
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.primaryGradient)
                                .frame(width: 22, height: 22)
                            Text("\(conversation.unreadCount)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }
}

// MARK: - Conversation View
struct ConversationView: View {
    @Environment(\.dismiss) var dismiss
    let conversation: Conversation
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var showOrderInfo = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        if messages.isEmpty {
                            Text("No messages yet")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Colors.secondaryLabel)
                                .frame(maxWidth: .infinity)
                                .padding(.top, Theme.Spacing.xxl)
                        } else {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                    }
                    .padding(Theme.Spacing.md)
                }
                .background(Theme.Colors.pageBackground)

                // Input Bar
                messageInputBar
            }
            .background(Theme.Colors.pageBackground)
            .navigationTitle(conversation.order?.restaurant?.name ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOrderInfo) { OrderInfoSheet(order: conversation.order) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hapticFeedback(.light)
                        showOrderInfo = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(Theme.Colors.primaryGradientStart)
                    }
                }
            }
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: Theme.Spacing.sm) {
            TextField("Type a message...", text: $messageText)
                .font(Theme.Typography.body)
                .padding(Theme.Spacing.md)
                .background(Color(.systemGray6))
                .cornerRadius(Theme.CornerRadius.xl)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.Colors.primaryGradient)
            }
            .disabled(messageText.isEmpty)
            .opacity(messageText.isEmpty ? 0.5 : 1)
        }
        .padding(Theme.Spacing.md)
        .background(Color(.systemBackground))
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = Message(
            id: UUID().uuidString,
            orderId: conversation.orderId,
            senderId: "currentUser",
            receiverId: "restaurant",
            content: messageText,
            timestamp: Date(),
            read: false,
            messageType: .text
        )
        withAnimation { messages.append(newMessage) }
        hapticFeedback(.light)
        messageText = ""
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    private var isFromCurrentUser: Bool { message.senderId == "currentUser" }

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer()
            }

            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(Theme.Typography.body)
                    .foregroundColor(isFromCurrentUser ? .white : Theme.Colors.label)
                    .padding(Theme.Spacing.md)
                    .background(
                        isFromCurrentUser ?
                        AnyShapeStyle(Theme.Colors.primaryGradient) :
                        AnyShapeStyle(Theme.Colors.secondaryBackground)
                    )
                    .cornerRadius(Theme.CornerRadius.xl)

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(Theme.Typography.caption2)
                    .foregroundColor(Theme.Colors.tertiaryLabel)
            }
            .frame(maxWidth: 280, alignment: isFromCurrentUser ? .trailing : .leading)

            if !isFromCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Order Info Sheet
private struct OrderInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let order: Order?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if let order {
                        infoRow(icon: "number.circle.fill", label: "Pickup Code", value: order.pickupCode)
                        infoRow(icon: "bag.fill", label: "Item", value: order.listing?.title ?? "Surplus Order")
                        infoRow(icon: "person.fill", label: "Customer", value: order.customer?.name ?? "Customer")
                        infoRow(icon: "dollarsign.circle.fill", label: "Total", value: String(format: "$%.2f", order.totalAmount))
                        infoRow(icon: "clock.fill", label: "Pickup Window",
                                value: "\(order.pickupWindowStart.formatted(date: .omitted, time: .shortened)) – \(order.pickupWindowEnd.formatted(date: .omitted, time: .shortened))")
                        infoRow(icon: "checkmark.circle.fill", label: "Status", value: order.status.rawValue)
                        infoRow(icon: "calendar", label: "Ordered At", value: order.createdAt.formatted(date: .abbreviated, time: .shortened))
                    } else {
                        Text("No order information available.")
                            .foregroundColor(Theme.Colors.secondaryLabel)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                }
                .padding(24)
            }
            .background(Theme.Colors.pageBackground)
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.Colors.primaryGradientStart)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.Colors.tertiaryLabel).tracking(0.5)
                Text(value).font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.Colors.label)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
