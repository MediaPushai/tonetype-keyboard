/**
 * ToneType Shared Library
 *
 * Core logic for tone detection and text enhancement.
 * Used by iOS keyboard, Android keyboard, and any other platforms.
 */
// Main enhancer (primary export)
export { enhanceMessage, enhanceMessageSync } from './enhancer.js';
// Individual services (for advanced usage)
export { detectTone, detectToneOffline, detectToneWithClaude } from './toneDetector.js';
export { mapToneToEmojis, getToneVisuals, getAvailableEmojis, getStyleEmojis } from './emojiMapper.js';
export { convertToUnicode, convertByTone, convertEmphasizedWords, previewAllStyles, containsStyledUnicode } from './unicodeConverter.js';
export { splitIntoSentences, isCompleteSentence, getSentenceEnding } from './sentenceSplitter.js';
//# sourceMappingURL=index.js.map