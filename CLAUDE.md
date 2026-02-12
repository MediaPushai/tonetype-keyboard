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
- [x] Upload screenshots to ASC — DONE 2/10/26
- [x] Build iOS archive and upload to ASC — DONE 2/10/26 (v1.0.0 build 1, processing)
- [x] Fix app icon alpha channel — DONE 2/10/26
- [x] Set review contact info in ASC — DONE 2/10/26
- [x] Set age rating to 4+ — DONE 2/10/26
- [x] Set copyright — DONE 2/10/26
- [x] Changed to iPhone-only — DONE 2/10/26
- [x] Set pricing to Free in ASC — DONE 2/10/26 (Puppeteer, $0.00 across 175 countries)
- [x] Fill privacy nutrition labels in ASC — DONE 2/10/26 (Data Not Collected)
- [x] Set up tax/banking in App Store Connect — DONE 2/10/26 (Free Apps Agreement already active)
- [x] Submit for iOS review — DONE 2/10/26 (v1.0.0 build 2, iPhone-only)
- [x] Cancel App Store review — DONE 2/10/26 (pulled from review for TestFlight testing first)
- [x] Set up TestFlight — DONE 2/10/26 (public link: https://testflight.apple.com/join/5Yx4kE68)
- [x] Submit for Beta App Review — DONE 2/10/26 (BETA_APPROVED)
- [x] TestFlight public link live — https://testflight.apple.com/join/5Yx4kE68
- [x] Resubmit for App Store review — DONE 2/12/26 (Build 2, v1.0.0)
- [ ] App Store review (24-48 hours — submitted 2/12/26)

## OpenClaw Handoff
- [x] Push all code to public repo (MediaPushai/tonetype-keyboard) — DONE 2/10/26
- [x] Fork to timmcvick-debug/tonetype-keyboard — DONE 2/10/26
- [x] Create OpenClaw development prompt — DONE 2/10/26 (~/Desktop/tonetype-openclaw-prompt.md)

## Android (Phase 2)
- [x] Implement numeric keyboard layout — DONE 2/6/26 (full 3-mode: QWERTY/numeric/symbols)
- [x] Upgrade keyboard_view.xml with purple theme — DONE 2/6/26
- [ ] Test on physical Android device
- [ ] Create Google Play Console listing
- [ ] Submit for Android review

**Status:** Submitted for App Store review 2/12/26 (Build 2, v1.0.0). Expect 24-48 hours. TestFlight: https://testflight.apple.com/join/5Yx4kE68. Android Phase 2 deferred to Q2 2026.
