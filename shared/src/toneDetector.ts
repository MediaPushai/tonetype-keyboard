import { ToneAnalysis, EmotionalTone, StyleTone } from './types.js';

/**
 * Detects emotional and style tones in text using AI API
 */

const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions';

/**
 * The prompt template for tone analysis
 * Now includes emphasized words detection - the AI identifies which specific
 * words carry emotional weight, rather than using a static keyword list
 */
const TONE_ANALYSIS_PROMPT = `Analyze this message's emotional tone and identify which specific words are emphasized.

IMPORTANT: "emphasizedWords" should contain the exact words from the message that carry emotional weight or would be stressed when spoken. This varies by context:
- "I can't believe YOU did that" → emphasize "you" (shock at the person)
- "I CAN'T believe you did that" → emphasize "can't" (disbelief)
- "I can't believe you did THAT" → emphasize "that" (shock at the action)

Return ONLY valid JSON:
{
  "emotional": {
    "primary": "happy|sad|angry|excited|anxious|neutral",
    "confidence": 0.0-1.0
  },
  "style": {
    "primary": "formal|casual|sarcastic|urgent|friendly",
    "confidence": 0.0-1.0
  },
  "intensity": "low|medium|high",
  "emphasizedWords": ["word1", "word2"]
}

Message: "{MESSAGE}"`;

/**
 * Detect tone in text using OpenAI API
 * @param text - The text to analyze
 * @param apiKey - OpenAI API key
 * @returns ToneAnalysis object
 */
export async function detectTone(text: string, apiKey: string): Promise<ToneAnalysis> {
  if (!text || !text.trim()) {
    return getDefaultTone();
  }

  if (!apiKey) {
    throw new Error('API key is required for tone detection');
  }

  try {
    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini', // Fast and cheap
        messages: [
          {
            role: 'system',
            content: 'You are a tone analyzer. You respond ONLY with valid JSON, no other text.'
          },
          {
            role: 'user',
            content: TONE_ANALYSIS_PROMPT.replace('{MESSAGE}', text)
          }
        ],
        temperature: 0.3, // Lower temperature for more consistent results
        max_tokens: 150
      })
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({})) as any;
      throw new Error(errorData.error?.message || `API error: ${response.status}`);
    }

    const data = await response.json() as any;
    const content = data.choices?.[0]?.message?.content;

    if (!content) {
      throw new Error('No response from API');
    }

    // Parse the JSON response
    const parsed = JSON.parse(content);
    return validateToneAnalysis(parsed);

  } catch (error) {
    console.error('Tone detection error:', error);

    // If it's a parsing error, try to extract what we can
    if (error instanceof SyntaxError) {
      return getDefaultTone();
    }

    throw error;
  }
}

/**
 * Detect tone using Claude API instead
 * @param text - The text to analyze
 * @param apiKey - Anthropic API key
 * @returns ToneAnalysis object
 */
export async function detectToneWithClaude(text: string, apiKey: string): Promise<ToneAnalysis> {
  if (!text || !text.trim()) {
    return getDefaultTone();
  }

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: 'claude-3-haiku-20240307', // Fast and cheap
      max_tokens: 150,
      messages: [
        {
          role: 'user',
          content: TONE_ANALYSIS_PROMPT.replace('{MESSAGE}', text)
        }
      ]
    })
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({})) as any;
    throw new Error(errorData.error?.message || `API error: ${response.status}`);
  }

  const data = await response.json() as any;
  const content = data.content?.[0]?.text;

  if (!content) {
    throw new Error('No response from API');
  }

  const parsed = JSON.parse(content);
  return validateToneAnalysis(parsed);
}

/**
 * Validate and normalize the tone analysis result
 */
