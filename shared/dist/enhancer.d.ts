import { EnhancedMessage, EnhancerSettings } from './types.js';
/**
 * Enhance a message with tone-based styling and emojis
 * @param text - The original message text
 * @param apiKey - API key for tone detection (optional for offline mode)
 * @param settings - Enhancement settings
 * @returns Enhanced message with all analysis data
 */
export declare function enhanceMessage(text: string, apiKey?: string, settings?: Partial<EnhancerSettings>): Promise<EnhancedMessage>;
/**
 * Quick enhance for real-time preview (uses offline detection)
 * Faster but less accurate
 */
export declare function enhanceMessageSync(text: string, settings?: Partial<EnhancerSettings>): EnhancedMessage;
export * from './types.js';
export { mapToneToEmojis, getToneVisuals } from './emojiMapper.js';
export { convertToUnicode, convertByTone, convertEmphasizedWords, previewAllStyles } from './unicodeConverter.js';
export { splitIntoSentences } from './sentenceSplitter.js';
export { detectTone, detectToneOffline, detectToneWithClaude } from './toneDetector.js';
//# sourceMappingURL=enhancer.d.ts.map