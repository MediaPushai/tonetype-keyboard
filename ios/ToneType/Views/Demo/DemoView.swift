import SwiftUI

/// Interactive demo view to try out tone detection and enhancement
struct DemoView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DemoViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Input section
                    InputSection(viewModel: viewModel)

                    // Enhance button
                    EnhanceButton(viewModel: viewModel, appState: appState)

                    // Results section
                    if viewModel.hasResult {
                        ResultsSection(viewModel: viewModel)
                    }

                    // Quick examples
                    QuickExamplesSection(viewModel: viewModel)

                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Try It Out")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEnhancing {
                        ProgressView()
                    }
                }
            }
        }
    }
}

// MARK: - View Model

@MainActor
final class DemoViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var enhancedResult: EnhancementResult?
    @Published var isEnhancing: Bool = false
    @Published var errorMessage: String?

    private let enhancer = TextEnhancer.shared

    var hasResult: Bool {
        enhancedResult != nil
    }

    func enhance(with appState: AppState) {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to enhance"
            return
        }

        isEnhancing = true
        errorMessage = nil

        Task {
            do {
                let result = try await enhancer.enhance(
                    inputText,
                    apiKey: appState.apiKey,
                    enableEmojis: appState.enableEmojis,
                    enableStyling: appState.enableStyling,
                    emojiIntensity: appState.emojiIntensity
                )

                await MainActor.run {
                    self.enhancedResult = result
                    self.isEnhancing = false
                }
            } catch {
                await MainActor.run {
                    // Fallback to offline
                    self.enhancedResult = self.enhancer.enhanceOffline(
                        self.inputText,
                        enableEmojis: appState.enableEmojis,
                        enableStyling: appState.enableStyling,
                        emojiIntensity: appState.emojiIntensity
                    )
                    self.isEnhancing = false
                }
            }
        }
    }

    func enhanceOffline(with appState: AppState) {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to enhance"
            return
        }

        enhancedResult = enhancer.enhanceOffline(
            inputText,
            enableEmojis: appState.enableEmojis,
            enableStyling: appState.enableStyling,
            emojiIntensity: appState.emojiIntensity
        )
    }

    func setExample(_ text: String) {
        inputText = text
        enhancedResult = nil
    }

    func copyToClipboard() {
        guard let result = enhancedResult else { return }
        UIPasteboard.general.string = result.enhanced
    }

    func clear() {
        inputText = ""
        enhancedResult = nil
        errorMessage = nil
    }
}

// MARK: - Input Section

struct InputSection: View {
    @ObservedObject var viewModel: DemoViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Message")
                    .font(.headline)

                Spacer()

                if !viewModel.inputText.isEmpty {
                    Button("Clear") {
                        viewModel.clear()
                    }
                    .font(.caption)
                }
            }

            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 100, maxHeight: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Enhance Button

struct EnhanceButton: View {
    @ObservedObject var viewModel: DemoViewModel
    let appState: AppState

    var body: some View {
        Button(action: { viewModel.enhance(with: appState) }) {
            HStack {
                if viewModel.isEnhancing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.isEnhancing ? "Analyzing..." : "Enhance")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isEnhancing || viewModel.inputText.isEmpty)
        .opacity(viewModel.inputText.isEmpty ? 0.6 : 1.0)
    }
}

// MARK: - Results Section

struct ResultsSection: View {
    @ObservedObject var viewModel: DemoViewModel
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tone badge
            if let result = viewModel.enhancedResult {
                HStack {
                    Text("Detected Tone:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(result.tone.emotional.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(result.tone.emotional.color)
                        .cornerRadius(12)

                    if result.tone.style != .casual {
                        Text(result.tone.style.displayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Enhanced text
            VStack(alignment: .leading, spacing: 8) {
                Text("Enhanced Message")
                    .font(.headline)

                if let result = viewModel.enhancedResult {
                    Text(result.enhanced)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }

            // Copy button
            Button(action: {
                viewModel.copyToClipboard()
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    copied = false
                }
            }) {
                HStack {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    Text(copied ? "Copied!" : "Copy to Clipboard")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Quick Examples

struct QuickExamplesSection: View {
    @ObservedObject var viewModel: DemoViewModel

    private let examples = [
        ("😊 Happy", "I'm so happy to hear from you!"),
        ("😢 Sad", "I really miss the good old days."),
        ("😤 Angry", "I can't believe this happened again!"),
        ("🚀 Excited", "OMG this is going to be amazing!!!"),
        ("😰 Anxious", "I'm a bit worried about tomorrow."),
        ("📋 Formal", "Please find attached the quarterly report.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Examples")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(examples, id: \.0) { example in
                    Button(action: { viewModel.setExample(example.1) }) {
                        Text(example.0)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    DemoView()
        .environmentObject(AppState())
}
