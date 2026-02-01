import Foundation

/// Converts regular text to styled Unicode characters
/// These special characters display as bold, italic, etc. in any text field
final class UnicodeConverter {

    // MARK: - Singleton

    static let shared = UnicodeConverter()

    private init() {
        buildCharacterMaps()
    }

    // MARK: - Character Maps

    private var boldMap: [Character: Character] = [:]
    private var italicMap: [Character: Character] = [:]
    private var boldItalicMap: [Character: Character] = [:]
    private var smallCapsMap: [Character: Character] = [:]

    private func buildCharacterMaps() {
        // Build bold map (Mathematical Bold: U+1D400 - U+1D433)
        for i in 0..<26 {
            let upper = Character(UnicodeScalar(65 + i)!) // A-Z
            let lower = Character(UnicodeScalar(97 + i)!) // a-z

            if let boldUpper = UnicodeScalar(0x1D400 + i),
               let boldLower = UnicodeScalar(0x1D41A + i) {
                boldMap[upper] = Character(boldUpper)
                boldMap[lower] = Character(boldLower)
            }
        }

        // Bold digits
        for i in 0..<10 {
            let digit = Character(UnicodeScalar(48 + i)!) // 0-9
            if let boldDigit = UnicodeScalar(0x1D7CE + i) {
                boldMap[digit] = Character(boldDigit)
            }
        }

        // Build italic map (Mathematical Italic: U+1D434 - U+1D467)
        for i in 0..<26 {
            let upper = Character(UnicodeScalar(65 + i)!)
            let lower = Character(UnicodeScalar(97 + i)!)

            if let italicUpper = UnicodeScalar(0x1D434 + i),
               let italicLower = UnicodeScalar(0x1D44E + i) {
                italicMap[upper] = Character(italicUpper)
                italicMap[lower] = Character(italicLower)
            }
        }
        // Special case: 'h' uses Planck constant
        if let planckH = UnicodeScalar(0x210E) {
            italicMap["h"] = Character(planckH)
        }

        // Build bold italic map (Mathematical Bold Italic: U+1D468 - U+1D49B)
        for i in 0..<26 {
            let upper = Character(UnicodeScalar(65 + i)!)
            let lower = Character(UnicodeScalar(97 + i)!)

            if let biUpper = UnicodeScalar(0x1D468 + i),
               let biLower = UnicodeScalar(0x1D482 + i) {
                boldItalicMap[upper] = Character(biUpper)
                boldItalicMap[lower] = Character(biLower)
            }
        }

        // Build small caps map (various Unicode blocks)
        let smallCapsChars: [Character] = Array("ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ")
        for i in 0..<26 {
            let lower = Character(UnicodeScalar(97 + i)!)
            let upper = Character(UnicodeScalar(65 + i)!)
            smallCapsMap[lower] = smallCapsChars[i]
            smallCapsMap[upper] = smallCapsChars[i]
        }
    }

    // MARK: - Public API

    /// Convert text to the specified Unicode style
    func convert(_ text: String, to style: UnicodeStyle) -> String {
        guard style != .normal else { return text }

        let map: [Character: Character]
        switch style {
        case .normal:
            return text
        case .bold:
            map = boldMap
        case .italic:
            map = italicMap
        case .boldItalic:
            map = boldItalicMap
        case .smallCaps:
            map = smallCapsMap
        }

        return String(text.map { map[$0] ?? $0 })
    }

    /// Convert text based on emotional tone
    func convert(_ text: String, forTone tone: EmotionalTone) -> String {
        convert(text, to: tone.unicodeStyle)
    }

    /// Preview all styles for a piece of text
    func previewAllStyles(_ text: String) -> [UnicodeStyle: String] {
        Dictionary(uniqueKeysWithValues: UnicodeStyle.allCases.map { style in
            (style, convert(text, to: style))
        })
    }

    /// Check if text contains styled Unicode characters
    func containsStyledUnicode(_ text: String) -> Bool {
        let pattern = "[\\u{1D400}-\\u{1D7FF}]|[ᴀ-ᴢ]"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    /// Strip Unicode styling and return plain text
    func stripStyling(_ text: String) -> String {
        // Create reverse maps
        var reverseMap: [Character: Character] = [:]

        for (plain, styled) in boldMap {
            reverseMap[styled] = plain
        }
        for (plain, styled) in italicMap {
            reverseMap[styled] = plain
        }
        for (plain, styled) in boldItalicMap {
            reverseMap[styled] = plain
        }
        for (plain, styled) in smallCapsMap {
            reverseMap[styled] = plain
        }

        return String(text.map { reverseMap[$0] ?? $0 })
    }

    // MARK: - AI-Determined Emphasis Styling

    /// Convert only AI-determined emphasized words (not guessing from static keywords)
    /// - Parameters:
    ///   - text: The text to process
    ///   - tone: The detected emotional tone (determines the style)
    ///   - emphasizedWords: Specific words to style (from AI analysis)
    /// - Returns: Text with only the emphasized words styled
    func convertEmphasizedWords(_ text: String, forTone tone: EmotionalTone, emphasizedWords: [String]) -> String {
        let style = tone.unicodeStyle
        guard style != .normal else { return text }
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
                let styledText = convert(matchedText, to: style)
                result.replaceSubrange(matchRange, with: styledText)
            }
        }

        return result
    }

    /// @deprecated Use convertEmphasizedWords with AI-determined words instead
    /// This function used static keyword guessing which was inaccurate
    func convertKeywords(_ text: String, forTone tone: EmotionalTone) -> String {
        // Without AI analysis, we can't know which words are emphasized
        // Return unstyled text - better than guessing wrong
        return text
    }
}
