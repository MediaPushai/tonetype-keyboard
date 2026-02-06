# ToneType Keyboard

**Expert Persona:** Principal Mobile Engineer (iOS/Android) — 14 years shipping keyboard and input method apps. Former tech lead at SwiftKey/Gboard. Deep expertise in keyboard extensions, predictive text, App Store optimization, and cross-platform mobile architecture.

## Overview
- **Description:** Custom keyboard app for iOS and Android
- **Tech:** Swift (iOS), Kotlin (Android), shared node modules
- **Structure:**
  - `ios/` - iOS app and keyboard extension (Xcode project)
  - `android/` - Android app
  - `shared/` - Shared logic/node modules
  - `web-demo/` - Web demo
  - `business/` - Brand assets, legal docs, marketing, website

## iOS Development
- Open `ios/ToneType.xcodeproj` in Xcode
- Keyboard extension: `ios/ToneTypeKeyboard/`

## Common Tasks
- Build iOS: Open in Xcode, select target, build
- Run shared tests: `cd shared && npm test`

## Ship List (iOS First - Android Q2 2026)
- [ ] Register tonetype.app domain
- [ ] Deploy website to Vercel
- [ ] Set up email forwarding (support@, press@, appstore@)
- [ ] Create App Store Connect listing
- [ ] Register bundle ID: com.tonetype.keyboard
- [ ] Replace app icon placeholder with final 1024x1024 icon
- [ ] Generate screenshots for all iPhone sizes (6.9", 6.7", 6.5", 5.5")
- [ ] Migrate API key storage from UserDefaults to Keychain
- [ ] Set up tax/banking in App Store Connect
- [ ] Submit for iOS review

## Android (Phase 2)
- [ ] Implement numeric keyboard layout (TODO at ToneTypeIME.kt:112)
- [ ] Add keyboard_view.xml layout file
- [ ] Test on physical Android device
- [ ] Create Google Play Console listing
- [ ] Submit for Android review

**Status:** 65% complete - iOS keyboard works, needs App Store prep and domain setup
