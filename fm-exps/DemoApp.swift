import SwiftUI
import FoundationModels

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            switch SystemLanguageModel.default.availability {
                case .available:
                    TabView {
                        SelfChatView()
                            .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
                        UIGeneratorView()
                            .tabItem { Label("UI Builder", systemImage: "rectangle.3.group") }
                    }
                case .unavailable(let unavailableReason):
                    UnavailableView(reason: unavailableReason)
            }
        }
    }
}
