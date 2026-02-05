# 📋 CR Attendance Tracker

A modern Flutter mobile application for Class Representatives to efficiently track student attendance with offline-first SQLite storage, dark mode, and WhatsApp integration — built with Flutter and designed for real-world classroom use.

## 🚀 Features

### 📱 Student Side
- **Quick attendance marking** with tap-to-toggle (P → A → L)
- **Smart import** from text (numbered lists or comma-separated)
- **Real-time search** by name or ID
- **Mobile-optimized** responsive UI

### 🛠️ CR Side
- **Manage attendance** for 58 students
- **7-day history** with calendar view
- **Export to WhatsApp** or clipboard
- **Customizable settings** (class name, font size, sorting)

### 🔐 Data Management
- **Offline-first** SQLite persistence
- **Auto-cleanup** (records older than 7 days)
- **Safe overwrite protection** with confirmation dialogs

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **Database** | SQLite (sqflite) |
| **Storage** | SharedPreferences |
| **UI** | Material Design 3 |
| **Sharing** | url_launcher (WhatsApp) |

## 📁 Project Structure

```text
attendance_app_flutter/
├── lib/
│   ├── db/
│   │   └── database_helper.dart
│   ├── models/
│   │   ├── student.dart
│   │   └── attendance.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── attendance_screen.dart
│   │   ├── import_attendance_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   └── main.dart
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

## ⚙️ Dependencies

This project uses the following Flutter packages:

```yaml
sqflite: ^2.3.0              # SQLite database
path: ^1.8.3                 # Path utilities
intl: ^0.18.1                # Date formatting
table_calendar: ^3.0.9       # Calendar widget
shared_preferences: ^2.2.2   # Settings storage
url_launcher: ^6.2.0         # WhatsApp sharing
```

## 🐳 Quick Start (Android – Recommended)

1. **Get Dependencies**
   ```sh
   flutter pub get
   ```

2. **Build Release APK**
   ```sh
   flutter build apk --release
   ```

3. **Install on Device**
   Transfer `build/app/outputs/flutter-apk/app-release.apk` to your phone

## 💻 Quick Start (iOS)

1. **Open in Xcode (macOS required)**
   ```sh
   cd ios
   open Runner.xcworkspace
   ```

2. **Run the Application**
   - Select your device/simulator
   - Click Run (▶️)

3. **Access Application**
   App will launch on your iPhone

## 🌍 Deployment (Production)

This application is deployment-ready and can be distributed via:
- Direct APK installation (Android)
- TestFlight / App Store (iOS)
- Enterprise distribution

### Production Checklist
- [x] SQLite persistence configured
- [x] WhatsApp integration tested
- [x] Dark mode implemented
- [x] Offline-first architecture
- [ ] App Store submission (optional)

## 📖 Usage Guide

### Marking Attendance
1. Open app → **"Mark Attendance"**
2. Select session (FN/AN)
3. Tap student cards to toggle status
4. **"Save"** to persist

### Importing Attendance
1. Copy text from another CR
2. **"Import Attendance"**
3. Paste → **"Import & Continue Editing"**

### Sharing via WhatsApp
1. After marking → **"COPY"**
2. Select format (Numbers / Names)
3. **"Share via WhatsApp"**

## 🐛 Troubleshooting

### App crashes on startup
- Use **Release APK**, not Debug
- Check Android version (5.0+)

### WhatsApp not working
- Ensure WhatsApp is installed
- Check internet connection

### Import parsing fails
- Verify format: `DD.MM.YYYY    FN`
- Check example format in app

## 🚀 Features

### 📱 Core Functionality
- **Quick attendance marking** with tap-to-toggle (Present → Absent → Late)
- **Smart import** from text (supports numbered lists and comma-separated formats)
- **Flexible export** (Numbers only / Numbers + Names)
- **7-day history** with calendar view
- **Real-time search** by name or ID
- **Status filters** (All/Present/Absent/Late)

### 🎨 User Experience
- **Premium dashboard** with gradient themes
- **Dark mode** with one-tap toggle
- **Offline-first** SQLite persistence
- **WhatsApp integration** for instant sharing
- **Customizable settings** (class name, font size, sorting)

### 🔐 Data Management
- **Auto-cleanup** (records older than 7 days)
- **Edit past attendance** via history screen
- **Safe overwrite protection** with confirmation dialogs

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **Database** | SQLite (sqflite) |
| **Storage** | SharedPreferences |
| **UI** | Material Design 3 |
| **Sharing** | url_launcher (WhatsApp) |

## 📁 Project Structure

```text
attendance_app_flutter/
├── lib/
│   ├── db/
│   │   └── database_helper.dart       # SQLite operations
│   ├── models/
│   │   ├── student.dart               # Student model
│   │   └── attendance.dart            # Attendance model
│   ├── screens/
│   │   ├── home_screen.dart           # Dashboard
│   │   ├── attendance_screen.dart     # Main marking UI
│   │   ├── import_attendance_screen.dart
│   │   ├── history_screen.dart        # Calendar view
│   │   └── settings_screen.dart
│   └── main.dart
├── android/                           # Android config
├── ios/                               # iOS config
└── pubspec.yaml
```

## 📦 Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0              # SQLite database
  path: ^1.8.3                 # Path utilities
  intl: ^0.18.1                # Date formatting
  table_calendar: ^3.0.9       # Calendar widget
  shared_preferences: ^2.2.2   # Settings storage
  url_launcher: ^6.2.0         # WhatsApp sharing
```

