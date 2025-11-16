# Buddy Chat - Flutter Firebase Chat Application

A Flutter chat application demonstrating Firebase Authentication and Cloud Firestore with real-time messaging.

## Features

### Authentication
- User registration with email/password and password confirmation
- User sign-in with Firebase Authentication
- Automatic authentication state management
- Comprehensive error handling
- Sign-out functionality

### Chat Features
- Real-time messaging with Cloud Firestore
- User list showing all registered users
- One-on-one chat conversations
- Avatar management with URL input
- Message timestamps
- Automatic scrolling to latest messages
- Visual distinction between sent and received messages

### User Interface
- Bottom tab navigation (Buddies, Settings)
- Consistent green (#A1EDA4) theme matching React Native version
- Clean, modern Material Design
- Responsive layout

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

2. **Enable Email/Password authentication:**
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**

3. **Create Cloud Firestore database:**
   - Go to **Firestore Database** → **Create database**
   - Select **Start in test mode** (for development)
   - Choose a location close to your users

4. **Create Firestore collections:**

   **Collection: `avatars`**
   - Document ID: (auto-generated)
   - Fields:
     - `email` (string): user email
     - `avatar` (string): avatar URL (e.g., https://i.pravatar.cc/150?img=1)

   **Collection: `chats`**
   - Document ID: (auto-generated)
   - Fields:
     - `_id` (string): unique message ID
     - `createdAt` (timestamp): message timestamp
     - `text` (string): message content
     - `user` (map):
       - `_id` (string): sender email
       - `avatar` (string): sender avatar URL
     - `receiver` (string): receiver email

5. **Create composite indexes** (CRITICAL for chat queries):

   The compound OR query requires ALL three indexes with Ascending sort order:

   **Index 1:**
   - Collection ID: `chats`
   - Fields:
     - `user._id` - Ascending
     - `receiver` - Ascending
     - `createdAt` - Ascending

   **Index 2:**
   - Collection ID: `chats`
   - Fields:
     - `user._id` - Ascending
     - `createdAt` - Ascending

   **Index 3:**
   - Collection ID: `chats`
   - Fields:
     - `receiver` - Ascending
     - `createdAt` - Ascending

   Navigate to: **Firestore Database** → **Indexes** → **Create Index**

   **Important:** All three indexes are required. Create them all before testing the chat feature.

   Note: Indexes take 5-10 minutes to build. The app will error until they're ready.

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
├── main.dart                   # App entry point with auth wrapper & navigation
├── firebase_options.dart       # Firebase configuration (gitignored)
└── screens/
    ├── signup_screen.dart      # User registration
    ├── login_screen.dart       # User sign-in
    ├── list_users_screen.dart  # Buddies list
    ├── chat_screen.dart        # Real-time chat
    └── settings_screen.dart    # Avatar management & sign out

ios/Runner/
└── GoogleService-Info.plist    # iOS Firebase config (gitignored)

android/app/
└── google-services.json        # Android Firebase config (gitignored)

macos/Runner/
└── GoogleService-Info.plist    # macOS Firebase config (gitignored)
```

## Testing

### 1. Create First User
1. Run the app: `flutter run -d chrome`
2. You'll see the **SignUp** screen
3. Enter email, password, and confirm password
4. Click **Sign Up**
5. You'll be automatically logged in to the Buddies tab

### 2. Set Up Avatar
1. Click the **Settings** tab
2. Enter an avatar URL:
   - For web: `https://api.dicebear.com/7.x/avataaars/svg?seed=yourname` (CORS-friendly)
   - For mobile: `https://i.pravatar.cc/150?img=1` works fine
3. Click **Save Changes**
4. Avatar preview will update (on web, CORS may prevent some URLs from displaying)

### 3. Create Second User (for testing chat)
1. Click **Sign Out** in Settings
2. On the SignUp screen, click **Log In** at the bottom
3. Click **Sign Up** to go back
4. Register a different email/password
5. Set up an avatar for this user too

### 4. Test Chat
1. Click the **Buddies** tab
2. You'll see both users listed (you first, then others)
3. Click on the other user
4. Type a message and click send
5. Sign out and log in as the other user
6. Open the chat - you'll see the message in real-time!

### 5. Test Real-time Updates
1. Open the app in two browser tabs
2. Sign in as different users in each tab
3. Start a conversation
4. Messages appear instantly in both tabs

## Features Implementation

### Authentication Flow
- `StreamBuilder` listens to `authStateChanges()`
- Unauthenticated users see SignUp/Login screens
- Authenticated users see Bottom Tab Navigator

### Chat Queries
Uses Firebase Compound OR queries to fetch all messages between two users:

```dart
Filter.or(
  Filter.and(
    Filter('user._id', isEqualTo: currentUser),
    Filter('receiver', isEqualTo: otherUser),
  ),
  Filter.and(
    Filter('user._id', isEqualTo: otherUser),
    Filter('receiver', isEqualTo: currentUser),
  ),
)
```

Requires composite indexes created in Firebase Console.

### Real-time Updates
- `StreamBuilder` with `.snapshots()` for live message updates
- Automatic UI refresh when new messages arrive
- Auto-scroll to latest message after sending

## Known Issues

### macOS Keychain Access
Firebase Auth on macOS requires Apple Developer code signing to access the system keychain. Without signing, you'll see keychain access errors. Use Web platform for testing, which works without any restrictions.

### Firestore Index Build Time
After creating composite indexes, allow 5-10 minutes for them to build. The chat screen will show errors until indexes are ready.

### Avatar Images Not Loading (Web Only)
Due to CORS (Cross-Origin Resource Sharing) restrictions, some avatar image URLs may not display in web browsers. The URLs are saved correctly in Firestore, but browsers block loading them.

**Solutions:**
- Use CORS-friendly services like Dicebear: `https://api.dicebear.com/7.x/avataaars/svg?seed=yourname`
- Upload images to Firebase Storage
- Images from `i.pravatar.cc` work fine on native platforms (iOS/Android) but are blocked on web

## Security Best Practices

1. **Never commit** Firebase configuration files
2. **Use Firestore Security Rules** in production:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /chats/{chatId} {
         allow read, write: if request.auth != null;
       }
       match /avatars/{avatarId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null &&
                        request.resource.data.email == request.auth.token.email;
       }
     }
   }
   ```
3. **Enable App Check** in production
4. **Rotate API keys** if accidentally exposed (see below)

## Rotating API Keys (If Exposed)

If you accidentally commit Firebase credentials to git, follow these steps immediately:

### Option 1: Delete and Regenerate (Recommended)

1. **Delete the exposed API key:**
   - Go to [Google Cloud Console → API & Services → Credentials](https://console.cloud.google.com/apis/credentials)
   - Find and delete the exposed API key

2. **Regenerate Firebase configuration:**
   ```bash
   # This will create new API keys automatically
   flutterfire configure
   ```
   - Select your existing Firebase project
   - Choose the same platforms as before
   - New configuration files will be generated with fresh API keys

3. **Verify new keys are working:**
   ```bash
   flutter run -d chrome
   ```

4. **Clean up git history:**
   - If credentials were pushed to GitHub, consider the repository compromised
   - You may need to force-push a cleaned history or create a new repository

## Dependencies

- `firebase_core: ^3.5.0` - Firebase Core SDK
- `firebase_auth: ^5.3.0` - Firebase Authentication
- `cloud_firestore: ^5.4.4` - Cloud Firestore for real-time database
- `intl: ^0.19.0` - Date/time formatting

## Architecture

### React Native → Flutter Equivalents

| React Native | Flutter |
|-------------|---------|
| `useAuthentication()` hook | `StreamBuilder<User?>` with `authStateChanges()` |
| `FlatList` | `ListView.builder` |
| `react-native-gifted-chat` | Custom chat UI with `ListView` |
| `Stack.Navigator` | Named routes with `Navigator` |
| `Tab.Navigator` | `BottomNavigationBar` |
| `onSnapshot` | `snapshots()` stream |
| `useState` | `StatefulWidget` with `setState()` |

## License

This is a learning project demonstrating Firebase Authentication and Firestore with Flutter.

## Support

For issues related to:
- Firebase setup: [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- FlutterFire: [FlutterFire Documentation](https://firebase.flutter.dev/)
- Firestore queries: [Firestore Documentation](https://firebase.google.com/docs/firestore)
- Flutter: [Flutter Documentation](https://docs.flutter.dev/)
