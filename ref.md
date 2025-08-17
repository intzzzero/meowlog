# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Meowlog** is a native iOS app built with Swift and SwiftUI for cat health monitoring and management. The app allows users to track their cats' health records (bowel movements, urination, respiratory rate, heart rate), manage medication schedules with push notifications, and maintain detailed cat profiles.

## Commands

### Build Commands
```bash
# Build only
xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates build | xcbeautify

# Build and run on iPhone 16 Pro simulator
xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' | xcbeautify

# Run tests
xcodebuild -project Meowlog.xcodeproj -scheme Meowlog -configuration Debug -allowProvisioningUpdates test -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' | xcbeautify
```

### Simulator Commands
```bash
# Open simulator
open -a Simulator

# Launch app directly (if already installed)
xcrun simctl launch booted com.meowlog.app.Meowlog

# Check booted simulator
xcrun simctl list devices | grep "iPhone 16 Pro" | grep "Booted"

# Uninstall and reinstall app (for cache issues)
xcrun simctl uninstall AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 com.meowlog.app.Meowlog
xcrun simctl install AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 ~/Library/Developer/Xcode/DerivedData/Meowlog-*/Build/Products/Debug-iphonesimulator/Meowlog.app
xcrun simctl launch AAF68E7E-8E07-4F3D-91C9-FDF1F418A755 com.meowlog.app.Meowlog
```

## Architecture

### Core Data Models (SwiftData)
- **Cat**: Main entity with profile information (name, birth date, breed, gender, weight, etc.)
- **HealthRecord**: Tracks various health metrics with specialized enums for bowel movements, urination, respiratory rate, and heart rate
- **MedicationSchedule**: Manages medication schedules with frequencies (daily, weekly, monthly, as-needed)
- **MedicationLog**: Records actual medication administration

### Key Features
- **SwiftData Integration**: Uses SwiftData for local data persistence with relationships between models
- **Push Notifications**: Comprehensive notification system for medication reminders with interactive actions
- **Health Tracking**: Detailed health record system with severity levels and health concerns
- **Multi-cat Support**: Designed to handle multiple cats with individual profiles and records

### UI Structure
- **MainTabView**: Root tab view with conditional onboarding for new users
- **Tab Structure**: Dashboard, Health Records, Medication Management, and Profile tabs
- **Onboarding**: Shows when no cats are registered

### Notification System
- **NotificationManager**: Singleton managing all push notifications
- **Interactive Actions**: "Take medication", "Skip", and "Snooze" actions
- **Frequency Support**: Daily, weekly, and monthly medication schedules
- **Authorization Handling**: Proper permission management

### Health Record Classifications
- **Bowel Movement**: 8 types with severity levels (normal, constipation, diarrhea, blood variants, etc.)
- **Urination**: 7 types with severity and health concern descriptions
- **Consistency & Color**: Detailed Bristol scale mapping and color classification
- **Frequency Tracking**: Normal, decreased, increased, and frequent patterns

## Development Notes

### Key Dependencies
- SwiftUI for UI framework
- SwiftData for local data persistence
- UserNotifications for push notifications
- Foundation for core utilities

### File Organization
- `Models/`: SwiftData models (Cat, HealthRecord, MedicationSchedule)
- `Views/`: SwiftUI views organized by feature (Dashboard, HealthRecord, Medication, Profile, Onboarding)
- `Managers/`: Singleton managers (NotificationManager)

### Important Patterns
- Uses `@Model` for SwiftData entities
- Implements `@Relationship` for data relationships with cascade deletion
- Utilizes `@StateObject` and `@EnvironmentObject` for state management
- Follows SwiftUI navigation patterns with TabView

### Testing Setup
- Unit tests in `MeowlogTests/`
- UI tests in `MeowlogUITests/`
- Uses in-memory model containers for testing

## Bundle Identifier
`com.meowlog.app.Meowlog`

## Target iOS Version
iOS 17+ (some features may require iOS 18+)