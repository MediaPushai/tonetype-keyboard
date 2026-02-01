# ToneType iOS App

A custom keyboard for iOS that detects tone in your messages and automatically adds emojis and text styling.

## Features

- **Tone Detection**: AI-powered analysis of emotional tone (happy, sad, angry, excited, anxious)
- **Smart Emojis**: Automatically adds relevant emojis after each sentence
- **Text Styling**: Transforms text to Unicode styles (𝗯𝗼𝗹𝗱, 𝘪𝘵𝘢𝘭𝘪𝘤, ᴛɪɴʏ ᴄᴀᴘꜱ) based on tone
- **Works Everywhere**: Custom keyboard works in Messages, WhatsApp, Notes, and any other app

## Examples

| Input | Output |
|-------|--------|
| "I'm so happy!" | "I'm so happy! 😊🎉" |
| "This is unacceptable!" | "𝐓𝐡𝐢𝐬 𝐢𝐬 𝐮𝐧𝐚𝐜𝐜𝐞𝐩𝐭𝐚𝐛𝐥𝐞! 😤🔥" |
| "Can't wait for tomorrow!!!" | "𝑪𝒂𝒏'𝒕 𝒘𝒂𝒊𝒕 𝒇𝒐𝒓 𝒕𝒐𝒎𝒐𝒓𝒓𝒐𝒘!!! 🚀⚡" |
| "I miss you so much" | "ɪ ᴍɪꜱꜱ ʏᴏᴜ ꜱᴏ ᴍᴜᴄʜ 😢💔" |

## Project Structure

```
ios/
├── ToneType.xcodeproj/          # Xcode project
├── ToneType/                     # Main app
│   ├── App/
│   │   └── ToneTypeApp.swift    # App entry point
│   ├── Models/
│   │   ├── AppState.swift       # Shared state management
│   │   └── ToneModels.swift     # Data models
│   ├── Services/
│   │   ├── UnicodeConverter.swift
│   │   ├── EmojiMapper.swift
│   │   ├── ToneDetector.swift
│   │   └── TextEnhancer.swift
│   ├── Views/
│   │   ├── Onboarding/
│   │   ├── Settings/
│   │   └── Demo/
│   └── Resources/
│       └── Assets.xcassets
└── ToneTypeKeyboard/            # Keyboard extension
    ├── KeyboardViewController.swift
    ├── KeyboardView.swift
    ├── KeyboardTextEnhancer.swift
    └── Info.plist
```

## Setup Instructions

### Prerequisites
- Mac with Xcode 15+ installed
- Apple Developer account (free for testing on your device)
- iOS 16+ device or simulator

### Step 1: Open the Project
```bash
cd /Users/timmcvicker/tonetype-keyboard/ios
open ToneType.xcodeproj
```

### Step 2: Configure Signing
1. Select the **ToneType** project in the navigator
2. Select the **ToneType** target
3. Go to **Signing & Capabilities**
4. Select your Team (Apple Developer account)
5. Repeat for the **ToneTypeKeyboard** target

### Step 3: Configure App Groups
1. Select the **ToneType** target → **Signing & Capabilities**
2. Click **+ Capability** → **App Groups**
3. Add: `group.com.tonetype.keyboard`
4. Repeat for the **ToneTypeKeyboard** target

> **Note**: If using your own bundle identifier, update it in:
> - ToneType target → Build Settings → Product Bundle Identifier
> - ToneTypeKeyboard target → Build Settings → Product Bundle Identifier
> - Both entitlements files

### Step 4: Build and Run
1. Select your device or simulator
2. Select the **ToneType** scheme
3. Press **⌘R** to build and run

### Step 5: Enable the Keyboard
On your device:
1. Go to **Settings** → **General** → **Keyboard** → **Keyboards**
2. Tap **Add New Keyboard**
3. Select **ToneType**
4. Tap **ToneType** → Enable **Allow Full Access**

## Usage

1. Open any app with a text field (Messages, Notes, etc.)
2. Tap the **🌐** globe icon to switch to ToneType
3. Type your message
4. Tap **✨** to analyze and enhance
5. Tap **✓** to apply the enhancement
6. Send your message!

## Configuration

In the ToneType app:
- **API Key**: Enter your OpenAI API key for AI-powered detection
- **Enable Emojis**: Toggle emoji additions on/off
- **Enable Styling**: Toggle Unicode text styling on/off
- **Emoji Intensity**: Choose how many emojis to add (1-3)

## Privacy

- Text is only sent to the AI when you tap the enhance button
- Without an API key, all detection is done offline
- Full Access is required for API calls but not for offline mode

## Troubleshooting

**Keyboard doesn't appear in the list**
- Make sure the app is installed on your device
- Try restarting Settings or your device

**Enhancement not working**
- Ensure Full Access is enabled for the keyboard
- Check your internet connection
- Verify your API key is correct

**Only offline detection working**
- Add an OpenAI API key in the ToneType app settings
- Make sure Full Access is enabled

## Development Notes

### App Groups
The main app and keyboard extension share data through App Groups:
- Settings (emoji/styling preferences)
- API key storage

### Keyboard Limitations
- iOS keyboard extensions have memory limits (~30MB)
- Network calls require "Allow Full Access"
- Cannot access most device features

### Testing
Test the keyboard in various apps:
- Messages (iMessage and SMS)
- WhatsApp
- Notes
- Email apps
