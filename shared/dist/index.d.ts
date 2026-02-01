/**
 * ToneType Shared Library
 *
 * Core logic for tone detection and text enhancement.
 * Used by iOS keyboard, Android keyboard, and any other platforms.
 */
export { enhanceMessage, enhanceMessageSync } from './enhancer.js';
export type { EmotionalTone, StyleTone, ToneAnalysis, AnalyzedSentence, EnhancedMessage, EnhancerSettings, UnicodeStyle, ToneVisuals } from './types.js';
export { detectTone, detectToneOffline, detectToneWithClaude } from './toneDetector.js';
export { mapToneToEmojis, getToneVisuals, getAvailableEmojis, getStyleEmojis } from './emojiMapper.js';
export { convertToUnicode, convertByTone, convertEmphasizedWords, previewAllStyles, containsStyledUnicode } from './unicodeConverter.js';
export { splitIntoSentences, isCompleteSentence, getSentenceEnding } from './sentenceSplitter.js';
//# sourceMappingURL=index.d.ts.map