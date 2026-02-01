package com.tonetype.keyboard

import android.content.Context
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit

/**
 * Service for tone detection and message enhancement
 */
class ToneService(private val context: Context) {

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    private val gson = Gson()

    data class EnhancedResult(
        val text: String,
        val tone: String,
        val emojis: List<String>
    )

    suspend fun enhanceMessage(
        text: String,
        apiKey: String?,
        enableEmojis: Boolean,
        enableStyling: Boolean,
        emojiIntensity: EmojiIntensity
    ): EnhancedResult = withContext(Dispatchers.IO) {
        if (apiKey.isNullOrBlank()) {
            // Offline enhancement
            return@withContext enhanceOffline(text, enableEmojis, enableStyling, emojiIntensity)
        }

        try {
            enhanceWithAI(text, apiKey, enableEmojis, enableStyling, emojiIntensity)
        } catch (e: Exception) {
            // Fallback to offline
            enhanceOffline(text, enableEmojis, enableStyling, emojiIntensity)
        }
    }

    private suspend fun enhanceWithAI(
        text: String,
        apiKey: String,
        enableEmojis: Boolean,
        enableStyling: Boolean,
        emojiIntensity: EmojiIntensity
    ): EnhancedResult = withContext(Dispatchers.IO) {
        val prompt = buildPrompt(text, enableEmojis, enableStyling, emojiIntensity)

        val requestBody = OpenAIRequest(
            model = "gpt-4o-mini",
            messages = listOf(
                Message("system", "You are a tone detection assistant. Analyze the emotional tone of messages and enhance them with appropriate emojis and styling. Respond with JSON only."),
                Message("user", prompt)
            ),
            temperature = 0.7
        )

        val request = Request.Builder()
            .url("https://api.openai.com/v1/chat/completions")
            .addHeader("Authorization", "Bearer $apiKey")
            .addHeader("Content-Type", "application/json")
            .post(gson.toJson(requestBody).toRequestBody("application/json".toMediaType()))
            .build()

        val response = client.newCall(request).execute()
        val responseBody = response.body?.string() ?: throw Exception("Empty response")

        if (!response.isSuccessful) {
            throw Exception("API error: ${response.code}")
        }

        val openAIResponse = gson.fromJson(responseBody, OpenAIResponse::class.java)
        val content = openAIResponse.choices.firstOrNull()?.message?.content
            ?: throw Exception("No content in response")

        // Parse the JSON response
        val result = gson.fromJson(content, AIEnhancementResponse::class.java)

        var enhancedText = text

        // Apply styling to emphasized words
        if (enableStyling && result.emphasizedWords.isNotEmpty()) {
            enhancedText = applyStyleToWords(enhancedText, result.emphasizedWords, result.tone)
        }

        // Add emojis
        if (enableEmojis && result.emojis.isNotEmpty()) {
            val emojiCount = when (emojiIntensity) {
                EmojiIntensity.LOW -> 1
                EmojiIntensity.MEDIUM -> 2
                EmojiIntensity.HIGH -> 3
            }
            val emojisToAdd = result.emojis.take(emojiCount).joinToString("")
            enhancedText = "$enhancedText $emojisToAdd"
        }

        EnhancedResult(
            text = enhancedText,
            tone = result.tone,
            emojis = result.emojis
        )
    }

    private fun buildPrompt(
        text: String,
        enableEmojis: Boolean,
        enableStyling: Boolean,
        emojiIntensity: EmojiIntensity
    ): String {
        return """
Analyze the emotional tone of this message and provide enhancement suggestions.

Message: "$text"

Respond with JSON in this exact format:
{
  "tone": "happy|sad|angry|excited|sarcastic|urgent|formal|casual",
  "confidence": 0.0-1.0,
  "emojis": ["emoji1", "emoji2", "emoji3"],
  "emphasizedWords": ["word1", "word2"]
}

For emphasizedWords, identify which specific words in the message carry the most emotional weight based on context. These are the words that would be stressed if spoken aloud.

For emojis, suggest ${when(emojiIntensity) {
            EmojiIntensity.LOW -> "1-2"
            EmojiIntensity.MEDIUM -> "2-3"
            EmojiIntensity.HIGH -> "3-5"
        }} emojis that match the detected tone.
        """.trimIndent()
    }

    private fun enhanceOffline(
        text: String,
        enableEmojis: Boolean,
        enableStyling: Boolean,
        emojiIntensity: EmojiIntensity
    ): EnhancedResult {
        // Simple offline tone detection based on keywords and punctuation
        val tone = detectToneOffline(text)
        val emojis = getEmojisForTone(tone)

        var enhancedText = text

        if (enableEmojis) {
            val emojiCount = when (emojiIntensity) {
                EmojiIntensity.LOW -> 1
                EmojiIntensity.MEDIUM -> 2
                EmojiIntensity.HIGH -> 3
            }
            enhancedText = "$enhancedText ${emojis.take(emojiCount).joinToString("")}"
        }

        return EnhancedResult(
            text = enhancedText,
            tone = tone,
            emojis = emojis
        )
    }

