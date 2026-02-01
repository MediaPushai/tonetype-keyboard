/**
 * Emotional tones that can be detected in text
 */
export type EmotionalTone =
  | 'happy'
  | 'sad'
  | 'angry'
  | 'excited'
  | 'anxious'
  | 'neutral';

/**
 * Communication style tones
 */
export type StyleTone =
  | 'formal'
  | 'casual'
  | 'sarcastic'
  | 'urgent'
  | 'friendly';

/**
 * Result of tone analysis for a piece of text
 */
export interface ToneAnalysis {
  emotional: {
    primary: EmotionalTone;
    confidence: number; // 0-1
  };
  style: {
    primary: StyleTone;
    confidence: number; // 0-1
  };
  intensity: 'low' | 'medium' | 'high';
  /** Words that carry emotional emphasis - determined by AI/voice analysis, not guessing */
  emphasizedWords?: string[];
}

/**
 * A sentence with its detected tone
 */
export interface AnalyzedSentence {
  original: string;
  tone: ToneAnalysis;
  enhanced: string;
}

/**
 * Result of enhancing a full message
 */
export interface EnhancedMessage {
  original: string;
  enhanced: string;
  sentences: AnalyzedSentence[];
  overallTone: ToneAnalysis;
}

/**
 * Settings for text enhancement
 */
export interface EnhancerSettings {
  enableEmojis: boolean;
  enableStyling: boolean;
  emojiIntensity: 'low' | 'medium' | 'high';
  emojiPlacement: 'end_of_sentence' | 'end_of_message';
}

/**
 * Unicode text style types
 */
export type UnicodeStyle =
  | 'normal'
  | 'bold'
  | 'italic'
  | 'bold_italic'
  | 'small_caps';

/**
 * Mapping of tones to their visual representations
 */
export interface ToneVisuals {
  emojis: string[];
  unicodeStyle: UnicodeStyle;
  cssClass?: string; // For rich text editors
}
