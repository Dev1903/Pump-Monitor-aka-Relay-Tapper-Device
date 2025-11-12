# Pump Monitor - Flutter Smart Home App

A Flutter app to monitor and control your smart home devices like pumps, lights, fans, and lamps using **Firebase Realtime Database** and **Blynk API**.

---

## Features

- Monitor pump state in real-time.
- Control devices: Light, Fan, Lamp.
- Local notifications for pump state changes.
- Device status sync with Blynk Cloud.
- Modular Flutter code structure for easy maintenance.

---

## Requirements

- Flutter SDK >= 3.9.0
- Android Studio / VS Code
- Firebase Project

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/pump_monitor.git
cd pump_monitor
```
### 2. Install Dependencies
```bash
flutter pub get
```
### 3. Firebase Setup
#### a. Create Firebase Project
Go to Firebase Console.

Click Add Project and follow the steps.

Enable Realtime Database in your project.

#### b. Add Android App
In Firebase Console, go to Project Settings → General → Your Apps → Add App → Android.

Enter your Android package name (from android/app/src/main/AndroidManifest.xml).

Download the google-services.json file.

Place it in: android/app/google-services.json

Note: This file is excluded from GitHub for security. You must provide it locally for builds.

#### c. Add iOS App (Optional)
Add an iOS app in Firebase Console.

Download GoogleService-Info.plist.

Place it in: ios/Runner/GoogleService-Info.plist

### 4. Configure Realtime Database
Go to Realtime Database → Rules and set:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
Or set to true temporarily for testing:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```
Create a node for pump state: switch/state.

### 5. Run the App
```bash
flutter run
```
---

## Folder Structure
```bash
lib/
├─ main.dart             # Entry point
├─ widgets/
│  ├─ pump_widget.dart    # Pump UI & logic
│  ├─ devices_widget.dart # Device buttons
│  ├─ device_button.dart  # Reusable device button widget
├─ helpers/
│  └─ notifications_helper.dart # Local notification logic
```
---

## Notes
Blynk API: Device states are fetched from Blynk Cloud using API keys in code. Replace them with your own Blynk token.

Local Notifications: Only triggers when the pump state changes.

App Icons: Managed using flutter_launcher_icons package.

---

## How to Add Your Own Firebase Config
Replace google-services.json (Android) and GoogleService-Info.plist (iOS) in the respective folders.

Make sure .gitignore keeps them excluded from GitHub.

Rebuild the app.