    private fun detectToneOffline(text: String): String {
        val lowercaseText = text.lowercase()

        return when {
            // Angry indicators
            lowercaseText.contains("angry") || lowercaseText.contains("furious") ||
            lowercaseText.contains("hate") || text.contains("!!!") -> "angry"

            // Sad indicators
            lowercaseText.contains("sad") || lowercaseText.contains("miss") ||
            lowercaseText.contains("sorry") || lowercaseText.contains("unfortunately") -> "sad"

            // Excited indicators
            lowercaseText.contains("excited") || lowercaseText.contains("amazing") ||
            lowercaseText.contains("awesome") || text.count { it == '!' } >= 2 -> "excited"

            // Happy indicators
            lowercaseText.contains("happy") || lowercaseText.contains("great") ||
            lowercaseText.contains("love") || lowercaseText.contains("wonderful") -> "happy"

            // Urgent indicators
            lowercaseText.contains("urgent") || lowercaseText.contains("asap") ||
            lowercaseText.contains("immediately") || lowercaseText.contains("now") -> "urgent"

            // Sarcastic indicators (harder to detect offline)
            lowercaseText.contains("oh great") || lowercaseText.contains("sure") ||
            lowercaseText.contains("right") && lowercaseText.contains("...") -> "sarcastic"

            // Default to casual
            else -> "casual"
        }
    }

    private fun getEmojisForTone(tone: String): List<String> {
        return when (tone) {
            "happy" -> listOf("😊", "🎉", "✨", "💫", "😄")
            "sad" -> listOf("😢", "💔", "😔", "🥺", "😿")
            "angry" -> listOf("😤", "🔥", "😡", "💢", "👊")
            "excited" -> listOf("🚀", "⚡", "🎊", "🤩", "🎉")
            "sarcastic" -> listOf("😏", "🙄", "💅", "😒", "🤷")
            "urgent" -> listOf("⚠️", "❗", "🚨", "⏰", "📢")
            "formal" -> listOf("📝", "✉️", "📋")
            "casual" -> listOf("👋", "😄", "👍", "🙂")
            else -> listOf("✨")
        }
    }

    private fun applyStyleToWords(text: String, words: List<String>, tone: String): String {
        var result = text
        for (word in words) {
            val styledWord = convertToUnicode(word, tone)
            result = result.replace(word, styledWord, ignoreCase = true)
        }
        return result
    }

    private fun convertToUnicode(text: String, tone: String): String {
        // Unicode mathematical bold characters
        val boldMap = mapOf(
            'a' to '𝗮', 'b' to '𝗯', 'c' to '𝗰', 'd' to '𝗱', 'e' to '𝗲',
            'f' to '𝗳', 'g' to '𝗴', 'h' to '𝗵', 'i' to '𝗶', 'j' to '𝗷',
            'k' to '𝗸', 'l' to '𝗹', 'm' to '𝗺', 'n' to '𝗻', 'o' to '𝗼',
            'p' to '𝗽', 'q' to '𝗾', 'r' to '𝗿', 's' to '𝘀', 't' to '𝘁',
            'u' to '𝘂', 'v' to '𝘃', 'w' to '𝘄', 'x' to '𝘅', 'y' to '𝘆', 'z' to '𝘇',
            'A' to '𝗔', 'B' to '𝗕', 'C' to '𝗖', 'D' to '𝗗', 'E' to '𝗘',
            'F' to '𝗙', 'G' to '𝗚', 'H' to '𝗛', 'I' to '𝗜', 'J' to '𝗝',
            'K' to '𝗞', 'L' to '𝗟', 'M' to '𝗠', 'N' to '𝗡', 'O' to '𝗢',
            'P' to '𝗣', 'Q' to '𝗤', 'R' to '𝗥', 'S' to '𝗦', 'T' to '𝗧',
            'U' to '𝗨', 'V' to '𝗩', 'W' to '𝗪', 'X' to '𝗫', 'Y' to '𝗬', 'Z' to '𝗭'
        )

        val italicMap = mapOf(
            'a' to '𝘢', 'b' to '𝘣', 'c' to '𝘤', 'd' to '𝘥', 'e' to '𝘦',
            'f' to '𝘧', 'g' to '𝘨', 'h' to '𝘩', 'i' to '𝘪', 'j' to '𝘫',
            'k' to '𝘬', 'l' to '𝘭', 'm' to '𝘮', 'n' to '𝘯', 'o' to '𝘰',
            'p' to '𝘱', 'q' to '𝘲', 'r' to '𝘳', 's' to '𝘴', 't' to '𝘵',
            'u' to '𝘶', 'v' to '𝘷', 'w' to '𝘸', 'x' to '𝘹', 'y' to '𝘺', 'z' to '𝘻',
            'A' to '𝘈', 'B' to '𝘉', 'C' to '𝘊', 'D' to '𝘋', 'E' to '𝘌',
            'F' to '𝘍', 'G' to '𝘎', 'H' to '𝘏', 'I' to '𝘐', 'J' to '𝘑',
            'K' to '𝘒', 'L' to '𝘓', 'M' to '𝘔', 'N' to '𝘕', 'O' to '𝘖',
            'P' to '𝘗', 'Q' to '𝘘', 'R' to '𝘙', 'S' to '𝘚', 'T' to '𝘛',
            'U' to '𝘜', 'V' to '𝘝', 'W' to '𝘞', 'X' to '𝘟', 'Y' to '𝘠', 'Z' to '𝘡'
        )

        val styleMap = when (tone) {
            "angry", "urgent" -> boldMap
            "sarcastic" -> italicMap
            "excited" -> boldMap
            else -> boldMap
        }

        return text.map { char -> styleMap[char] ?: char }.joinToString("")
    }

    // Data classes for API
    data class OpenAIRequest(
        val model: String,
        val messages: List<Message>,
        val temperature: Double
    )

    data class Message(
        val role: String,
        val content: String
    )

    data class OpenAIResponse(
        val choices: List<Choice>
    )

    data class Choice(
        val message: MessageContent
    )

    data class MessageContent(
        val content: String
    )

    data class AIEnhancementResponse(
        val tone: String,
        val confidence: Double,
        val emojis: List<String>,
        @SerializedName("emphasizedWords")
        val emphasizedWords: List<String>
    )
}

enum class EmojiIntensity {
    LOW, MEDIUM, HIGH
}
