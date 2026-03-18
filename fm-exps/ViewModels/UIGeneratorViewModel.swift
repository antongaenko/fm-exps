import FoundationModels
import Observation

@Observable
final class UIGeneratorViewModel {
    enum Phase {
        case idle
        case generating
        case showing(GeneratedScreen)
        case error(String)
    }

    var phase: Phase = .idle

    func generate(from prompt: String) {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard case .idle = phase else { return }
        Task { await _generate(from: trimmed) }
    }

    func reset() {
        phase = .idle
    }

    private func _generate(from prompt: String) async {
        phase = .generating

        let session = LanguageModelSession(
            model: SystemLanguageModel.default,
            instructions: """
            You generate SwiftUI interface layouts from natural language descriptions.
            When the user describes a screen, form, or feature, produce a GeneratedScreen
            with appropriate UIRow elements using clear, concise labels.
            Include relevant SF Symbol names in iconName where meaningful.
            """
        )

        do {
            let response = try await session.respond(
                to: "Create a UI layout for: \(prompt)",
                generating: GeneratedScreen.self
            )
            phase = .showing(response.content)
        } catch let error as LanguageModelSession.GenerationError {
            switch error {
            case .guardrailViolation:
                phase = .error("The request was blocked by content guidelines.")
            default:
                phase = .error(error.localizedDescription)
            }
        } catch {
            phase = .error(error.localizedDescription)
        }
    }
}
