import Foundation

/// Detects emotional and communication style tones in text
final class ToneDetector {

    // MARK: - Singleton

    static let shared = ToneDetector()

    private init() {}

    // MARK: - API Configuration

    private let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions")!

    private let systemPrompt = """
        You are a tone analyzer. Analyze text and respond with ONLY valid JSON.
        No explanations, no markdown, just the JSON object.
        """

    private let analysisPromptTemplate = """
        Analyze this message's emotional tone and identify which specific words are emphasized.

        IMPORTANT: "emphasizedWords" should contain the exact words from the message that carry emotional weight or would be stressed when spoken. This varies by context:
        - "I can't believe YOU did that" → emphasize "you" (shock at the person)
        - "I CAN'T believe you did that" → emphasize "can't" (disbelief)
        - "I can't believe you did THAT" → emphasize "that" (shock at the action)

        Return ONLY this JSON (no other text):
        {"emotional":"happy|sad|angry|excited|anxious|neutral","emotionalConfidence":0.0-1.0,"style":"formal|casual|sarcastic|urgent|friendly","styleConfidence":0.0-1.0,"intensity":"low|medium|high","emphasizedWords":["word1","word2"]}

        Message: "{MESSAGE}"
        """

    // MARK: - Public API

    /// Detect tone using AI API (async)
    func detectTone(in text: String, apiKey: String) async throws -> ToneAnalysis {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .neutral
        }

        guard !apiKey.isEmpty else {
            return detectToneOffline(in: text)
        }

        var request = URLRequest(url: openAIURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10

        let prompt = analysisPromptTemplate.replacingOccurrences(of: "{MESSAGE}", with: text)

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 150
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ToneDetectorError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw ToneDetectorError.apiError(message)
            }
            throw ToneDetectorError.apiError("HTTP \(httpResponse.statusCode)")
        }

        return try parseAPIResponse(data)
    }

    /// Detect tone using AI API with completion handler (for keyboard extension)
    func detectTone(
        in text: String,
        apiKey: String,
        completion: @escaping (Result<ToneAnalysis, Error>) -> Void
    ) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.success(.neutral))
            return
        }

        guard !apiKey.isEmpty else {
            completion(.success(detectToneOffline(in: text)))
            return
        }

        Task {
            do {
                let result = try await detectTone(in: text, apiKey: apiKey)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    // Fallback to offline on error
                    completion(.success(self.detectToneOffline(in: text)))
                }
            }
        }
    }

    /// Detect tone offline using rule-based analysis (faster but less accurate)
    func detectToneOffline(in text: String) -> ToneAnalysis {
        let lower = text.lowercased()
        let isAllCaps = text == text.uppercased() && text.count > 5

        // Detect emotional tone
        var emotional: EmotionalTone = .neutral
        var emotionalConfidence: Double = 0.5
        var intensity: EmojiIntensity = .medium

        // Happy patterns
        let happyPatterns = ["happy", "glad", "excited", "great", "awesome", "wonderful",
                            "love", "yay", "woohoo", "fantastic", "amazing", "perfect"]
        if happyPatterns.contains(where: { lower.contains($0) }) {
            emotional = .happy
            emotionalConfidence = 0.7
        }

        // Sad patterns
        let sadPatterns = ["sad", "sorry", "unfortunately", "miss", "down", "depressed",
                         "disappointed", "heartbroken", "upset", "terrible"]
        if sadPatterns.contains(where: { lower.contains($0) }) {
            emotional = .sad
            emotionalConfidence = 0.7
        }

        // Angry patterns
        let angryPatterns = ["angry", "mad", "furious", "hate", "annoyed", "frustrated",
                           "stupid", "ridiculous", "unbelievable", "outraged"]
        if angryPatterns.contains(where: { lower.contains($0) }) || isAllCaps {
            emotional = .angry
            emotionalConfidence = isAllCaps ? 0.8 : 0.7
            intensity = isAllCaps ? .high : .medium
        }

        // Excited patterns
        let excitedPatterns = ["omg", "wow", "amazing", "incredible", "can't wait",
                              "so excited", "!!!"]
        if excitedPatterns.contains(where: { lower.contains($0) }) ||
           text.filter({ $0 == "!" }).count >= 3 {
            emotional = .excited
            emotionalConfidence = 0.8
            intensity = .high
        }

        // Anxious patterns
        let anxiousPatterns = ["worried", "nervous", "anxious", "scared", "afraid",
                              "unsure", "concerned", "stressed"]
        if anxiousPatterns.contains(where: { lower.contains($0) }) {
            emotional = .anxious
            emotionalConfidence = 0.7
        }

        // Detect style
        var style: StyleTone = .casual
        var styleConfidence: Double = 0.5

        // Formal patterns
        let formalPatterns = ["please find", "attached", "regards", "sincerely", "dear",
                            "per our", "as discussed", "kindly", "hereby"]
        if formalPatterns.contains(where: { lower.contains($0) }) {
            style = .formal
            styleConfidence = 0.8
        }

        // Urgent patterns
        let urgentPatterns = ["asap", "urgent", "immediately", "now", "hurry",
                            "deadline", "critical", "emergency"]
        if urgentPatterns.contains(where: { lower.contains($0) }) {
            style = .urgent
            styleConfidence = 0.8
        }

        // Sarcastic patterns (harder to detect)
        let sarcasticPatterns = ["oh great", "sure thing", "yeah right", "whatever",
                                "totally", "obviously"]
        if sarcasticPatterns.contains(where: { lower.contains($0) }) {
            style = .sarcastic
            styleConfidence = 0.6
        }

        return ToneAnalysis(
            emotional: emotional,
            emotionalConfidence: emotionalConfidence,
            style: style,
            styleConfidence: styleConfidence,
            intensity: intensity,
            emphasizedWords: [] // Offline detection can't determine emphasis
        )
    }

    // MARK: - Private Methods

    private func parseAPIResponse(_ data: Data) throws -> ToneAnalysis {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ToneDetectorError.parsingError
        }

        // Clean the content (remove any markdown formatting)
        let cleanContent = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let resultData = cleanContent.data(using: .utf8),
              let result = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
            throw ToneDetectorError.parsingError
        }

        // Parse with defaults
        let emotionalRaw = result["emotional"] as? String ?? "neutral"
        let emotional = EmotionalTone(rawValue: emotionalRaw) ?? .neutral

        let emotionalConfidence = result["emotionalConfidence"] as? Double ?? 0.5

        let styleRaw = result["style"] as? String ?? "casual"
        let style = StyleTone(rawValue: styleRaw) ?? .casual

        let styleConfidence = result["styleConfidence"] as? Double ?? 0.5

        let intensityRaw = result["intensity"] as? String ?? "medium"
        let intensity = EmojiIntensity(rawValue: intensityRaw) ?? .medium

        // Extract AI-determined emphasized words (not guessing from static list)
        let emphasizedWords = (result["emphasizedWords"] as? [String]) ?? []

        return ToneAnalysis(
            emotional: emotional,
            emotionalConfidence: min(1.0, max(0.0, emotionalConfidence)),
            style: style,
            styleConfidence: min(1.0, max(0.0, styleConfidence)),
            intensity: intensity,
            emphasizedWords: emphasizedWords
        )
    }
}

// MARK: - Errors

enum ToneDetectorError: LocalizedError {
    case invalidResponse
    case apiError(String)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingError:
            return "Failed to parse tone analysis"
        }
    }
}