function validateToneAnalysis(data: any): ToneAnalysis {
  const validEmotional: EmotionalTone[] = ['happy', 'sad', 'angry', 'excited', 'anxious', 'neutral'];
  const validStyle: StyleTone[] = ['formal', 'casual', 'sarcastic', 'urgent', 'friendly'];
  const validIntensity = ['low', 'medium', 'high'];

  // Validate and default emotional tone
  const emotional = validEmotional.includes(data.emotional?.primary)
    ? data.emotional.primary
    : 'neutral';

  const emotionalConfidence = typeof data.emotional?.confidence === 'number'
    ? Math.max(0, Math.min(1, data.emotional.confidence))
    : 0.5;

  // Validate and default style tone
  const style = validStyle.includes(data.style?.primary)
    ? data.style.primary
    : 'casual';

  const styleConfidence = typeof data.style?.confidence === 'number'
    ? Math.max(0, Math.min(1, data.style.confidence))
    : 0.5;

  // Validate intensity
  const intensity = validIntensity.includes(data.intensity)
    ? data.intensity
    : 'medium';

  // Extract emphasized words (AI-determined, not guessed from a static list)
  const emphasizedWords = Array.isArray(data.emphasizedWords)
    ? data.emphasizedWords.filter((w: any) => typeof w === 'string')
    : [];

  return {
    emotional: {
      primary: emotional,
      confidence: emotionalConfidence
    },
    style: {
      primary: style,
      confidence: styleConfidence
    },
    intensity: intensity as 'low' | 'medium' | 'high',
    emphasizedWords
  };
}

/**
 * Get default/neutral tone for fallback
 */
function getDefaultTone(): ToneAnalysis {
  return {
    emotional: {
      primary: 'neutral',
      confidence: 1.0
    },
    style: {
      primary: 'casual',
      confidence: 1.0
    },
    intensity: 'medium'
  };
}

/**
 * Simple rule-based tone detection (fallback when offline)
 * Less accurate but works without API
 */
export function detectToneOffline(text: string): ToneAnalysis {
  const lower = text.toLowerCase();

  // Check for emotional indicators
  let emotional: EmotionalTone = 'neutral';
  let intensity: 'low' | 'medium' | 'high' = 'medium';

  // Happy indicators
  if (/\b(happy|glad|excited|great|awesome|wonderful|love|yay|woohoo)\b/.test(lower) ||
      /[!]{2,}/.test(text) && /\b(so|really|very)\b/.test(lower)) {
    emotional = 'happy';
  }
  // Sad indicators
  else if (/\b(sad|sorry|unfortunately|miss|down|depressed|cry|tears)\b/.test(lower)) {
    emotional = 'sad';
  }
  // Angry indicators
  else if (/\b(angry|mad|furious|hate|annoyed|frustrated|stupid|ridiculous)\b/.test(lower) ||
           text === text.toUpperCase() && text.length > 10) {
    emotional = 'angry';
    if (text === text.toUpperCase()) intensity = 'high';
  }
  // Excited indicators
  else if (/\b(omg|wow|amazing|incredible|can't wait|so excited)\b/.test(lower) ||
           /[!]{3,}/.test(text)) {
    emotional = 'excited';
    intensity = 'high';
  }
  // Anxious indicators
  else if (/\b(worried|nervous|anxious|scared|afraid|unsure|maybe)\b/.test(lower)) {
    emotional = 'anxious';
  }

  // Check for style indicators
  let style: StyleTone = 'casual';

  // Formal indicators
  if (/\b(please find|attached|regards|sincerely|dear|per our|as discussed)\b/.test(lower)) {
    style = 'formal';
  }
  // Urgent indicators
  else if (/\b(asap|urgent|immediately|now|hurry|deadline)\b/.test(lower) ||
           /[!]{2,}/.test(text)) {
    style = 'urgent';
  }
  // Sarcastic indicators (hard to detect accurately)
  else if (/\b(oh great|sure|right|whatever|totally|obviously)\b/.test(lower) &&
           /\.{3}|🙄/.test(text)) {
    style = 'sarcastic';
  }

  return {
    emotional: { primary: emotional, confidence: 0.6 },
    style: { primary: style, confidence: 0.6 },
    intensity
  };
}
