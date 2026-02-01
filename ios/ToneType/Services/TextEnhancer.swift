import Foundation

/// Main service that orchestrates tone detection and text enhancement
final class TextEnhancer {

    // MARK: - Singleton

    static let shared = TextEnhancer()

    private let toneDetector = ToneDetector.shared
    private let emojiMapper = EmojiMapper.shared
    private let unicodeConverter = UnicodeConverter.shared

    private init() {}

    // MARK: - Public API

    /// Enhance text with full AI-powered tone detection
    func enhance(
        _ text: String,
        apiKey: String,
        enableEmojis: Bool = true,
        enableStyling: Bool = true,
        emojiIntensity: EmojiIntensity = .medium
    ) async throws -> EnhancementResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return EnhancementResult(original: text, enhanced: text, tone: .neutral)
        }

        // Split into sentences
        let sentences = splitIntoSentences(text)

        // Detect overall tone (for consistent styling)
        let overallTone = try await toneDetector.detectTone(in: text, apiKey: apiKey)

        // Process each sentence
        var enhancedSentences: [String] = []

        for sentence in sentences {
            var enhanced = sentence

            // Apply styling only to AI-determined emphasized words (not guessing)
            if enableStyling && !overallTone.emphasizedWords.isEmpty {
                enhanced = unicodeConverter.convertEmphasizedWords(
                    sentence,
                    forTone: overallTone.emotional,
                    emphasizedWords: overallTone.emphasizedWords
                )
            }

            // Add emojis if enabled
            if enableEmojis && overallTone.emotional != .neutral {
                let emojis = emojiMapper.getEmojis(
                    emotional: overallTone.emotional,
                    style: overallTone.style,
                    intensity: emojiIntensity
                )
                enhanced += " " + emojis
            }

            enhancedSentences.append(enhanced)
        }

        let enhancedText = enhancedSentences.joined(separator: " ")

        return EnhancementResult(
            original: text,
            enhanced: enhancedText,
            tone: overallTone
        )
    }

    /// Enhance text with offline tone detection (faster, for real-time preview)
    /// Note: Offline mode cannot determine word emphasis without AI
    func enhanceOffline(
        _ text: String,
        enableEmojis: Bool = true,
        enableStyling: Bool = true,
        emojiIntensity: EmojiIntensity = .medium
    ) -> EnhancementResult {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return EnhancementResult(original: text, enhanced: text, tone: .neutral)
        }

        let sentences = splitIntoSentences(text)
        let overallTone = toneDetector.detectToneOffline(in: text)

        var enhancedSentences: [String] = []

        for sentence in sentences {
            var enhanced = sentence

            // Offline mode: can't determine emphasized words without AI
            // Only apply styling if we somehow have emphasized words
            if enableStyling && !overallTone.emphasizedWords.isEmpty {
                enhanced = unicodeConverter.convertEmphasizedWords(
                    sentence,
                    forTone: overallTone.emotional,
                    emphasizedWords: overallTone.emphasizedWords
                )
            }

            if enableEmojis && overallTone.emotional != .neutral {
                let emojis = emojiMapper.getEmojis(
                    emotional: overallTone.emotional,
                    style: overallTone.style,
                    intensity: emojiIntensity
                )
                enhanced += " " + emojis
            }

            enhancedSentences.append(enhanced)
        }

        let enhancedText = enhancedSentences.joined(separator: " ")

        return EnhancementResult(
            original: text,
            enhanced: enhancedText,
            tone: overallTone
        )
    }

    /// Enhance with completion handler (for keyboard extension compatibility)
    func enhance(
        _ text: String,
        apiKey: String,
        enableEmojis: Bool,
        enableStyling: Bool,
        emojiIntensity: EmojiIntensity,
        completion: @escaping (EnhancementResult) -> Void
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(EnhancementResult(original: text, enhanced: text, tone: .neutral))
            return
        }

        if apiKey.isEmpty {
            // Use offline enhancement
            let result = enhanceOffline(
                text,
                enableEmojis: enableEmojis,
                enableStyling: enableStyling,
                emojiIntensity: emojiIntensity
            )
            completion(result)
            return
        }

        Task {
            do {
                let result = try await enhance(
                    text,
                    apiKey: apiKey,
                    enableEmojis: enableEmojis,
                    enableStyling: enableStyling,
                    emojiIntensity: emojiIntensity
                )
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                // Fallback to offline on error
                let result = self.enhanceOffline(
                    text,
                    enableEmojis: enableEmojis,
                    enableStyling: enableStyling,
                    emojiIntensity: emojiIntensity
                )
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    // MARK: - Private Methods

    /// Split text into sentences
    private func splitIntoSentences(_ text: String) -> [String] {
        // Pattern matches sentences ending with . ! ? or text without those
        let pattern = "[^.!?]*[.!?]+(?:\\s|$)|[^.!?]+$"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [text]
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            let sentence = String(text[range]).trimmingCharacters(in: .whitespaces)
            return sentence.isEmpty ? nil : sentence
        }
    }
}
