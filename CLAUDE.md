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
- [x] Deploy website to Vercel — DONE 2/6/26 (tonetype-website.vercel.app)
- [ ] Set up email forwarding (support@, press@, appstore@)
- [ ] Create App Store Connect listing
- [ ] Register bundle ID: com.tonetype.keyboard
- [x] Replace app icon placeholder with final 1024x1024 icon — DONE (purple gradient speech bubble with tone waves)
- [ ] Generate screenshots for all iPhone sizes (6.9", 6.7", 6.5", 5.5")
- [x] Migrate API key storage from UserDefaults to Keychain — DONE 2/6/26
- [ ] Set up tax/banking in App Store Connect
- [ ] Submit for iOS review

## Android (Phase 2)
- [x] Implement numeric keyboard layout — DONE 2/6/26 (full 3-mode: QWERTY/numeric/symbols)
- [x] Upgrade keyboard_view.xml with purple theme — DONE 2/6/26
- [ ] Test on physical Android device
- [ ] Create Google Play Console listing
- [ ] Submit for Android review

**Status:** 75% complete - iOS keyboard works (Keychain secure), Android keyboard complete (3-mode layout). Needs domain registration, App Store prep, and store submissions.
