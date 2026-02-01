import SwiftUI

/// Main onboarding view with paged steps
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0

    private let totalPages = 4

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.accentColor.opacity(0.1), Color.accentColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    HowItWorksPage()
                        .tag(1)

                    EnableKeyboardPage()
                        .tag(2)

                    SetupCompletePage()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom navigation
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .buttonStyle(.bordered)
                        }

                        Spacer()

                        if currentPage < totalPages - 1 {
                            Button("Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Get Started") {
                                completeOnboarding()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        withAnimation {
            appState.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Welcome Page

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 120, height: 120)

                Text("✨")
                    .font(.system(size: 60))
            }

            VStack(spacing: 12) {
                Text("Welcome to ToneType")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Express yourself better with tone-aware text enhancement")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Example preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Before:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("I'm so excited about this!")
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)

                Text("After:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("𝑰'𝒎 𝒔𝒐 𝒆𝒙𝒄𝒊𝒕𝒆𝒅 𝒂𝒃𝒐𝒖𝒕 𝒕𝒉𝒊𝒔! 🚀⚡")
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

// MARK: - How It Works Page

struct HowItWorksPage: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("How It Works")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 24) {
                FeatureRow(
                    icon: "keyboard",
                    title: "Type Your Message",
                    description: "Use the ToneType keyboard in any app"
                )

                FeatureRow(
                    icon: "sparkles",
                    title: "Tap Enhance",
                    description: "AI detects the tone of your message"
                )

                FeatureRow(
                    icon: "text.badge.star",
                    title: "See the Magic",
                    description: "Text styling and emojis are added automatically"
                )

                FeatureRow(
                    icon: "paperplane.fill",
                    title: "Send with Style",
                    description: "Your enhanced message is ready to go"
                )
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Enable Keyboard Page

struct EnableKeyboardPage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "keyboard.badge.ellipsis")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("Enable the Keyboard")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Follow these steps to enable ToneType:")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 16) {
                SetupStep(number: 1, text: "Open Settings app")
                SetupStep(number: 2, text: "Go to General → Keyboard → Keyboards")
                SetupStep(number: 3, text: "Tap \"Add New Keyboard...\"")
                SetupStep(number: 4, text: "Select \"ToneType\"")
                SetupStep(number: 5, text: "Tap ToneType → Enable \"Allow Full Access\"")
            }
            .padding(.horizontal, 24)

            // Open Settings button
            Button(action: openSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("Open Settings")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 24)

            Spacer()

            Text("Full Access is required for AI-powered tone detection")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
        }
        .padding()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct SetupStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Setup Complete Page

struct SetupCompletePage: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Start typing with ToneType to enhance your messages")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                // Tone examples
                ToneExampleRow(tone: .happy, example: "Great news!", enhanced: "Great news! 😊🎉")
                ToneExampleRow(tone: .angry, example: "This is unacceptable!", enhanced: "𝐓𝐡𝐢𝐬 𝐢𝐬 𝐮𝐧𝐚𝐜𝐜𝐞𝐩𝐭𝐚𝐛𝐥𝐞! 😤🔥")
                ToneExampleRow(tone: .excited, example: "Can't wait!", enhanced: "𝑪𝒂𝒏'𝒕 𝒘𝒂𝒊𝒕! 🚀⚡")
                ToneExampleRow(tone: .sad, example: "I miss you", enhanced: "ɪ ᴍɪꜱꜱ ʏᴏᴜ 😢💔")
            }
            .padding(.horizontal, 24)

            Spacer()

            Text("Tip: Switch keyboards by tapping 🌐 on your keyboard")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct ToneExampleRow: View {
    let tone: EmotionalTone
    let example: String
    let enhanced: String

    var body: some View {
        HStack {
            Text(tone.displayName)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tone.color)
                .cornerRadius(8)

            Spacer()

            Text(enhanced)
                .font(.callout)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
