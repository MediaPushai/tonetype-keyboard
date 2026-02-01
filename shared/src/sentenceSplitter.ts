/**
 * Splits text into sentences for individual tone analysis.
 * Handles common sentence endings and edge cases.
 */

/**
 * Split text into sentences
 * @param text - The text to split
 * @returns Array of sentences (trimmed, non-empty)
 */
export function splitIntoSentences(text: string): string[] {
  if (!text || typeof text !== 'string') {
    return [];
  }

  // Regex to split on sentence-ending punctuation
  // Handles: . ! ? and combinations like ?! or ...
  // Preserves the punctuation with the sentence
  const sentenceRegex = /[^.!?]*[.!?]+(?:\s|$)|[^.!?]+$/g;

  const matches = text.match(sentenceRegex);

  if (!matches) {
    // No sentence endings found, return the whole text as one sentence
    return text.trim() ? [text.trim()] : [];
  }

  return matches
    .map(s => s.trim())
    .filter(s => s.length > 0);
}

/**
 * Check if a string is likely a complete sentence
 * @param text - Text to check
 * @returns true if it ends with sentence-ending punctuation
 */
export function isCompleteSentence(text: string): boolean {
  if (!text) return false;
  const trimmed = text.trim();
  return /[.!?]$/.test(trimmed);
}

/**
 * Get the sentence ending punctuation
 * @param sentence - The sentence to analyze
 * @returns The punctuation at the end, or empty string
 */
export function getSentenceEnding(sentence: string): string {
  if (!sentence) return '';
  const match = sentence.trim().match(/[.!?]+$/);
  return match ? match[0] : '';
}
