import Foundation

/// Maps tones to appropriate emojis
final class EmojiMapper {

    // MARK: - Singleton

    static let shared = EmojiMapper()

    private init() {}

    // MARK: - Public API

    /// Get emojis for the given tones and intensity
    func getEmojis(
        emotional: EmotionalTone,
        style: StyleTone,
        intensity: EmojiIntensity
    ) -> String {
        let count = intensity.emojiCount

        // Get emotional emojis first (primary)
        var emojis = Array(emotional.emojis.prefix(count))

        // Add style emojis if we need more and style isn't formal
        if emojis.count < count && style != .formal {
            let styleEmojis = style.emojis
            let needed = count - emojis.count
            emojis.append(contentsOf: styleEmojis.prefix(needed))
        }

        return emojis.joined()
    }

    /// Get all available emojis for a tone (for customization UI)
    func getAvailableEmojis(for tone: EmotionalTone) -> [String] {
        tone.emojis
    }

    /// Get recommended emojis for a tone analysis
    func getRecommendedEmojis(for analysis: ToneAnalysis) -> String {
        getEmojis(
            emotional: analysis.emotional,
            style: analysis.style,
            intensity: analysis.intensity
        )
    }
}
