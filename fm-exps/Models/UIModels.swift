import FoundationModels

/// A fully generated screen layout produced by the on-device Foundation Model.
@Generable
struct GeneratedScreen {
    @Guide(description: "A concise, descriptive title for the screen")
    var title: String

    @Guide(description: "An optional one-line subtitle or purpose description")
    var subtitle: String?

    @Guide(description: "The UI rows to display from top to bottom", .maximumCount(12))
    var rows: [UIRow]
}

/// A single UI element in the generated screen.
@Generable
struct UIRow {
    @Guide(description: "The type of UI control or display element")
    var kind: UIRowKind

    @Guide(description: "The main label or title text for this element")
    var label: String

    @Guide(description: "Secondary text, hint, or placeholder value")
    var detail: String?

    @Guide(description: "An SF Symbol name for an accompanying icon, e.g. 'person.fill'")
    var iconName: String?

    @Guide(description: "The visual style or semantic role of this element")
    var style: UIRowStyle?

    @Generable
    enum UIRowKind {
        case heading
        case subheading
        case body
        case button
        case textField
        case toggle
        case slider
        case divider
        case infoCard
        case badge
    }

    @Generable
    enum UIRowStyle {
        case primary
        case secondary
        case destructive
        case success
        case warning
        case muted
    }
}
