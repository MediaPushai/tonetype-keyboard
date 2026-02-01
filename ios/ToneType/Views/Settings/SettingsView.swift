import SwiftUI

/// Settings view for configuring ToneType
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAPIKeyInfo = false
    @State private var showingResetConfirmation = false
    @State private var apiKeyInput: String = ""

    var body: some View {
        NavigationView {
            Form {
                // API Configuration
                Section {
                    SecureField("API Key", text: $apiKeyInput)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .onChange(of: apiKeyInput) { newValue in
                            appState.apiKey = newValue
                        }

                    if !appState.apiKey.isEmpty {
                        HStack {
                            Image(systemName: appState.isValidAPIKey(appState.apiKey) ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(appState.isValidAPIKey(appState.apiKey) ? .green : .orange)
                            Text(appState.isValidAPIKey(appState.apiKey) ? "API key configured" : "API key format may be invalid")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: { showingAPIKeyInfo = true }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("How to get an API key")
                        }
                    }
                } header: {
                    Text("AI Configuration")
                } footer: {
                    Text("An OpenAI API key enables accurate AI-powered tone detection. Without it, basic offline detection is used.")
                }

                // Enhancement Options
                Section {
                    Toggle(isOn: $appState.enableEmojis) {
                        Label("Add Emojis", systemImage: "face.smiling")
                    }

                    Toggle(isOn: $appState.enableStyling) {
                        Label("Apply Text Styling", systemImage: "textformat")
                    }

                    Picker(selection: $appState.emojiIntensity) {
                        ForEach(EmojiIntensity.allCases) { intensity in
                            Text(intensity.displayName).tag(intensity)
                        }
                    } label: {
                        Label("Emoji Intensity", systemImage: "sparkles")
                    }
                } header: {
                    Text("Enhancement Options")
                }

                // Style Preview
                Section {
                    NavigationLink(destination: StylePreviewView()) {
                        Label("Preview Text Styles", systemImage: "eye")
                    }

                    NavigationLink(destination: ToneGuideView()) {
                        Label("Tone & Emoji Guide", systemImage: "book")
                    }
                } header: {
                    Text("Learn More")
                }

                // Keyboard Setup
                Section {
                    Button(action: openKeyboardSettings) {
                        HStack {
                            Label("Keyboard Settings", systemImage: "keyboard")
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: SetupHelpView()) {
                        Label("Setup Help", systemImage: "questionmark.circle")
                    }
                } header: {
                    Text("Keyboard")
                }

                // About & Reset
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Button(role: .destructive, action: { showingResetConfirmation = true }) {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                apiKeyInput = appState.apiKey
            }
            .sheet(isPresented: $showingAPIKeyInfo) {
                APIKeyInfoSheet()
            }
            .confirmationDialog(
                "Reset Settings?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    appState.resetToDefaults()
                    apiKeyInput = ""
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all settings to their default values. Your API key will also be removed.")
            }
        }
    }

    private func openKeyboardSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - API Key Info Sheet

struct APIKeyInfoSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Getting an OpenAI API Key")
                        .font(.title2)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 12) {
                        InfoStep(number: 1, text: "Go to platform.openai.com")
                        InfoStep(number: 2, text: "Sign up or log in to your account")
                        InfoStep(number: 3, text: "Navigate to API Keys section")
                        InfoStep(number: 4, text: "Click \"Create new secret key\"")
                        InfoStep(number: 5, text: "Copy the key and paste it in the app")
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pricing")
                            .font(.headline)

                        Text("OpenAI charges approximately $0.001 per message for tone detection. A typical user might spend $1-2 per month.")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy")
                            .font(.headline)

                        Text("Your messages are sent to OpenAI only when you tap the enhance button. We never store or log your messages.")
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                        HStack {
                            Text("Open OpenAI Platform")
                            Image(systemName: "arrow.up.forward")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("API Key Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct InfoStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor)
                .clipShape(Circle())

            Text(text)
        }
    }
}

// MARK: - Style Preview View

struct StylePreviewView: View {
    @State private var previewText = "Hello World"

    var body: some View {
        List {
            Section {
                TextField("Preview text", text: $previewText)
            }

            Section("Unicode Styles") {
                ForEach(UnicodeStyle.allCases) { style in
                    HStack {
                        Text(style.displayName)
                        Spacer()
                        Text(UnicodeConverter.shared.convert(previewText, to: style))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Style Preview")
    }
}

// MARK: - Tone Guide View

struct ToneGuideView: View {
    var body: some View {
        List {
            Section("Emotional Tones") {
                ForEach(EmotionalTone.allCases) { tone in
                    HStack {
                        Circle()
                            .fill(tone.color)
                            .frame(width: 12, height: 12)

                        Text(tone.displayName)

                        Spacer()

                        Text(tone.emojis.prefix(3).joined())
                    }
                }
            }

            Section("Communication Styles") {
                ForEach(StyleTone.allCases) { style in
                    HStack {
                        Text(style.displayName)
                        Spacer()
                        Text(style.emojis.prefix(2).joined())
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("How Tones Map to Styles") {
                VStack(alignment: .leading, spacing: 8) {
                    ToneStyleRow(tone: "Angry", style: "𝗕𝗼𝗹𝗱", example: "𝐓𝐡𝐢𝐬 𝐢𝐬 𝐮𝐧𝐚𝐜𝐜𝐞𝐩𝐭𝐚𝐛𝐥𝐞")
                    ToneStyleRow(tone: "Sad", style: "Small Caps", example: "ɪ ᴍɪꜱꜱ ʏᴏᴜ")
                    ToneStyleRow(tone: "Excited", style: "Bold Italic", example: "𝑻𝒉𝒊𝒔 𝒊𝒔 𝒂𝒎𝒂𝒛𝒊𝒏𝒈")
                    ToneStyleRow(tone: "Happy", style: "Normal", example: "Great news!")
                }
            }
        }
        .navigationTitle("Tone Guide")
    }
}

struct ToneStyleRow: View {
    let tone: String
    let style: String
    let example: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(tone)
                    .font(.caption)
                    .fontWeight(.medium)
                Text("→")
                    .foregroundColor(.secondary)
                Text(style)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(example)
                .font(.callout)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Setup Help View

struct SetupHelpView: View {
    var body: some View {
        List {
            Section("Enable the Keyboard") {
                SetupStep(number: 1, text: "Open the Settings app")
                SetupStep(number: 2, text: "Go to General → Keyboard → Keyboards")
                SetupStep(number: 3, text: "Tap \"Add New Keyboard...\"")
                SetupStep(number: 4, text: "Select \"ToneType\"")
            }

            Section("Enable Full Access") {
                SetupStep(number: 1, text: "In Keyboards list, tap \"ToneType\"")
                SetupStep(number: 2, text: "Toggle on \"Allow Full Access\"")
                SetupStep(number: 3, text: "Tap \"Allow\" on the confirmation")
            }

            Section("Using the Keyboard") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Open any app with a text field")
                    Text("2. Tap the globe 🌐 icon to switch to ToneType")
                    Text("3. Type your message")
                    Text("4. Tap ✨ to enhance")
                    Text("5. Tap ✓ to apply the enhancement")
                }
            }

            Section("Troubleshooting") {
                VStack(alignment: .leading, spacing: 12) {
                    TroubleshootItem(
                        problem: "Keyboard doesn't appear",
                        solution: "Make sure it's enabled in Settings and try restarting your device"
                    )
                    TroubleshootItem(
                        problem: "Enhancement not working",
                        solution: "Check that Full Access is enabled and you have an internet connection"
                    )
                    TroubleshootItem(
                        problem: "Offline mode only",
                        solution: "Add an API key in Settings for AI-powered detection"
                    )
                }
            }
        }
        .navigationTitle("Setup Help")
    }
}

struct TroubleshootItem: View {
    let problem: String
    let solution: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(problem)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(solution)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
