/**
 * Splits text into sentences for individual tone analysis.
 * Handles common sentence endings and edge cases.
 */
/**
 * Split text into sentences
 * @param text - The text to split
 * @returns Array of sentences (trimmed, non-empty)
 */
export declare function splitIntoSentences(text: string): string[];
/**
 * Check if a string is likely a complete sentence
 * @param text - Text to check
 * @returns true if it ends with sentence-ending punctuation
 */
export declare function isCompleteSentence(text: string): boolean;
/**
 * Get the sentence ending punctuation
 * @param sentence - The sentence to analyze
 * @returns The punctuation at the end, or empty string
 */
export declare function getSentenceEnding(sentence: string): string;
//# sourceMappingURL=sentenceSplitter.d.ts.map