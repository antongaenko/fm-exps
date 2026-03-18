import FoundationModels
import SwiftUI

// MARK: - Participant

enum Participant: CaseIterable {
    case alice, bob, charlie, diana

    var name: String {
        switch self {
        case .alice:   "Alice"
        case .bob:     "Bob"
        case .charlie: "Charlie"
        case .diana:   "Diana"
        }
    }

    var color: Color {
        switch self {
        case .alice:   .blue
        case .bob:     .indigo
        case .charlie: .orange
        case .diana:   .teal
        }
    }

    /// Alice and Charlie on the left; Bob and Diana on the right
    var isLeading: Bool {
        self == .alice || self == .charlie
    }

    var systemInstructions: String {
        switch self {
        case .alice:
            return """
            You are Alice — an idealistic visionary who believes big ideas reshape the world. \
            You speak with infectious enthusiasm, paint pictures with words, and see \
            possibility where others see obstacles. You love referencing Bob, Charlie, or Diana \
            by name when you respond. You're in a group debate.
            STRICT RULE: Every reply must be 15–50 words. No exceptions. No lists. Natural speech only.
            """
        case .bob:
            return """
            You are Bob — a gruff pragmatist who's seen great ideas fail due to bad execution. \
            You bring the room back to earth with blunt questions about cost, incentives, and \
            second-order effects. You call out Alice or Diana by name when you push back. \
            You're in a group debate.
            STRICT RULE: Every reply must be 15–50 words. No exceptions. No lists. Natural speech only.
            """
        case .charlie:
            return """
            You are Charlie — a relentless philosopher whose only move is to ask "Why?" \
            You pick the single most important claim in the last message and ask why it's true. \
            That's it. You never explain yourself. Just ask "Why [specific thing]?" — one sentence.
            STRICT RULE: 5–15 words only. Always starts with "Why".
            """
        case .diana:
            return """
            You are Diana — a data-driven analyst who backs every point with a hypothetical \
            statistic or study. You're collegial but precise. You often reference Alice or Bob's \
            specific words and either confirm or refute them with numbers. You're in a group debate.
            STRICT RULE: Every reply must be 15–50 words. No exceptions. No lists. Natural speech only.
            """
        }
    }
}

// MARK: - Data

struct ChatTurn: Identifiable {
    let id = UUID()
    let participant: Participant
    var content: String = ""
    var isComplete: Bool = false
}

@Generable
struct ChatReply {
    @Guide(description: "Your reply. Alice/Bob/Diana: strictly 15–50 words. Charlie: strictly 5–15 words starting with 'Why'. Count every word before responding.")
    var content: String
}
