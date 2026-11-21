# ClearHead

A simple focus timer for students. Name a session, pick a length, stay present — when the timer ends you write one thing you accomplished and it counts toward your history.

## Why it exists

Every study session starts with good intentions and gets pulled away by the phone in your hand. ClearHead doesn't pretend to lock your device — it gives you a calm focus screen, counts only finished sessions, and keeps an honest record of what you actually got done.

## Features

- Start a focus session: name it (e.g. "Maths Revision") and pick 15 / 25 / 45 / 60 minutes
- Full-screen focus view with a live countdown
- Emergency exit button — flagged in history so you stay honest with yourself
- Completion check-in: write one thing you accomplished or learned
- History: completed sessions, total focus minutes, past sessions
- Trusted contacts list shown during focus so you know who matters right now
- All data stays on device (UserDefaults) — no account, no internet

## Requirements
- iPhone with iOS 16.0 or later

## Project structure

```
ClearHead/
├── App/
│   └── ClearHeadApp.swift      @main entry point
├── Models/
│   ├── FocusSession.swift      session data model
│   └── SessionStore.swift      observed store + local persistence
└── Views/
    ├── RootView.swift           tab bar + active session cover
    ├── HomeView.swift           stats + start button + recent list
    ├── SessionSetupView.swift   name + length picker
    ├── LockedSessionView.swift  active countdown screen
    ├── CheckInView.swift        completion note
    ├── HistoryView.swift        past sessions + totals
    └── SettingsView.swift       contacts + about + reset
```

## Building

Create a new iOS SwiftUI project in Xcode (deployment target iOS 16), add these files to matching groups, and run. No external packages, no API keys.
