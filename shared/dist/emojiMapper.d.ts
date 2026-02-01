import { EmotionalTone, StyleTone, ToneVisuals } from './types.js';
/**
 * Get emojis for a detected tone
 * @param emotional - The emotional tone
 * @param style - The communication style
 * @param intensity - How many emojis to return
 * @returns String of emojis
 */
export declare function mapToneToEmojis(emotional: EmotionalTone, style: StyleTone, intensity?: 'low' | 'medium' | 'high'): string;
/**
 * Get the full visual representation for a tone
 * @param emotional - The emotional tone
 * @param style - The communication style
 * @param intensity - Emoji intensity level
 * @returns ToneVisuals object with emojis and style info
 */
export declare function getToneVisuals(emotional: EmotionalTone, style: StyleTone, intensity?: 'low' | 'medium' | 'high'): ToneVisuals;
/**
 * Get all available emojis for a given emotional tone
 * Useful for letting users customize
 */
export declare function getAvailableEmojis(tone: EmotionalTone): string[];
/**
 * Get all available style emojis
 */
export declare function getStyleEmojis(style: StyleTone): string[];
//# sourceMappingURL=emojiMapper.d.ts.map