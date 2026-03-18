import SwiftUI

struct UIGeneratorView: View {
    @State private var generator = UIGeneratorViewModel()
    @State private var prompt = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        NavigationStack {
            phaseView
                .navigationTitle("UI Builder")
                .toolbar {
                    if case .showing = generator.phase {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("New") { generator.reset() }
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var phaseView: some View {
        switch generator.phase {
        case .idle:
            idleView
        case .generating:
            generatingView
        case .showing(let screen):
            GeneratedScreenView(screen: screen)
        case .error(let message):
            errorView(message: message)
        }
    }

    // MARK: - Idle

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)
                Text("Describe your interface")
                    .font(.title2.bold())
                Text("Type what screen you want — the model builds it instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer()
            promptInputField
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
        }
    }

    // MARK: - Prompt input

    private var promptInputField: some View {
        HStack(spacing: 10) {
            TextField("e.g. settings screen with notifications...", text: $prompt, axis: .vertical)
                .lineLimit(1...4)
                .focused($isFieldFocused)
                .submitLabel(.send)
                .onSubmit(submit)
                .padding(.vertical, 12)
                .padding(.leading, 16)
                .padding(.trailing, 4)

            Button(action: submit) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        prompt.trimmingCharacters(in: .whitespaces).isEmpty
                        ? AnyShapeStyle(.tertiary)
                        : AnyShapeStyle(Color.accentColor)
                    )
            }
            .disabled(prompt.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.trailing, 8)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isFieldFocused
                    ? AnyShapeStyle(Color.accentColor.opacity(0.6))
                    : AnyShapeStyle(Color.primary.opacity(0.1)),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(isFieldFocused ? 0.08 : 0.04), radius: isFieldFocused ? 12 : 6, y: 3)
        .animation(.easeInOut(duration: 0.2), value: isFieldFocused)
    }

    // MARK: - Generating

    private var generatingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Building your UI…")
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try again") { generator.reset() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Actions

    private func submit() {
        isFieldFocused = false
        generator.generate(from: prompt)
        prompt = ""
    }
}

// MARK: - Generated screen renderer

struct GeneratedScreenView: View {
    let screen: GeneratedScreen

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                screenHeader
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                ForEach(screen.rows.indices, id: \.self) { index in
                    UIRowView(row: screen.rows[index])
                }
            }
            .padding(.bottom, 32)
        }
    }

    private var screenHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(screen.title)
                .font(.largeTitle.bold())
            if let subtitle = screen.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Component renderer

struct UIRowView: View {
    let row: UIRow
    @State private var toggleValue = false
    @State private var sliderValue = 0.5
    @State private var textValue = ""

    var body: some View {
        Group {
            if row.kind == .divider {
                Divider()
                    .padding(.horizontal)
                    .padding(.vertical, 6)
            } else {
                contentView
                    .padding(.horizontal)
                    .padding(.vertical, 5)
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch row.kind {
        case .heading:      headingView
        case .subheading:   subheadingView
        case .body:         bodyView
        case .button:       buttonView
        case .textField:    textFieldView
        case .toggle:       toggleView
        case .slider:       sliderView
        case .infoCard:     infoCardView
        case .badge:        badgeView
        case .divider:      EmptyView()
        }
    }

    private var headingView: some View {
        HStack(spacing: 8) {
            if let icon = row.iconName {
                Image(systemName: icon).foregroundStyle(Color.accentColor)
            }
            Text(row.label).font(.title2.bold())
        }
        .padding(.top, 8)
    }

    private var subheadingView: some View {
        Text(row.label).font(.headline).foregroundStyle(.secondary)
    }

    private var bodyView: some View {
        HStack(alignment: .top, spacing: 12) {
            if let icon = row.iconName {
                Image(systemName: icon).foregroundStyle(.secondary).frame(width: 20)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(row.label)
                if let detail = row.detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    private var buttonView: some View {
        Button(action: {}) {
            HStack {
                if let icon = row.iconName { Image(systemName: icon) }
                Text(row.label)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(row.style == .destructive ? .red : .accentColor)
    }

    private var textFieldView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if let icon = row.iconName {
                    Image(systemName: icon).foregroundStyle(.secondary).imageScale(.small)
                }
                Text(row.label).font(.caption).foregroundStyle(.secondary)
            }
            TextField(row.detail ?? row.label, text: $textValue)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var toggleView: some View {
        Toggle(isOn: $toggleValue) {
            HStack(spacing: 10) {
                if let icon = row.iconName {
                    Image(systemName: icon).foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(row.label)
                    if let detail = row.detail {
                        Text(detail).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var sliderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if let icon = row.iconName {
                    Image(systemName: icon).foregroundStyle(.secondary)
                }
                Text(row.label)
            }
            Slider(value: $sliderValue)
            if let detail = row.detail {
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var infoCardView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let icon = row.iconName {
                    Image(systemName: icon).foregroundStyle(Color.accentColor)
                }
                Text(row.label).fontWeight(.medium)
            }
            if let detail = row.detail {
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var badgeView: some View {
        HStack(spacing: 8) {
            Text(row.label)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(badgeColor.opacity(0.15))
                .foregroundStyle(badgeColor)
                .clipShape(Capsule())
            if let detail = row.detail {
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var badgeColor: Color {
        switch row.style {
        case .destructive: .red
        case .success:     .green
        case .warning:     .orange
        case .primary:     .accentColor
        case .secondary:   .blue
        case .muted, nil:  .secondary
        }
    }
}

// MARK: - Previews

#Preview("UI Generator") {
    UIGeneratorView()
}

#Preview("Generated Screen") {
    GeneratedScreenView(screen: GeneratedScreen(
        title: "New Account",
        subtitle: "Fill in your details to get started",
        rows: [
            UIRow(kind: .textField, label: "Full name", detail: "Jane Doe", iconName: "person"),
            UIRow(kind: .textField, label: "Email", detail: "you@example.com", iconName: "envelope"),
            UIRow(kind: .divider, label: ""),
            UIRow(kind: .toggle, label: "Agree to Terms", detail: "Required to continue", iconName: "doc.text"),
            UIRow(kind: .divider, label: ""),
            UIRow(kind: .button, label: "Create account", iconName: "person.badge.plus", style: .primary),
        ]
    ))
}
