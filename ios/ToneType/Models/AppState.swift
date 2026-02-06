import Foundation
import SwiftUI
import Combine

/// Shared app state that persists across the app and keyboard extension
final class AppState: ObservableObject {

    // MARK: - Shared UserDefaults (App Group)

    private let defaults: UserDefaults
    private static let suiteName = "group.com.tonetype.keyboard"

    // MARK: - Keychain

    private let keychain = KeychainHelper.shared

    // MARK: - Published Properties

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published var apiKey: String {
        didSet { keychain.set(apiKey, forKey: Keys.apiKey) }
    }

    @Published var enableEmojis: Bool {
        didSet { defaults.set(enableEmojis, forKey: Keys.enableEmojis) }
    }

    @Published var enableStyling: Bool {
        didSet { defaults.set(enableStyling, forKey: Keys.enableStyling) }
    }

    @Published var emojiIntensity: EmojiIntensity {
        didSet { defaults.set(emojiIntensity.rawValue, forKey: Keys.emojiIntensity) }
    }

    @Published var isKeyboardEnabled: Bool = false
    @Published var hasFullAccess: Bool = false

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let apiKey = "apiKey"
        static let enableEmojis = "enableEmojis"
        static let enableStyling = "enableStyling"
        static let emojiIntensity = "emojiIntensity"
        static let apiKeyMigrated = "apiKeyMigratedToKeychain"
    }

    // MARK: - Initialization

    init() {
        // Use App Group shared defaults, fallback to standard if not available
        self.defaults = UserDefaults(suiteName: Self.suiteName) ?? .standard

        // Migrate API key from UserDefaults to Keychain on first launch after update
        migrateAPIKeyToKeychain()

        // Load persisted values
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.hasCompletedOnboarding)
        self.apiKey = keychain.get(forKey: Keys.apiKey) ?? ""
        self.enableEmojis = defaults.object(forKey: Keys.enableEmojis) as? Bool ?? true
        self.enableStyling = defaults.object(forKey: Keys.enableStyling) as? Bool ?? true

        let intensityRaw = defaults.string(forKey: Keys.emojiIntensity) ?? "medium"
        self.emojiIntensity = EmojiIntensity(rawValue: intensityRaw) ?? .medium

        // Check keyboard status on init
        checkKeyboardStatus()
    }

    // MARK: - Migration

    /// Moves the API key from UserDefaults to Keychain exactly once.
    /// After migration, the key is deleted from UserDefaults so it no longer
    /// sits in an unencrypted plist on disk.
    private func migrateAPIKeyToKeychain() {
        guard !defaults.bool(forKey: Keys.apiKeyMigrated) else { return }

        if let existingKey = defaults.string(forKey: Keys.apiKey), !existingKey.isEmpty {
            keychain.set(existingKey, forKey: Keys.apiKey)
            defaults.removeObject(forKey: Keys.apiKey)
        }

        defaults.set(true, forKey: Keys.apiKeyMigrated)
    }

    // MARK: - Methods

    /// Check if the keyboard extension is enabled
    func checkKeyboardStatus() {
        // Note: There's no reliable API to check this in iOS
        // We can only guide users through the setup
        // This is a placeholder that could be enhanced with various heuristics

        // For now, we assume it's enabled after onboarding
        isKeyboardEnabled = hasCompletedOnboarding
    }

    /// Reset all settings to defaults
    func resetToDefaults() {
        enableEmojis = true
        enableStyling = true
        emojiIntensity = .medium
        apiKey = ""
        keychain.delete(forKey: Keys.apiKey)
    }

    /// Validate API key format (basic check)
    func isValidAPIKey(_ key: String) -> Bool {
        // OpenAI keys start with "sk-" and are typically 51 characters
        return key.hasPrefix("sk-") && key.count >= 40
    }
}

// MARK: - Emoji Intensity

enum EmojiIntensity: String, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Subtle (1 emoji)"
        case .medium: return "Normal (2 emojis)"
        case .high: return "Expressive (3 emojis)"
        }
    }

    var emojiCount: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        }
    }
}
