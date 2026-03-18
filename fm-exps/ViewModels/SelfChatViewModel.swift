import FoundationModels
import SwiftUI

@Observable
final class SelfChatViewModel {
    var turns: [ChatTurn] = []
    var typingParticipant: Participant? = nil
    var topic: String = ""
    var isRunning = false

    private let turnOrder: [Participant] = [.alice, .bob, .charlie, .diana]
    private let maxRounds = 4          // rounds after greeting
    private var sessions: [Participant: LanguageModelSession] = [:]
    private var chatTask: Task<Void, Never>?

    // MARK: Public API

    func start(topic: String) {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        self.topic = trimmed
        turns = []
        isRunning = true

        sessions = Dictionary(uniqueKeysWithValues: Participant.allCases.map { p in
            (p, LanguageModelSession(model: SystemLanguageModel.default,
                                     instructions: p.systemInstructions))
        })

        chatTask = Task { await self.runConversation() }
    }

    func stop() {
        chatTask?.cancel()
        chatTask = nil
        isRunning = false
        typingParticipant = nil
    }

    func restart() {
        stop()
        let saved = topic
        turns = []
        start(topic: saved)
    }

    // MARK: Conversation loop

    private func runConversation() async {
        // 1. Greeting round — each participant introduces themselves
        for participant in turnOrder {
            guard !Task.isCancelled else { return }
            let greetingPrompt = """
            The group is about to debate: "\(topic)".
            Greet the others briefly and share your opening stance in one sentence. \
            Stay strictly in character. 15–30 words.
            """
            await speak(participant, prompt: greetingPrompt)
            try? await Task.sleep(for: .milliseconds(400))
        }

        // 2. Debate rounds
        for _ in 0..<maxRounds {
            for participant in turnOrder {
                guard !Task.isCancelled else { return }

                // Context: topic + last message from a different participant
                let lastOther = turns.last(where: { $0.participant != participant && $0.isComplete })
                let context: String
                if let prev = lastOther {
                    context = "\(prev.participant.name) just said: \"\(prev.content)\""
                } else {
                    context = "The topic is \(topic). Start the debate."
                }

                let prompt: String
                if participant == .charlie {
                    prompt = """
                    \(context)
                    Ask "Why [specific claim]?" — one short sentence, 5–15 words only.
                    """
                } else {
                    prompt = """
                    Topic: \(topic)
                    \(context)
                    Respond in character. Reference the speaker by name. 15–50 words strictly.
                    """
                }

                await speak(participant, prompt: prompt)
                try? await Task.sleep(for: .milliseconds(400))
            }
        }

        isRunning = false
        typingParticipant = nil
    }

    private func speak(_ participant: Participant, prompt: String) async {
        typingParticipant = participant
        let idx = appendTurn(for: participant)
        guard let session = sessions[participant] else { return }

        do {
            let stream = session.streamResponse(to: prompt, generating: ChatReply.self)
            for try await partial in stream {
                if let text = partial.content.content {
                    withAnimation(.easeIn(duration: 0.15)) {
                        turns[idx].content = text
                    }
                }
            }
            turns[idx].isComplete = true
        } catch {
            turns[idx].content = "…"
            turns[idx].isComplete = true
        }
        typingParticipant = nil
    }

    private func appendTurn(for participant: Participant) -> Int {
        turns.append(ChatTurn(participant: participant))
        return turns.count - 1
    }
}
