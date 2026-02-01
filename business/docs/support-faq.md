# ToneType Support FAQ

## Getting Started

### How do I install ToneType?
1. Download ToneType from the App Store
2. Open the ToneType app
3. Follow the onboarding steps to enable the keyboard:
   - Go to **Settings → General → Keyboard → Keyboards**
   - Tap **Add New Keyboard**
   - Select **ToneType**
   - Tap **ToneType** again and enable **Allow Full Access**

### How do I switch to the ToneType keyboard?
When you're in any text field, tap the globe icon (🌐) on your current keyboard to cycle through keyboards until you see ToneType.

**Tip**: You can also hold the globe icon to see a list of all your keyboards and select ToneType directly.

### What does "Allow Full Access" mean?
iOS requires "Full Access" for keyboard extensions that need network connectivity. ToneType needs this to send your text to our AI service for tone analysis.

**What Full Access does NOT do:**
- It does NOT give us access to passwords
- It does NOT let us see sensitive fields (credit cards, etc.)
- It does NOT log your keystrokes
- It does NOT send data without your action (tapping enhance)

---

## Using ToneType

### How do I enhance a message?
1. Type your message as normal
2. Tap the **✨** (sparkle) button on the keyboard
3. Wait briefly for AI analysis
4. Your enhanced message appears with emojis and styling
5. Tap to apply, or edit as needed

### Can I undo an enhancement?
Yes! After enhancing, you can use your phone's standard undo (shake to undo on iOS) or simply delete and retype.

### What tones does ToneType detect?
ToneType recognizes:
- **Happy**: Cheerful, positive messages
- **Sad**: Melancholy, disappointed messages
- **Angry**: Frustrated, upset messages
- **Excited**: Enthusiastic, energetic messages
- **Sarcastic**: Ironic, witty messages
- **Urgent**: Time-sensitive, important messages
- **Formal**: Professional, business-like messages
- **Casual**: Relaxed, friendly messages

### Why did ToneType add emojis I didn't want?
ToneType bases emoji suggestions on detected tone. If the suggestions don't match your intent, your message may have been ambiguous. You can:
- Edit or remove emojis after enhancement
- Rephrase your message to clarify intent
- Adjust emoji intensity in Settings

### The styling looks weird in some apps. Why?
ToneType uses Unicode characters for text styling (𝗯𝗼𝗹𝗱, 𝘪𝘵𝘢𝘭𝘪𝘤, etc.). Most apps display these correctly, but some older apps or specific platforms may not render them properly. The text will still be readable, just without the styling.

---

## Settings & Customization

### How do I change emoji intensity?
1. Open the ToneType app
2. Go to **Settings**
3. Find **Emoji Intensity**
4. Choose: Low (1-2 emojis), Medium (2-3), or High (3-5)

### How do I disable text styling?
1. Open the ToneType app
2. Go to **Settings**
3. Toggle off **Apply Text Styling**

### How do I disable emojis entirely?
1. Open the ToneType app
2. Go to **Settings**
3. Toggle off **Add Emojis**

### Can I use my own API key?
Yes! ToneType supports "Bring Your Own Key" for users who want unlimited usage:
1. Open the ToneType app
2. Go to **Settings → AI Configuration**
3. Enter your OpenAI API key
4. Your key is stored securely on your device

---

## Privacy & Security

### Does ToneType see everything I type?
**No.** ToneType only processes text when you tap the enhance button. We do not:
- Log keystrokes
- Monitor your typing
- Store your messages
- Send data without your explicit action

### Where does my text go when I enhance?
When you tap enhance, your current text is sent to OpenAI's API for tone analysis. The text is:
- Processed immediately
- Not stored by ToneType
- Not used for training
- Deleted after processing

### Is my data sold to advertisers?
**Absolutely not.** We do not sell, share, or monetize your data in any way. Our business model is the product itself, not your information.

### How is my API key protected?
If you provide your own OpenAI API key, it's stored in iOS Keychain—Apple's encrypted, secure storage. It never leaves your device except when making API calls.

---

## Troubleshooting

### ToneType isn't showing up as a keyboard option
1. Make sure you downloaded ToneType from the App Store
2. Go to **Settings → General → Keyboard → Keyboards → Add New Keyboard**
3. Look for **ToneType** in the list
4. If not there, try restarting your device

### Enhancement isn't working
Check the following:
1. **Full Access enabled?** Go to Settings → General → Keyboard → Keyboards → ToneType → Allow Full Access
2. **Internet connection?** ToneType needs network access for AI analysis
3. **API key valid?** If using your own key, verify it's correct

### The keyboard looks different than expected
ToneType follows iOS system appearance. If you want to change the keyboard appearance:
1. Check iOS Settings → Display & Brightness
2. Light/Dark mode affects keyboard appearance

### Enhancement is slow
Enhancement typically takes 1-3 seconds. If slower:
- Check your internet connection
- Try on WiFi instead of cellular
- Server load may cause occasional delays

### I'm hitting the daily limit
Free users get 10 enhancements per day. To get unlimited:
- Upgrade to ToneType Pro ($4.99/month)
- Or add your own OpenAI API key (you pay OpenAI directly)

---

## Account & Billing

### Do I need an account to use ToneType?
No. ToneType works without any account or sign-up. All settings are stored locally on your device.

### How do I subscribe to Pro?
1. Open the ToneType app
2. Tap **Upgrade to Pro**
3. Complete purchase through Apple (uses your Apple ID)

### How do I cancel my subscription?
1. Open **Settings** on your iPhone
2. Tap your name at the top
3. Tap **Subscriptions**
4. Find **ToneType** and tap **Cancel Subscription**

### Can I get a refund?
Refunds are handled by Apple. Contact Apple Support or request a refund at reportaproblem.apple.com.

---

## Contact Support

### I have a question not answered here
Email us at **support@tonetype.app**

We typically respond within 24 hours.

### I found a bug
Please report bugs to **bugs@tonetype.app** with:
- Your iOS version
- Steps to reproduce the issue
- Screenshots if possible

### I have a feature request
We love hearing ideas! Send them to **feedback@tonetype.app**

---

## Troubleshooting Checklist

If ToneType isn't working, try these steps in order:

1. ✅ Restart the app you're typing in
2. ✅ Check Full Access is enabled
3. ✅ Verify internet connection
4. ✅ Restart your device
5. ✅ Delete and reinstall ToneType
6. ✅ Contact support if still not working
