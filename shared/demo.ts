/**
 * Demo script to test the ToneType shared logic
 *
 * Run with: npx tsx demo.ts
 * Or after building: node dist/demo.js
 */

import { enhanceMessageSync, previewAllStyles } from './src/index.js';

console.log('=== ToneType Demo ===\n');

// Test messages with different tones
const testMessages = [
  "I'm so happy to see you!",
  "This is terrible. I can't believe it happened.",
  "I NEED THIS DONE NOW!",
  "Oh great, another meeting...",
  "Please find attached the quarterly report.",
  "OMG this is amazing!!! I can't wait!!!",
  "I'm feeling a bit worried about tomorrow.",
  "Hey! What's up? Want to grab coffee?"
];

console.log('--- Testing Tone Detection + Enhancement ---\n');

for (const msg of testMessages) {
  const result = enhanceMessageSync(msg);

  console.log(`Original:  "${msg}"`);
  console.log(`Enhanced:  "${result.enhanced}"`);
  console.log(`Tone:      ${result.overallTone.emotional.primary} (${result.overallTone.style.primary})`);
  console.log('');
}

console.log('\n--- Unicode Style Preview ---\n');

const sampleText = 'Hello World';
const styles = previewAllStyles(sampleText);

console.log(`Normal:      ${styles.normal}`);
console.log(`Bold:        ${styles.bold}`);
console.log(`Italic:      ${styles.italic}`);
console.log(`Bold Italic: ${styles.bold_italic}`);
console.log(`Small Caps:  ${styles.small_caps}`);

console.log('\n=== Demo Complete ===');
