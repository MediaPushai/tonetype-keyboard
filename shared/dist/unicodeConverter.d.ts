import { EmotionalTone, UnicodeStyle } from './types.js';
/**
 * Convert text to styled Unicode
 * @param text - The text to convert
 * @param style - The Unicode style to apply
 * @returns Styled text using Unicode characters
 */
export declare function convertToUnicode(text: string, style: UnicodeStyle): string;
/**
 * Convert text based on emotional tone
 * @param text - The text to convert
 * @param tone - The detected emotional tone
 * @returns Styled text
 */
export declare function convertByTone(text: string, tone: EmotionalTone): string;
/**
 * Preview how text will look in each style
 * Useful for settings/preview UI
 */
export declare function previewAllStyles(text: string): Record<UnicodeStyle, string>;
/**
 * Check if text contains styled Unicode characters
 * (Useful for detecting already-enhanced text)
 */
export declare function containsStyledUnicode(text: string): boolean;
/**
 * Convert specific emphasized words in text (AI-determined, not guessed)
 * @param text - The text to process
 * @param tone - The detected emotional tone (determines the style to apply)
 * @param emphasizedWords - Specific words to style (from AI analysis or voice prosody)
 * @returns Text with only the emphasized words styled
 */
export declare function convertEmphasizedWords(text: string, tone: EmotionalTone, emphasizedWords: string[]): string;
/**
 * @deprecated Use convertEmphasizedWords with AI-determined words instead
 * This function uses static keyword guessing which is inaccurate
 */
export declare function convertKeywordsByTone(text: string, tone: EmotionalTone): string;
//# sourceMappingURL=unicodeConverter.d.ts.map