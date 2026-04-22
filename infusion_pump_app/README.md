# Infusion Pump Controller - Flutter App

A production-ready Flutter mobile application for controlling an ESP32-based Infusion/Syringe Pump medical device via Firebase Realtime Database.

## Features

- **Live Dashboard** - Real-time monitoring of flow rates, dispensed volume, circular progress, and volume-over-time chart
- **Alarms Panel** - 2x2 alarm grid with audio alerts, push notifications, and haptic feedback
- **Manual Control** - Start/Pause/Stop buttons with validated flow rate and volume inputs
- **Auto Dose Calculator** - Weight-based dosing calculation for 10 common ICU drugs with safety warnings
- **Infusion History** - Local session logs with expandable details and clipboard export
- **Background Monitoring** - Alarm monitoring continues when app is minimized
- **Push Notifications** - FCM Cloud Functions send push alerts when alarms trigger

## Architecture

- **State Management**: Riverpod (StreamProviders for real-time Firebase data)
- **Routing**: go_router with ShellRoute for persistent bottom navigation
- **Theme**: "Blood Cell" dark theme with crimson accents and blood cell background
- **Clean Architecture**: `/core`, `/features`, `/shared` folder structure
- **Platforms**: Android (primary), iOS, Web, Windows, macOS, Linux

## Setup

### Prerequisites
- Flutter 3.x with Dart null safety
- A Firebase project with Realtime Database enabled
- Android Studio or VS Code with Flutter extension

### Step 1: Firebase Configuration (FlutterFire CLI — Recommended)

The fastest way to configure Firebase for all platforms:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (auto-generates firebase_options.dart & google-services.json)
flutterfire configure
```

This will:
- Create/update `lib/firebase_options.dart` with your actual config
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS
- Configure web platform support

### Step 1 (Alternative): Manual Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a project (or use existing)
3. Enable **Realtime Database** (set region)
4. **Android**: Add app with package name `com.infusionpump.infusion_pump_app`
   - Download `google-services.json` → place in `android/app/`
5. **iOS**: Add app with bundle ID `com.infusionpump.infusionPumpApp`
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. **Web**: Add a web app and copy the config values
7. Edit `lib/firebase_options.dart` with your actual config values

### Step 2: Firebase Security Rules

For development (academic project), use open rules:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

> **WARNING**: Never use open rules in production. Restrict to authenticated users.

### Step 3: Install Dependencies

```bash
cd infusion_pump_app
flutter pub get
```

### Step 4: Add Alarm Sound

Place an MP3 alarm sound file at `assets/sounds/alarm.mp3`. You can download one from [Freesound](https://freesound.org/search/?q=medical+alarm).

### Step 5: Run

```bash
# Android
flutter run

# iOS (requires macOS with Xcode)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

### Step 6 (Optional): Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

## Firebase Realtime Database Structure

### Read Paths (from ESP32)
```
/pump/dispensedML          -> Actual dispensed volume (mL)
/pump/expectedVolumeML     -> Expected volume at this time (mL)
/pump/weightGrams          -> Load cell weight reading (g)
/pump/status               -> "running" | "paused" | "complete" | "idle"
/alarms/occlusion          -> true/false
/alarms/bubble             -> true/false
/alarms/bagEmpty           -> true/false
/alarms/complete           -> true/false
```

### Write Paths (to ESP32)
```
/pump/setFlowRateMLperHR   -> Flow rate set by user (mL/hr)
/pump/setVolumeML          -> Target volume set by user (mL)
/pump/command              -> "start" | "pause" | "stop"
/dosing/drugName           -> Drug name (string)
/dosing/patientWeightKg    -> Patient weight (double)
/dosing/calculatedRate     -> Auto-calculated flow rate (mL/hr)
```

### FCM Token Storage
```
/users/{deviceId}/fcmToken -> FCM token for push notifications
```

## ESP32 Calibration Notes

- **Load Cell**: Calibrate using a known weight. Update the calibration factor in the ESP32 firmware.
- **Flow Sensor**: Calibrate by measuring actual dispensed volume against reported value.
- **Alarm Thresholds**: Set occlusion pressure threshold and air bubble sensitivity in ESP32 firmware.
- **Database Latency**: Typical round-trip time to Firebase RTDB is 100-300ms on a stable WiFi connection.

## Platform Configuration

### Android
- **minSdkVersion**: 26 (Android 8.0+)
- **targetSdkVersion**: 34
- **Permissions**: Internet, vibrate, wake lock, foreground service, post notifications
- **FCM**: Configured via `google-services.json` and Cloud Functions

### iOS
- **Minimum iOS Version**: 13.0
- **Background Modes**: fetch, remote-notification
- **Capabilities**: Push Notifications (enable in Xcode)
- **FCM**: Requires APNs certificate/key in Firebase Console

### Web
- **Firebase Config**: Set in `firebase_options.dart`
- **Note**: Audio alarms and background service not available on web

## Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase & FCM setup
├── firebase_options.dart              # Firebase config (all platforms)
├── core/
│   ├── constants/firebase_paths.dart  # RTDB path constants
│   ├── services/
│   │   ├── firebase_service.dart      # Read/write Firebase RTDB
│   │   ├── notification_service.dart  # Local notifications
│   │   ├── background_service.dart    # Background alarm monitoring
│   │   └── audio_service.dart         # Alarm sounds
│   ├── theme/
│   │   ├── app_theme.dart             # Blood Cell dark theme
│   │   └── blood_cell_background.dart # CustomPaint blood cells
│   ├── utils/
│   │   ├── debouncer.dart             # Firebase write debouncer
│   │   └── validators.dart            # Form input validators
│   └── widgets/
│       ├── connection_indicator.dart   # Firebase connection status
│       ├── metric_card.dart           # Reusable metric display
│       ├── shimmer_loading.dart       # Skeleton loading
│       └── status_chip.dart           # Pump status indicator
├── features/
│   ├── dashboard/dashboard_screen.dart
│   ├── alarms/alarms_screen.dart
│   ├── control/control_screen.dart
│   ├── dose_calculator/dose_calculator_screen.dart
│   └── history/history_screen.dart
├── shared/
│   ├── models/
│   │   ├── pump_data.dart
│   │   └── alarm_data.dart
│   ├── providers/firebase_providers.dart
│   └── router/app_router.dart
functions/
├── index.js                           # FCM Cloud Function
└── package.json
```

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## License

Academic project - for educational purposes only. Not for clinical use without proper medical device certification.
