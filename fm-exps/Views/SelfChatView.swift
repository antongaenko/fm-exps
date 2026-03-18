import SwiftUI
import FoundationModels

struct SelfChatView: View {
    @State private var viewModel = SelfChatViewModel()
    @State private var topicDraft = ""
    @FocusState private var isTopicFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.turns.isEmpty && !viewModel.isRunning {
                    topicPickerView
                } else {
                    chatView
                }
            }
            .navigationTitle("AI Group Chat")
            .toolbar {
                if viewModel.isRunning || !viewModel.turns.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button(viewModel.isRunning ? "Stop" : "Restart",
                               systemImage: viewModel.isRunning ? "stop.circle" : "arrow.clockwise") {
                            viewModel.isRunning ? viewModel.stop() : viewModel.restart()
                        }
                        .tint(viewModel.isRunning ? .red : .accentColor)
                    }
                    if !viewModel.isRunning {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("New topic") {
                                viewModel.stop()
                                viewModel.turns = []
                                topicDraft = ""
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Topic picker

    private var topicPickerView: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .indigo, .teal],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("AI Group Debate")
                    .font(.title.bold())
                Text("Alice, Bob, Charlie & Diana discuss any topic.\nCharlie always asks Why?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: 12) {
                Text("Choose a topic").font(.headline)
                topicInputField
                suggestedTopics
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private var suggestedTopics: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["AI replaces doctors", "Remote work", "Space colonization",
                         "Universal income", "Social media"], id: \.self) { topic in
                    Button(topic) { topicDraft = topic; startChat() }
                        .buttonStyle(.bordered)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, -24)
    }

    // MARK: Chat view

    private var chatView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    topicHeader
                    ForEach(viewModel.turns) { turn in
                        // Skip empty turns — TypingIndicatorView covers that state
                        if !turn.content.isEmpty {
                            BubbleView(turn: turn)
                                .id(turn.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(
                                        scale: 0.92,
                                        anchor: turn.participant.isLeading ? .bottomLeading : .bottomTrailing
                                    )),
                                    removal: .opacity
                                ))
                        }
                    }
                    if let typing = viewModel.typingParticipant,
                       viewModel.turns.last?.content.isEmpty == true {
                        TypingIndicatorView(participant: typing)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .onChange(of: viewModel.turns.count)         { scrollToBottom(proxy: proxy) }
            .onChange(of: viewModel.turns.last?.content) { scrollToBottom(proxy: proxy) }
            .onChange(of: viewModel.typingParticipant)   { scrollToBottom(proxy: proxy) }
        }
    }

    private var topicHeader: some View {
        Text("Topic: \(viewModel.topic)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(.regularMaterial)
            .clipShape(Capsule())
    }

    private var topicInputField: some View {
        HStack(spacing: 10) {
            TextField("e.g. Should AI replace doctors?", text: $topicDraft)
                .focused($isTopicFocused)
                .submitLabel(.go)
                .onSubmit(startChat)
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .padding(.trailing, 4)

            Button(action: startChat) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        topicDraft.trimmingCharacters(in: .whitespaces).isEmpty
                        ? AnyShapeStyle(.tertiary)
                        : AnyShapeStyle(Color.accentColor)
                    )
            }
            .disabled(topicDraft.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.trailing, 8)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isTopicFocused
                    ? AnyShapeStyle(Color.accentColor.opacity(0.6))
                    : AnyShapeStyle(Color.primary.opacity(0.1)),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(isTopicFocused ? 0.08 : 0.04), radius: isTopicFocused ? 12 : 6, y: 3)
        .animation(.easeInOut(duration: 0.2), value: isTopicFocused)
    }

    private func startChat() {
        isTopicFocused = false
        viewModel.start(topic: topicDraft)
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// MARK: - Bubble

struct BubbleView: View {
    let turn: ChatTurn

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if turn.participant.isLeading {
                avatar
                bubbleText
                Spacer(minLength: 56)
            } else {
                Spacer(minLength: 56)
                bubbleText
                avatar
            }
        }
    }

    private var avatar: some View {
        Text(turn.participant.name.prefix(1))
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(turn.participant.color)
            .clipShape(Circle())
    }

    private var bubbleText: some View {
        VStack(alignment: turn.participant.isLeading ? .leading : .trailing, spacing: 3) {
            Text(turn.participant.name)
                .font(.caption2.bold())
                .foregroundStyle(turn.participant.color)
            Text(turn.content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    turn.participant.isLeading
                    ? Color.secondary.opacity(0.1)
                    : turn.participant.color.opacity(0.15)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Typing indicator

struct TypingIndicatorView: View {
    let participant: Participant
    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if participant.isLeading {
                avatarView; dotsView; Spacer(minLength: 56)
            } else {
                Spacer(minLength: 56); dotsView; avatarView
            }
        }
    }

    private var avatarView: some View {
        Text(participant.name.prefix(1))
            .font(.caption.bold())
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(participant.color)
            .clipShape(Circle())
    }

    private var dotsView: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(participant.color.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animating ? 1.2 : 0.6)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .delay(Double(i) * 0.15)
                            .repeatForever(autoreverses: true),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { animating = false; Task { @MainActor in animating = true } }
        .onDisappear { animating = false }
    }
}

// MARK: - Preview

#Preview("Group Chat") { SelfChatView() }

#Preview("Bubbles") {
    VStack(spacing: 10) {
        BubbleView(turn: ChatTurn(participant: .alice,
            content: "I think decentralised AI will democratise healthcare completely.", isComplete: true))
        BubbleView(turn: ChatTurn(participant: .bob,
            content: "Alice, democratise for whom exactly? 60% of rural areas still lack broadband.", isComplete: true))
        BubbleView(turn: ChatTurn(participant: .charlie,
            content: "Why would broadband solve the diagnostic accuracy problem?", isComplete: true))
        BubbleView(turn: ChatTurn(participant: .diana,
            content: "Studies show 73% accuracy improvement in early detection — but Bob is right that access is the bottleneck.", isComplete: true))
        TypingIndicatorView(participant: .alice)
    }
    .padding()
}
