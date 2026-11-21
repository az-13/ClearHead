# ClearHead

A calm focus timer for students. Name a session, pick a length, stay present — when the timer ends you write one thing you accomplished and it counts toward your history.

## Why it exists

Every study session starts with good intentions and gets pulled away by the phone in your hand. ClearHead doesn't pretend to lock your device — it gives you a calm focus screen, counts only finished sessions, and keeps an honest record of what you actually got done.

## Features

- First-launch welcome screen, then a Home dashboard with greeting, streak and stats
- Start a session in one tap: name it (or pick a quick chip) and choose 15 / 25 / 45 / 60 minutes
- Full-screen focus view with a progress ring, big countdown and gentle reminders
- Emergency exit button — flagged in history so you stay honest with yourself
- Completion check-in: write one thing you accomplished or learned
- History: streak, total focus time, last-7-days strip, completed vs early-exited sessions
- Trusted contacts list in settings
- All data stays on device (UserDefaults) — no account, no internet

## Requirements

- iOS 16.0 or later
- iPhone

## Project structure

```
ClearHead/
├── App/
│   ├── ClearHeadApp.swift      @main entry point
│   └── Theme.swift              colours, cards, button style
├── Models/
│   ├── FocusSession.swift       session data model
│   └── SessionStore.swift       observed store, stats, local persistence
└── Views/
    ├── OnboardingView.swift     first-launch welcome
    ├── RootView.swift           gate + tab bar + active session cover
    ├── HomeView.swift           greeting, stats, inline session setup, recent list
    ├── LockedSessionView.swift  active countdown with progress ring
    ├── CheckInView.swift        completion celebration + reflection note
    ├── HistoryView.swift        streak, weekly strip, past sessions
    └── SettingsView.swift       contacts, about, reset
```

## Building with GitHub Actions

`.github/workflows/build.yml` installs XcodeGen, generates `ClearHead.xcodeproj` from `project.yml`, builds an unsigned iPhone app (`CODE_SIGNING_ALLOWED=NO`), packages it as `ClearHead.ipa`, and uploads it as a build artifact. Sideload the IPA with Sideloadly or AltStore.

## Building locally

Create a new iOS SwiftUI project in Xcode (deployment target iOS 16), add these files to matching groups, and run. No external packages, no API keys.
