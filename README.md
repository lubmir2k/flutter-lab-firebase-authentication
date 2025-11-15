# Flutter Firebase Authentication Lab

A Flutter application demonstrating Firebase Authentication with email/password sign-in.

## Features

- User registration with email/password
- User sign-in with Firebase Authentication
- Welcome screen showing authenticated user
- Sign-out functionality
- Comprehensive error handling
- Multi-platform support (Web, iOS, Android, macOS, Windows)

## ⚠️ Security Notice

**IMPORTANT:** This repository does NOT include Firebase configuration files for security reasons.

The following files contain sensitive API keys and should NEVER be committed:
- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- `android/app/google-services.json`

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Project Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Email/Password authentication:
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**

### 3. Install Firebase Tools

```bash
# Install Firebase tools
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### 4. Generate Firebase Configuration

```bash
# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure
```

This will:
- Create `lib/firebase_options.dart`
- Generate platform-specific configuration files
- Register your app with Firebase

### 5. Platform-Specific Setup

#### Web
No additional setup required after running `flutterfire configure`.

#### iOS/macOS
GoogleService-Info.plist will be automatically created by `flutterfire configure`.

#### Android
google-services.json will be automatically created by `flutterfire configure`.

## Running the App

### Web (Recommended for testing)
```bash
flutter run -d chrome
```

### macOS
```bash
flutter run -d macos
```

**Note:** macOS requires code signing for keychain access. For development without signing, the app will show keychain errors but Web platform works perfectly.

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart              # Main application with auth implementation
└── firebase_options.dart  # Firebase configuration (gitignored)

ios/Runner/
└── GoogleService-Info.plist  # iOS Firebase config (gitignored)

android/app/
└── google-services.json      # Android Firebase config (gitignored)

macos/Runner/
└── GoogleService-Info.plist  # macOS Firebase config (gitignored)
```

## Testing

1. Run the app on Web: `flutter run -d chrome`
2. Enter an email and password
3. Click **Register** to create a new account
4. Verify navigation to Welcome screen
5. Click **Sign Out**
6. Click **Sign In** with the same credentials
7. Test error handling with invalid credentials

## Known Issues

### macOS Keychain Access
Firebase Auth on macOS requires Apple Developer code signing to access the system keychain. Without signing, you'll see keychain access errors. Use Web platform for testing, which works without any restrictions.

## Security Best Practices

1. **Never commit** Firebase configuration files
2. **Use environment variables** for CI/CD
3. **Rotate API keys** if accidentally exposed
4. **Enable App Check** in production
5. **Use Firebase Security Rules** to protect data

## Dependencies

- `firebase_core: ^3.5.0` - Firebase Core SDK
- `firebase_auth: ^5.3.0` - Firebase Authentication

## License

This is a learning project for Firebase Authentication.

## Support

For issues related to:
- Firebase setup: [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- FlutterFire: [FlutterFire Documentation](https://firebase.flutter.dev/)
- Flutter: [Flutter Documentation](https://docs.flutter.dev/)
