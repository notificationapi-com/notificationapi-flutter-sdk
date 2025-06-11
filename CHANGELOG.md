# Changelog

All notable changes to this project will be documented in this file.

## [2.0.5] - 2024-03-21

### Changed

- 📦 **Package update** - Provided better utility methods for push token management

## [2.0.4] - 2024-03-21

### Fixed

- 🔧 **Permission handling** - Fixed issue where notification permission is revoked but was previously granted

## [2.0.2] - 2024-12-20

### Fixed

- 🔧 **Notification parsing** - Fixed title and body extraction from push messages to correctly handle backend data format
- 📱 **FCM compatibility** - Now properly extracts title and body from `data` field for FCM notifications
- 🍎 **APN compatibility** - Now properly extracts title and body from `alert` object for APN notifications
- 🔄 **Backward compatibility** - Maintains fallback to standard notification fields if custom format not found

## [2.0.1] - 2024-12-20

### Fixed

- 🔧 **Package publishing** - Minor fixes and improvements for pub.dev compatibility

## [2.0.0] - 2024-12-20

### BREAKING CHANGES

- 🚀 **Native APN support for iOS** - iOS now uses Apple Push Notifications directly, no Firebase routing required
- 🔥 **Removed Firebase dependencies for iOS** - Eliminated `firebase_messaging` and `firebase_core` dependencies
- 📱 **Platform-specific push tokens** - FCM tokens on Android, APN tokens on iOS
- ⚡ **Improved performance** - Reduced latency for iOS notifications by removing Firebase intermediate step

### Added

- 🍎 **Direct APN integration** - Native iOS push notifications without Firebase
- 🎯 **Cross-platform push package** - Unified push notification handling across platforms
- 🔧 **Simplified architecture** - Removed service abstraction layer for cleaner code

### Changed

- **iOS setup** - No longer requires Firebase configuration on iOS
- **Token handling** - Platform-specific token types (APN for iOS, FCM for Android)
- **Dependencies** - Replaced Firebase dependencies with `push: ^3.3.3` package
- **Performance** - Faster iOS notification delivery through direct APN connection

### Removed

- Firebase dependencies for iOS (`firebase_messaging`, `firebase_core`)
- Push notification service abstraction layer
- Firebase initialization requirement for iOS

### Migration Guide

**For iOS developers:**

- Remove Firebase configuration files if only using for push notifications
- No code changes required - API remains the same
- Enjoy faster notification delivery!

**For Android developers:**

- Firebase setup still required for FCM
- No code changes required

### Dependencies

- `push: ^3.3.3` (replaces Firebase dependencies)
- `flutter_local_notifications: ^17.2.2`
- `http: ^1.1.0`
- `shared_preferences: ^2.2.2`
- `device_info_plus: ^10.1.0`

## [1.0.3] - 2024-12-20

### Fixed

- 🔧 **Android namespace declaration** - Added required `namespace` property to `build.gradle` for modern Android Gradle Plugin compatibility
- 🐛 **AGP compatibility** - Resolved "Namespace not specified" error with newer Android Gradle Plugin versions
- 📱 **Build configuration** - Ensured proper namespace declaration as required by current Android tooling standards

## [1.0.2] - 2024-12-20

### Fixed

- 🔧 **Android build configuration** - Added missing `build.gradle`, `AndroidManifest.xml`, and `gradle.properties` files
- 🐛 **Flutter 3.32.0 compatibility** - Resolved "Configuration with name 'implementation' not found" errors
- ⚙️ **Gradle setup** - Fixed NullPointerException during project evaluation
- 📱 **Plugin integration** - Ensured proper Android plugin structure for modern Flutter versions

### Technical Details

- Added complete Android build configuration with Kotlin support
- Included AndroidX compatibility settings
- Added proper Gradle plugin declarations and dependency management
- Fixed plugin structure to meet current Flutter plugin standards

## [1.0.1] - 2024-12-20

### Changed

- Published under verified publisher `notificationapi.com`
- No functional changes from 1.0.0

## [1.0.0] - 2024-12-20

### Added

- 🚀 **One-line setup** - Single `NotificationAPI.setup()` call replaces complex multi-step initialization
- 🔔 **Automatic native notifications** - Built-in foreground notification display with `flutter_local_notifications`
- 📱 **Cross-platform support** - Full iOS and Android compatibility
- 🌙 **Background notification handling** - Complete support for notifications when app is closed/terminated
- 🔐 **Automatic permission management** - Optional auto-request of push notification permissions
- 🎯 **Deep linking support** - Handle navigation when notifications are tapped
- 💾 **User persistence** - Automatic user data storage across app launches
- 🔄 **Token management** - Automatic FCM token retrieval and backend synchronization
- 🛡️ **Graceful error handling** - No thrown exceptions, returns safe defaults
- 📊 **Real-time streams** - Listen to foreground and tap events with reactive streams

### Features

- Simplified API replacing complex client/service architecture
- Firebase Messaging integration
- Local notification display in foreground
- SharedPreferences-based user persistence
- HTTP-based backend communication
- Comprehensive example app
- Detailed documentation with setup guides

### Dependencies

- `firebase_messaging: ^14.7.9`
- `firebase_core: ^2.24.2`
- `flutter_local_notifications: ^17.2.2`
- `http: ^1.1.0`
- `shared_preferences: ^2.2.2`

### Platform Support

- **Flutter**: >=3.0.0
- **Dart**: >=3.0.0 <4.0.0
- **iOS**: iOS 10.0+
- **Android**: API level 21+ (Android 5.0)
