import Foundation

/// Text enhancer optimized for keyboard extension use
/// Self-contained to avoid dependency issues with main app
final class KeyboardTextEnhancer {

    // MARK: - Types

    struct EnhancementResult {
        let original: String
        let enhanced: String
        let toneName: String
    }

    private enum EmotionalTone: String {
        case happy, sad, angry, excited, anxious, neutral

        var emojis: [String] {
            switch self {
            case .happy: return ["😊", "🎉", "✨"]
            case .sad: return ["😢", "💔", "😔"]
            case .angry: return ["😤", "🔥", "😡"]
            case .excited: return ["🚀", "⚡", "🎊"]
            case .anxious: return ["😰", "😬", "💭"]
            case .neutral: return []
            }
        }
    }

    private enum StyleTone: String {
        case formal, casual, sarcastic, urgent, friendly
    }

    // MARK: - Properties

    private var settings: KeyboardSettings = KeyboardSettings()
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Unicode character maps
    private var boldMap: [Character: Character] = [:]
    private var italicMap: [Character: Character] = [:]
    private var boldItalicMap: [Character: Character] = [:]
    private var smallCapsMap: [Character: Character] = [:]

    // MARK: - Initialization

    init() {
        buildCharacterMaps()
    }

    // MARK: - Configuration

    func configure(with settings: KeyboardSettings) {
        self.settings = settings
    }

    /// Result of tone detection including AI-determined emphasized words
    private struct ToneResult {
        let tone: EmotionalTone
        let emphasizedWords: [String]
    }

    // MARK: - Public API

