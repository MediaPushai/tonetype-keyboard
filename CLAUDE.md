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

## App Store Connect
- **ASC App ID:** 6759009300
- **Bundle ID:** com.tonetype.app (app), com.tonetype.app.keyboard (extension)
- **Apple Team ID:** 8Q86CQRXSH
- **SKU:** tonetype-ios-001

## Ship List (iOS First - Android Q2 2026)
- [ ] Register tonetype.app domain (DEFERRED — shipping with Vercel URLs)
- [x] Deploy website to Vercel — DONE 2/6/26 (tonetype-website.vercel.app)
- [ ] Set up email forwarding (DEFERRED — using timmcvick@gmail.com)
- [x] Create App Store Connect listing — DONE 2/10/26 (ASC ID: 6759009300)
- [x] Register bundle ID — DONE 2/10/26 (com.tonetype.app)
- [x] Replace app icon placeholder with final 1024x1024 icon — DONE (purple gradient speech bubble with tone waves)
- [x] Generate screenshots for iPhone 6.7" (iPhone 17 Pro Max) — DONE 2/9/26 (5 screenshots: hero, how it works, setup, tones, demo)
- [x] Migrate API key storage from UserDefaults to Keychain — DONE 2/6/26
- [x] Set DEVELOPMENT_TEAM in Xcode — DONE 2/10/26 (8Q86CQRXSH)
- [x] Update URLs to Vercel subdomain — DONE 2/10/26
- [x] Upload metadata to ASC — DONE 2/10/26
- [x] Set up fastlane — DONE 2/10/26
- [ ] Upload screenshots to ASC (in progress)
- [ ] Build iOS archive and upload to ASC
- [ ] Set review contact info in ASC (needs real phone number)
- [ ] Set up tax/banking in App Store Connect
- [ ] Submit for iOS review

## Android (Phase 2)
- [x] Implement numeric keyboard layout — DONE 2/6/26 (full 3-mode: QWERTY/numeric/symbols)
- [x] Upgrade keyboard_view.xml with purple theme — DONE 2/6/26
- [ ] Test on physical Android device
- [ ] Create Google Play Console listing
- [ ] Submit for Android review

**Status:** 90% complete - iOS keyboard works, ASC listing created, metadata uploaded. Building archive for submission. Needs: archive upload, review contact info, tax/banking, then submit.
