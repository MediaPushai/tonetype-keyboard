import Foundation
import SwiftUI

// MARK: - Emotional Tone

enum EmotionalTone: String, CaseIterable, Identifiable {
    case happy
    case sad
    case angry
    case excited
    case anxious
    case neutral

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .happy: return .orange
        case .sad: return .blue
        case .angry: return .red
        case .excited: return .purple
        case .anxious: return .gray
        case .neutral: return .primary
        }
    }

    var emojis: [String] {
        switch self {
        case .happy: return ["😊", "🎉", "✨", "😄", "🌟", "💫"]
        case .sad: return ["😢", "💔", "😔", "🥺", "😞", "💙"]
        case .angry: return ["😤", "🔥", "😡", "💢", "😠", "⚡"]
        case .excited: return ["🚀", "⚡", "🎊", "🙌", "💥", "🎯"]
        case .anxious: return ["😰", "😬", "💭", "😟", "🫤", "😣"]
        case .neutral: return []
        }
    }

    var unicodeStyle: UnicodeStyle {
        switch self {
        case .happy: return .normal
        case .sad: return .smallCaps
        case .angry: return .bold
        case .excited: return .boldItalic
        case .anxious: return .normal
        case .neutral: return .normal
        }
    }
}

// MARK: - Style Tone

enum StyleTone: String, CaseIterable, Identifiable {
    case formal
    case casual
    case sarcastic
    case urgent
    case friendly

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var emojis: [String] {
        switch self {
        case .formal: return ["📋", "✉️", "📝"]
        case .casual: return ["👋", "😄", "🙂"]
        case .sarcastic: return ["😏", "🙄", "💅", "🤷"]
        case .urgent: return ["⚠️", "❗", "🚨", "⏰"]
        case .friendly: return ["💕", "🤗", "😊", "💫"]
        }
    }
}

// MARK: - Unicode Style

enum UnicodeStyle: String, CaseIterable, Identifiable {
    case normal
    case bold
    case italic
    case boldItalic
    case smallCaps

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .boldItalic: return "Bold Italic"
        case .smallCaps: return "Small Caps"
        }
    }

    var example: String {
        UnicodeConverter.shared.convert("Hello", to: self)
    }
}

// MARK: - Tone Analysis Result

struct ToneAnalysis: Equatable {
    let emotional: EmotionalTone
    let emotionalConfidence: Double
    let style: StyleTone
    let styleConfidence: Double
    let intensity: EmojiIntensity
    /// Words that carry emotional emphasis - determined by AI analysis, not static guessing
    let emphasizedWords: [String]

    static let neutral = ToneAnalysis(
        emotional: .neutral,
        emotionalConfidence: 1.0,
        style: .casual,
        styleConfidence: 1.0,
        intensity: .medium,
        emphasizedWords: []
    )
}

// MARK: - Enhancement Result

struct EnhancementResult: Equatable {
    let original: String
    let enhanced: String
    let tone: ToneAnalysis

    var toneName: String {
        tone.emotional.displayName
    }

    var toneColor: Color {
        tone.emotional.color
    }
}
