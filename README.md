# fm-exps — Foundation Models Experiments

A pair of quick iOS/macOS concept experiments built after Apple's **"Enhance your apps with Foundation Models and AI frameworks"** session, using the on-device `FoundationModels` framework.

## TL;DR
<table>                                                                                                                                               
    <tr> 
      <td>
        <video src="https://github.com/user-attachments/assets/4d6a2b7a-15b4-44ae-980e-9376b632d70a" controls width="600"></video>    
      </td>
      <td>
        <video src="https://github.com/user-attachments/assets/848e3f6c-1f2b-4a82-979d-8f3602e886d6" controls width="600"></video>    
      </td>
    </tr>
</table>

## Concepts

### AI Group Chat
Four AI personas — Alice, Bob, Charlie, and Diana — debate any topic you choose, each running in their own `LanguageModelSession` with distinct character instructions. Responses stream in real time via `streamResponse(to:generating:)`.

- Alice: idealistic visionary
- Bob: gruff pragmatist
- Charlie: relentless philosopher who only asks "Why?"
- Diana: data-driven analyst

### UI Builder
Describe a screen in plain text and the on-device model generates a live SwiftUI interface from your description using structured output (`@Generable`). It just shows the concept and supports only a few fields.

## Requirements

- Xcode 26+
- iOS 26+ / macOS 26+
- Device with Apple Intelligence (on-device model)

## License

MIT — see [LICENSE.txt](LICENSE.txt)

---

*Built with [Claude Code](https://claude.ai/claude-code) (claude-opus-4-6)*
