import { EmotionalTone, StyleTone, ToneVisuals } from './types.js';

/**
 * Maps tones to appropriate emojis and visual styles
 */

// Emoji sets for each emotional tone
const emotionalEmojis: Record<EmotionalTone, string[]> = {
  happy: ['😊', '🎉', '✨', '😄', '🌟', '💫'],
  sad: ['😢', '💔', '😔', '🥺', '😞', '💙'],
  angry: ['😤', '🔥', '😡', '💢', '😠', '⚡'],
  excited: ['🚀', '⚡', '🎊', '🙌', '💥', '🎯'],
  anxious: ['😰', '😬', '💭', '😟', '🫤', '😣'],
  neutral: [] // No emojis for neutral
};

// Emoji sets for style tones (used as secondary/accent)
const styleEmojis: Record<StyleTone, string[]> = {
  formal: ['📋', '✉️', '📝'],
  casual: ['👋', '😄', '🙂'],
  sarcastic: ['😏', '🙄', '💅', '🤷'],
  urgent: ['⚠️', '❗', '🚨', '⏰'],
  friendly: ['💕', '🤗', '😊', '💫']
};

// Unicode styles for each emotional tone
const toneStyles: Record<EmotionalTone, ToneVisuals['unicodeStyle']> = {
  happy: 'normal',
  sad: 'small_caps',
  angry: 'bold',
  excited: 'bold_italic',
  anxious: 'normal',
  neutral: 'normal'
};

// Override styles for certain style tones
const styleOverrides: Partial<Record<StyleTone, ToneVisuals['unicodeStyle']>> = {
  sarcastic: 'italic',
  urgent: 'bold'
};

/**
 * Get emojis for a detected tone
 * @param emotional - The emotional tone
 * @param style - The communication style
 * @param intensity - How many emojis to return
 * @returns String of emojis
 */
export function mapToneToEmojis(
  emotional: EmotionalTone,
  style: StyleTone,
  intensity: 'low' | 'medium' | 'high' = 'medium'
): string {
  const count = intensity === 'low' ? 1 : intensity === 'medium' ? 2 : 3;

  // Get emotional emojis first
  const emojis = emotionalEmojis[emotional].slice(0, count);

  // If we need more and have style emojis, add them
  if (emojis.length < count && style !== 'formal') {
    const styleEmojiList = styleEmojis[style];
    const needed = count - emojis.length;
    emojis.push(...styleEmojiList.slice(0, needed));
  }

  return emojis.join('');
}

/**
 * Get the full visual representation for a tone
 * @param emotional - The emotional tone
 * @param style - The communication style
 * @param intensity - Emoji intensity level
 * @returns ToneVisuals object with emojis and style info
 */
export function getToneVisuals(
  emotional: EmotionalTone,
  style: StyleTone,
  intensity: 'low' | 'medium' | 'high' = 'medium'
): ToneVisuals {
  const count = intensity === 'low' ? 1 : intensity === 'medium' ? 2 : 3;

  // Determine unicode style (style tone can override emotional tone style)
  let unicodeStyle = toneStyles[emotional];
  if (styleOverrides[style]) {
    unicodeStyle = styleOverrides[style]!;
  }

  // Get emojis
  const emojis = emotionalEmojis[emotional].slice(0, count);

  // CSS class for rich text styling
  const cssClass = `tone-${emotional}`;

  return {
    emojis,
    unicodeStyle,
    cssClass
  };
}

/**
 * Get all available emojis for a given emotional tone
 * Useful for letting users customize
 */
export function getAvailableEmojis(tone: EmotionalTone): string[] {
  return [...emotionalEmojis[tone]];
}

/**
 * Get all available style emojis
 */
export function getStyleEmojis(style: StyleTone): string[] {
  return [...styleEmojis[style]];
}