## 🐳 Quick Start (Android)

### Prerequisites
- Flutter SDK installed
- Android device or emulator

### Build & Install

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd attendance_app_flutter
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Build Release APK**
   ```bash
   flutter build apk --release
   ```

4. **Install on device**
   ```bash
   flutter install -d <device-id>
   ```
   Or manually transfer:
   `build/app/outputs/flutter-apk/app-release.apk`

## 🍎 Quick Start (iOS)

### Prerequisites
- macOS with Xcode installed
- iOS device or simulator

### Build & Run

1. **Open iOS project**
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. **Run from Xcode**
   - Select your device/simulator
   - Click Run (▶️)

## 📖 Usage Guide

### Marking Attendance
1. Open app → Tap **"Mark Attendance"**
2. Select session (FN/AN)
3. Tap student cards to toggle status
4. Tap **"Save"** to persist

### Importing Attendance
1. Copy attendance text from another CR
2. Tap **"Import Attendance"**
3. Paste text → Tap **"Import & Continue Editing"**
4. Review and save

### Sharing via WhatsApp
1. After marking attendance
2. Tap **"COPY"** → Select format
3. Tap **"Share via WhatsApp"**
4. Select contact and send

### Viewing History
1. Tap **"History"** from dashboard
2. Select date from calendar
3. View/edit past attendance

## 🎨 Customization

Access **Settings** to customize:
- Class name
- Font size (Small/Medium/Large)
- Sorting preference (Name/ID/Status)
- Dark mode toggle

## 🔧 Configuration

### Android Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
- WhatsApp query permissions
- Internet access (for future features)

### iOS Permissions
Already configured in `ios/Runner/Info.plist`:
- URL scheme queries (WhatsApp)

## 🌍 Deployment

### Android
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **File size**: ~47-50 MB
- **Min SDK**: 21 (Android 5.0+)

### iOS
- Build via Xcode on macOS
- Requires Apple Developer account for distribution

## 🐛 Troubleshooting

### App crashes on startup
- Ensure you're using the **Release APK**, not Debug
- Check device Android version (5.0+)

### WhatsApp button not working
- Ensure WhatsApp is installed
- Check internet connection

### Import not parsing correctly
- Verify format matches examples
- Ensure date format is DD.MM.YYYY

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

Built with ❤️ for Class Representatives

---

**Need help?** Open an issue on GitHub or contact the developer.
