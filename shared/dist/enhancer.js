import { splitIntoSentences } from './sentenceSplitter.js';
import { detectTone, detectToneOffline } from './toneDetector.js';
import { mapToneToEmojis } from './emojiMapper.js';
import { convertEmphasizedWords } from './unicodeConverter.js';
/**
 * Main enhancer that orchestrates all the tone detection and text transformation
 */
const DEFAULT_SETTINGS = {
    enableEmojis: true,
    enableStyling: true,
    emojiIntensity: 'medium',
    emojiPlacement: 'end_of_sentence'
};
/**
 * Enhance a message with tone-based styling and emojis
 * @param text - The original message text
 * @param apiKey - API key for tone detection (optional for offline mode)
 * @param settings - Enhancement settings
 * @returns Enhanced message with all analysis data
 */
export async function enhanceMessage(text, apiKey, settings = {}) {
    const opts = { ...DEFAULT_SETTINGS, ...settings };
    if (!text || !text.trim()) {
        return {
            original: text,
            enhanced: text,
            sentences: [],
            overallTone: getDefaultTone()
        };
    }
    // Split into sentences
    const sentences = splitIntoSentences(text);
    // Analyze and enhance each sentence
    const analyzedSentences = [];
    for (const sentence of sentences) {
        // Detect tone (use API if available, otherwise offline)
        let tone;
        try {
            if (apiKey) {
                tone = await detectTone(sentence, apiKey);
            }
            else {
                tone = detectToneOffline(sentence);
            }
        }
        catch (error) {
            console.error('Tone detection failed, using offline:', error);
            tone = detectToneOffline(sentence);
        }
        // Build enhanced sentence
        let enhanced = sentence;
        // Apply styling to AI-determined emphasized words (not guessing)
        if (opts.enableStyling && tone.emphasizedWords && tone.emphasizedWords.length > 0) {
            enhanced = convertEmphasizedWords(sentence, tone.emotional.primary, tone.emphasizedWords);
        }
        // Add emojis if enabled
        if (opts.enableEmojis && opts.emojiPlacement === 'end_of_sentence') {
            const emojis = mapToneToEmojis(tone.emotional.primary, tone.style.primary, opts.emojiIntensity);
            if (emojis) {
                enhanced = enhanced + ' ' + emojis;
            }
        }
        analyzedSentences.push({
            original: sentence,
            tone,
            enhanced
        });
    }
    // Combine enhanced sentences
    let enhancedText = analyzedSentences.map(s => s.enhanced).join(' ');
    // Add emojis at end of message if that's the preference
    if (opts.enableEmojis && opts.emojiPlacement === 'end_of_message') {
        const overallTone = calculateOverallTone(analyzedSentences);
        const emojis = mapToneToEmojis(overallTone.emotional.primary, overallTone.style.primary, opts.emojiIntensity);
        if (emojis) {
            enhancedText = enhancedText + ' ' + emojis;
        }
    }
    return {
        original: text,
        enhanced: enhancedText.trim(),
        sentences: analyzedSentences,
        overallTone: calculateOverallTone(analyzedSentences)
    };
}
/**
 * Quick enhance for real-time preview (uses offline detection)
 * Faster but less accurate
 */
export function enhanceMessageSync(text, settings = {}) {
    const opts = { ...DEFAULT_SETTINGS, ...settings };
    if (!text || !text.trim()) {
        return {
            original: text,
            enhanced: text,
            sentences: [],
            overallTone: getDefaultTone()
        };
    }
    const sentences = splitIntoSentences(text);
    const analyzedSentences = [];
    for (const sentence of sentences) {
        const tone = detectToneOffline(sentence);
        let enhanced = sentence;
        // Offline mode: can't determine emphasized words without AI
        // Only apply styling if we somehow have emphasized words
        if (opts.enableStyling && tone.emphasizedWords && tone.emphasizedWords.length > 0) {
            enhanced = convertEmphasizedWords(sentence, tone.emotional.primary, tone.emphasizedWords);
        }
        if (opts.enableEmojis && opts.emojiPlacement === 'end_of_sentence') {
            const emojis = mapToneToEmojis(tone.emotional.primary, tone.style.primary, opts.emojiIntensity);
            if (emojis) {
                enhanced = enhanced + ' ' + emojis;
            }
        }
        analyzedSentences.push({
            original: sentence,
            tone,
            enhanced
        });
    }
    let enhancedText = analyzedSentences.map(s => s.enhanced).join(' ');
    if (opts.enableEmojis && opts.emojiPlacement === 'end_of_message') {
        const overallTone = calculateOverallTone(analyzedSentences);
        const emojis = mapToneToEmojis(overallTone.emotional.primary, overallTone.style.primary, opts.emojiIntensity);
        if (emojis) {
            enhancedText = enhancedText + ' ' + emojis;
        }
    }
    return {
        original: text,
        enhanced: enhancedText.trim(),
        sentences: analyzedSentences,
        overallTone: calculateOverallTone(analyzedSentences)
    };
}
/**
 * Calculate overall tone from multiple sentences
 * Uses weighted average based on sentence length and confidence
 */
function calculateOverallTone(sentences) {
    if (sentences.length === 0) {
        return getDefaultTone();
    }
    if (sentences.length === 1) {
        return sentences[0].tone;
    }
    // Count occurrences of each tone, weighted by confidence
    const emotionalCounts = {};
    const styleCounts = {};
    let totalEmotionalWeight = 0;
    let totalStyleWeight = 0;
    for (const s of sentences) {
        const emotionalWeight = s.tone.emotional.confidence;
        const styleWeight = s.tone.style.confidence;
        emotionalCounts[s.tone.emotional.primary] =
            (emotionalCounts[s.tone.emotional.primary] || 0) + emotionalWeight;
        totalEmotionalWeight += emotionalWeight;
        styleCounts[s.tone.style.primary] =
            (styleCounts[s.tone.style.primary] || 0) + styleWeight;
        totalStyleWeight += styleWeight;
    }
    // Find dominant tones
    const dominantEmotional = Object.entries(emotionalCounts)
        .sort((a, b) => b[1] - a[1])[0];
    const dominantStyle = Object.entries(styleCounts)
        .sort((a, b) => b[1] - a[1])[0];
    // Calculate average intensity
    const avgIntensity = sentences.reduce((sum, s) => {
        const intensityValue = s.tone.intensity === 'low' ? 1 :
            s.tone.intensity === 'medium' ? 2 : 3;
        return sum + intensityValue;
    }, 0) / sentences.length;
    const intensity = avgIntensity < 1.5 ? 'low' :
        avgIntensity < 2.5 ? 'medium' : 'high';
    return {
        emotional: {
            primary: dominantEmotional[0],
            confidence: dominantEmotional[1] / totalEmotionalWeight
        },
        style: {
            primary: dominantStyle[0],
            confidence: dominantStyle[1] / totalStyleWeight
        },
        intensity
    };
}
function getDefaultTone() {
    return {
        emotional: { primary: 'neutral', confidence: 1.0 },
        style: { primary: 'casual', confidence: 1.0 },
        intensity: 'medium'
    };
}
// Re-export types and utilities for convenience
export * from './types.js';
export { mapToneToEmojis, getToneVisuals } from './emojiMapper.js';
export { convertToUnicode, convertByTone, convertEmphasizedWords, previewAllStyles } from './unicodeConverter.js';
export { splitIntoSentences } from './sentenceSplitter.js';
export { detectTone, detectToneOffline, detectToneWithClaude } from './toneDetector.js';
//# sourceMappingURL=enhancer.js.map