    /// Enhance text with AI (async with callback)
    func enhance(_ text: String, completion: @escaping (EnhancementResult) -> Void) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(EnhancementResult(original: text, enhanced: text, toneName: "neutral"))
            return
        }

        // If no API key, use offline (no emphasis styling without AI)
        guard !settings.apiKey.isEmpty else {
            completion(enhanceOffline(text))
            return
        }

        // Make API request - returns tone AND emphasized words
        detectToneWithAPI(text) { [weak self] result in
            guard let self = self else { return }

            let enhanced = self.applyEnhancement(
                to: text,
                tone: result.tone,
                emphasizedWords: result.emphasizedWords
            )
            completion(EnhancementResult(
                original: text,
                enhanced: enhanced,
                toneName: result.tone.rawValue
            ))
        }
    }

    /// Enhance text offline (synchronous, faster)
    /// Note: Offline mode cannot determine word emphasis without AI
    func enhanceOffline(_ text: String) -> EnhancementResult {
        let tone = detectToneOffline(text)
        // Offline: no emphasized words available
        let enhanced = applyEnhancement(to: text, tone: tone, emphasizedWords: [])

        return EnhancementResult(
            original: text,
            enhanced: enhanced,
            toneName: tone.rawValue
        )
    }

    // MARK: - Private: Enhancement

    private func applyEnhancement(to text: String, tone: EmotionalTone, emphasizedWords: [String]) -> String {
        let sentences = splitIntoSentences(text)
        var enhancedSentences: [String] = []

        for sentence in sentences {
            var enhanced = sentence

            // Apply styling only to AI-determined emphasized words (not guessing)
            if settings.enableStyling && !emphasizedWords.isEmpty {
                enhanced = styleEmphasizedWords(sentence, tone: tone, emphasizedWords: emphasizedWords)
            }

            // Add emojis
            if settings.enableEmojis && tone != .neutral {
                let emojis = getEmojis(for: tone)
                enhanced += " " + emojis
            }

            enhancedSentences.append(enhanced)
        }

        return enhancedSentences.joined(separator: " ")
    }

    private func splitIntoSentences(_ text: String) -> [String] {
        let pattern = "[^.!?]*[.!?]+(?:\\s|$)|[^.!?]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [text]
        }

        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)

        return matches.compactMap { match -> String? in
            guard let range = Range(match.range, in: text) else { return nil }
            let sentence = String(text[range]).trimmingCharacters(in: .whitespaces)
            return sentence.isEmpty ? nil : sentence
        }
    }

    private func getEmojis(for tone: EmotionalTone) -> String {
        let count: Int
        switch settings.emojiIntensity {
        case "low": count = 1
        case "high": count = 3
        default: count = 2
        }

        return tone.emojis.prefix(count).joined()
    }

    // MARK: - Private: Unicode Conversion

    private func buildCharacterMaps() {
        // Bold (Mathematical Bold)
        for i in 0..<26 {
            if let upper = UnicodeScalar(65 + i),
               let lower = UnicodeScalar(97 + i),
               let boldUpper = UnicodeScalar(0x1D400 + i),
               let boldLower = UnicodeScalar(0x1D41A + i) {
                boldMap[Character(upper)] = Character(boldUpper)
                boldMap[Character(lower)] = Character(boldLower)
            }
        }

        // Bold digits
        for i in 0..<10 {
            if let digit = UnicodeScalar(48 + i),
               let boldDigit = UnicodeScalar(0x1D7CE + i) {
                boldMap[Character(digit)] = Character(boldDigit)
            }
        }

        // Italic (Mathematical Italic)
        for i in 0..<26 {
            if let upper = UnicodeScalar(65 + i),
               let lower = UnicodeScalar(97 + i),
               let italicUpper = UnicodeScalar(0x1D434 + i),
               let italicLower = UnicodeScalar(0x1D44E + i) {
                italicMap[Character(upper)] = Character(italicUpper)
                italicMap[Character(lower)] = Character(italicLower)
            }
        }

        // Bold Italic (Mathematical Bold Italic)
        for i in 0..<26 {
            if let upper = UnicodeScalar(65 + i),
               let lower = UnicodeScalar(97 + i),
               let biUpper = UnicodeScalar(0x1D468 + i),
               let biLower = UnicodeScalar(0x1D482 + i) {
                boldItalicMap[Character(upper)] = Character(biUpper)
                boldItalicMap[Character(lower)] = Character(biLower)
            }
        }

        // Small Caps
        let smallCapsChars = Array("ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ")
        for i in 0..<26 {
            if let lower = UnicodeScalar(97 + i),
               let upper = UnicodeScalar(65 + i) {
                smallCapsMap[Character(lower)] = smallCapsChars[i]
                smallCapsMap[Character(upper)] = smallCapsChars[i]
            }
        }
    }

    /// Style only AI-determined emphasized words (not guessing from static keywords)
    private func styleEmphasizedWords(_ text: String, tone: EmotionalTone, emphasizedWords: [String]) -> String {
        let map: [Character: Character]

        switch tone {
        case .angry:
            map = boldMap
        case .sad:
            map = smallCapsMap
        case .excited:
            map = boldItalicMap
        case .anxious:
            map = italicMap
        default:
            return text
        }

        guard !emphasizedWords.isEmpty else { return text }

        var result = text

        // Sort by length (longest first) to avoid partial replacements
        let sortedWords = emphasizedWords.sorted { $0.count > $1.count }

        for word in sortedWords {
            // Case-insensitive word boundary match
            let pattern = "\\b(\(NSRegularExpression.escapedPattern(for: word)))\\b"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
                continue
            }

            let range = NSRange(result.startIndex..., in: result)
            let matches = regex.matches(in: result, options: [], range: range)

            // Process matches in reverse order to preserve indices
            for match in matches.reversed() {
                guard let matchRange = Range(match.range, in: result) else { continue }
                let matchedText = String(result[matchRange])
                let styledText = String(matchedText.map { map[$0] ?? $0 })
                result.replaceSubrange(matchRange, with: styledText)
            }
        }

        return result
    }

    // MARK: - Private: Tone Detection

    private func detectToneOffline(_ text: String) -> EmotionalTone {
        let lower = text.lowercased()
        let isAllCaps = text == text.uppercased() && text.count > 5

        // Happy
        if ["happy", "glad", "great", "awesome", "love", "wonderful", "amazing"]
            .contains(where: { lower.contains($0) }) {
            return .happy
        }

        // Sad
        if ["sad", "sorry", "miss", "unfortunately", "disappointed", "upset"]
            .contains(where: { lower.contains($0) }) {
            return .sad
        }

        // Angry
        if ["angry", "mad", "hate", "furious", "annoyed", "frustrated"]
            .contains(where: { lower.contains($0) }) || isAllCaps {
            return .angry
        }

        // Excited
        if ["omg", "wow", "amazing", "incredible", "can't wait", "excited"]
            .contains(where: { lower.contains($0) }) || text.contains("!!!") {
            return .excited
        }

        // Anxious
        if ["worried", "nervous", "anxious", "scared", "afraid", "stressed"]
            .contains(where: { lower.contains($0) }) {
            return .anxious
        }

        return .neutral
    }

    private func detectToneWithAPI(_ text: String, completion: @escaping (ToneResult) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 8

        let prompt = """
            Analyze this message's emotional tone and identify which specific words are emphasized.

            IMPORTANT: "emphasizedWords" should contain the exact words from the message that carry emotional weight or would be stressed when spoken. This varies by context:
            - "I can't believe YOU did that" → emphasize "you" (shock at the person)
            - "I CAN'T believe you did that" → emphasize "can't" (disbelief)
            - "I can't believe you did THAT" → emphasize "that" (shock at the action)

            Return ONLY valid JSON:
            {"tone":"happy|sad|angry|excited|anxious|neutral","emphasizedWords":["word1","word2"]}

            Message: "\(text)"
            """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are a tone analyzer. Respond ONLY with valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 100
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }

            // Fallback to offline on any error
            guard error == nil,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                DispatchQueue.main.async {
                    completion(ToneResult(tone: self.detectToneOffline(text), emphasizedWords: []))
                }
                return
            }

            // Parse JSON response
            let cleanContent = content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let resultData = cleanContent.data(using: .utf8),
                  let result = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
                DispatchQueue.main.async {
                    completion(ToneResult(tone: self.detectToneOffline(text), emphasizedWords: []))
                }
                return
            }

            let toneStr = (result["tone"] as? String)?.lowercased() ?? "neutral"
            let tone = EmotionalTone(rawValue: toneStr) ?? self.detectToneOffline(text)
            let emphasizedWords = (result["emphasizedWords"] as? [String]) ?? []

            DispatchQueue.main.async {
                completion(ToneResult(tone: tone, emphasizedWords: emphasizedWords))
            }
        }.resume()
    }
}
