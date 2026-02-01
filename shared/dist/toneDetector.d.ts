import { ToneAnalysis } from './types.js';
/**
 * Detect tone in text using OpenAI API
 * @param text - The text to analyze
 * @param apiKey - OpenAI API key
 * @returns ToneAnalysis object
 */
export declare function detectTone(text: string, apiKey: string): Promise<ToneAnalysis>;
/**
 * Detect tone using Claude API instead
 * @param text - The text to analyze
 * @param apiKey - Anthropic API key
 * @returns ToneAnalysis object
 */
export declare function detectToneWithClaude(text: string, apiKey: string): Promise<ToneAnalysis>;
/**
 * Simple rule-based tone detection (fallback when offline)
 * Less accurate but works without API
 */
export declare function detectToneOffline(text: string): ToneAnalysis;
//# sourceMappingURL=toneDetector.d.ts.map