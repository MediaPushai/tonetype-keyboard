import { EmotionalTone, UnicodeStyle } from './types.js';

/**
 * Converts regular text to styled Unicode characters
 * These special characters display as bold, italic, etc. in any text field
 */

// Unicode character mappings for different styles
// Mathematical Alphanumeric Symbols block (U+1D400–U+1D7FF)

const BOLD_UPPER = 'U+1D400'; // Start of bold uppercase A
const BOLD_LOWER = 'U+1D41A'; // Start of bold lowercase a

const ITALIC_UPPER = 'U+1D434'; // Start of italic uppercase A
const ITALIC_LOWER = 'U+1D44E'; // Start of italic lowercase a

const BOLD_ITALIC_UPPER = 'U+1D468'; // Start of bold italic uppercase A
const BOLD_ITALIC_LOWER = 'U+1D482'; // Start of bold italic lowercase a

// Character maps for each style
const boldMap: Record<string, string> = {};
const italicMap: Record<string, string> = {};
const boldItalicMap: Record<string, string> = {};
const smallCapsMap: Record<string, string> = {};

// Build bold character map (Mathematical Bold)
for (let i = 0; i < 26; i++) {
  const upper = String.fromCharCode(65 + i); // A-Z
  const lower = String.fromCharCode(97 + i); // a-z
  boldMap[upper] = String.fromCodePoint(0x1D400 + i);
  boldMap[lower] = String.fromCodePoint(0x1D41A + i);
}

// Build italic character map (Mathematical Italic)
for (let i = 0; i < 26; i++) {
  const upper = String.fromCharCode(65 + i);
  const lower = String.fromCharCode(97 + i);
  // Note: 'h' is at a different position in Unicode
  if (i === 7) { // 'h'
    italicMap[lower] = String.fromCodePoint(0x210E); // Planck constant
  } else {
    italicMap[upper] = String.fromCodePoint(0x1D434 + i);
    italicMap[lower] = String.fromCodePoint(0x1D44E + i);
  }
  italicMap[upper] = String.fromCodePoint(0x1D434 + i);
}

// Build bold italic character map
for (let i = 0; i < 26; i++) {
  const upper = String.fromCharCode(65 + i);
  const lower = String.fromCharCode(97 + i);
  boldItalicMap[upper] = String.fromCodePoint(0x1D468 + i);
  boldItalicMap[lower] = String.fromCodePoint(0x1D482 + i);
}

// Build small caps map (using Latin Small Capitals from various Unicode blocks)
const smallCapsChars = 'ᴀʙᴄᴅᴇꜰɢʜɪᴊᴋʟᴍɴᴏᴘǫʀꜱᴛᴜᴠᴡxʏᴢ';
for (let i = 0; i < 26; i++) {
  const lower = String.fromCharCode(97 + i);
  const upper = String.fromCharCode(65 + i);
  smallCapsMap[lower] = smallCapsChars[i];
  smallCapsMap[upper] = smallCapsChars[i];
}

// Bold digits
const boldDigits: Record<string, string> = {};
for (let i = 0; i < 10; i++) {
  boldDigits[String(i)] = String.fromCodePoint(0x1D7CE + i);
}

/**
 * Convert a single character to its styled Unicode equivalent
 */
function convertChar(char: string, style: UnicodeStyle): string {
  if (style === 'normal') return char;

  switch (style) {
    case 'bold':
      return boldMap[char] || boldDigits[char] || char;
    case 'italic':
      return italicMap[char] || char;
    case 'bold_italic':
      return boldItalicMap[char] || boldDigits[char] || char;
    case 'small_caps':
      return smallCapsMap[char] || char;
    default:
      return char;
  }
}

/**
 * Convert text to styled Unicode
 * @param text - The text to convert
 * @param style - The Unicode style to apply
 * @returns Styled text using Unicode characters
 */
export function convertToUnicode(text: string, style: UnicodeStyle): string {
  if (!text || style === 'normal') return text;

  return Array.from(text)
    .map(char => convertChar(char, style))
    .join('');
}

/**
 * Convert text based on emotional tone
 * @param text - The text to convert
 * @param tone - The detected emotional tone
 * @returns Styled text
 */
export function convertByTone(text: string, tone: EmotionalTone): string {
  const styleMap: Record<EmotionalTone, UnicodeStyle> = {
    happy: 'normal',
    sad: 'small_caps',
    angry: 'bold',
    excited: 'bold_italic',
    anxious: 'normal',
    neutral: 'normal'
  };

  return convertToUnicode(text, styleMap[tone]);
}

/**
 * Preview how text will look in each style
 * Useful for settings/preview UI
 */
export function previewAllStyles(text: string): Record<UnicodeStyle, string> {
  return {
    normal: text,
    bold: convertToUnicode(text, 'bold'),
    italic: convertToUnicode(text, 'italic'),
    bold_italic: convertToUnicode(text, 'bold_italic'),
    small_caps: convertToUnicode(text, 'small_caps')
  };
}

/**
 * Check if text contains styled Unicode characters
 * (Useful for detecting already-enhanced text)
 */
export function containsStyledUnicode(text: string): boolean {
  // Check for Mathematical Alphanumeric Symbols
  return /[\u{1D400}-\u{1D7FF}]|[ᴀ-ᴢ]/u.test(text);
}

/**
 * Style map for tones
 */
const toneStyleMap: Record<EmotionalTone, UnicodeStyle> = {
  happy: 'normal',
  sad: 'small_caps',
  angry: 'bold',
  excited: 'bold_italic',
  anxious: 'italic',
  neutral: 'normal'
};

/**
 * Convert specific emphasized words in text (AI-determined, not guessed)
 * @param text - The text to process
 * @param tone - The detected emotional tone (determines the style to apply)
 * @param emphasizedWords - Specific words to style (from AI analysis or voice prosody)
 * @returns Text with only the emphasized words styled
 */
export function convertEmphasizedWords(
  text: string,
  tone: EmotionalTone,
  emphasizedWords: string[]
): string {
  const style = toneStyleMap[tone];
  if (style === 'normal') return text;
  if (!emphasizedWords || emphasizedWords.length === 0) return text;

  let result = text;

  // Sort by length (longest first) to avoid partial replacements
  const sortedWords = [...emphasizedWords].sort((a, b) => b.length - a.length);

  for (const word of sortedWords) {
    // Escape special regex characters
    const escaped = word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const pattern = new RegExp(`\\b(${escaped})\\b`, 'gi');

    result = result.replace(pattern, (match) => convertToUnicode(match, style));
  }

  return result;
}

/**
 * @deprecated Use convertEmphasizedWords with AI-determined words instead
 * This function uses static keyword guessing which is inaccurate
 */
export function convertKeywordsByTone(text: string, tone: EmotionalTone): string {
  // Fallback for offline mode - but this is just guessing
  const style = toneStyleMap[tone];
  if (style === 'normal') return text;

  // Without AI analysis, we can't know which words are emphasized
  // Return unstyled text - better than guessing wrong
  return text;
}
