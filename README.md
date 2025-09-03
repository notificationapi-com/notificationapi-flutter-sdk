# NotificationAPI Flutter SDK

A Flutter plugin for integrating [NotificationAPI](https://notificationapi.com) push notifications into your mobile app.

## 🚀 Push Notification Support

**Cross-platform push notifications with native performance:**

- **Android**: Full FCM (Firebase Cloud Messaging) support
- **iOS**: Direct APN (Apple Push Notifications) integration - no Firebase routing required!

This means you get native iOS push notifications with reduced latency and fewer dependencies.

## 🚀 Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  notificationapi_flutter_sdk: ^2.1.0
```

### 2. Setup (One Line!)

```dart
import 'package:notificationapi_flutter_sdk/notificationapi_flutter_sdk.dart';

// That's it! This handles initialization, user identification, and permission requests
await NotificationAPI.setup(
  clientId: 'your_client_id_here',
  userId: 'user123',
  autoRequestPermission: true, // automatically request push permissions
  showForegroundNotifications: true, // show native notifications when app is open
  region: 'eu', // 'us' (default), 'eu', or 'ca'
);
```

### 3. Listen to Notifications (Optional)

```dart
// Listen to notifications received while app is open
// Note: These are automatically shown as native notifications by default
NotificationAPI.onMessage.listen((notification) {
  print('Received: ${notification.title}');
  // Optional: Handle notification data or custom actions
});

// Listen to notifications that opened the app
NotificationAPI.onMessageOpenedApp.listen((notification) {
  print('App opened from: ${notification.title}');
  // Handle deep linking or navigation
});
```

### 4. Check Status

```dart
// Check if everything is ready
if (NotificationAPI.isReady) {
  print('NotificationAPI is ready to receive notifications!');
}

// Get the push token (FCM on Android, APN on iOS)
String? token = await NotificationAPI.getToken();
```

## 📱 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:notificationapi_flutter_sdk/notificationapi_flutter_sdk.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    try {
      await NotificationAPI.setup(
        clientId: 'your_client_id',
        userId: 'user123',
        showForegroundNotifications: true, // Auto-show native notifications
      );

      // Optional: Listen for custom handling
      NotificationAPI.onMessage.listen((notification) {
        print('Foreground notification: ${notification.title}');
        // Notification is automatically displayed as native notification
      });

      NotificationAPI.onMessageOpenedApp.listen((notification) {
        print('App opened from notification: ${notification.title}');
        // Handle navigation or deep linking
        if (notification.deepLink != null) {
          // Navigate to specific screen
        }
      });
    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('NotificationAPI Example')),
        body: Center(
          child: Column(
            children: [
              Text('Ready: ${NotificationAPI.isReady}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool granted = await NotificationAPI.requestPermission();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permission: ${granted ? "Granted" : "Denied"}')),
                  );
                },
                child: Text('Request Permission'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Toggle foreground notification display
                  NotificationAPI.setShowForegroundNotifications(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Foreground notifications disabled')),
                  );
                },
                child: Text('Disable Foreground Notifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🌙 Background Notifications (App Closed)

Background notifications are automatically handled by the push package. The SDK uses:

- **FCM** for Android background notifications
- **APN** for iOS background notifications

No additional setup is required for basic background notification handling.

### Handling Notification Taps

When users tap a notification while the app is terminated, it's automatically handled:

```dart
class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    await NotificationAPI.setup(
      clientId: 'your_client_id',
      userId: 'user123',
    );

    // Handle notifications that opened the app
    NotificationAPI.onMessageOpenedApp.listen((notification) {
      _handleNotificationTap(notification);
    });
  }

  void _handleNotificationTap(PushNotification notification) {
    print('Notification tapped: ${notification.title}');

    // Handle deep linking or navigation
    if (notification.deepLink != null) {
      // Navigate to specific screen
      Navigator.pushNamed(context, notification.deepLink!);
    }
  }
}
```

### Platform-Specific Setup

#### Android

- Requires Firebase setup for FCM
- Background notifications work automatically

#### iOS

- Uses native APN - no Firebase required!
- Requires Apple Developer Program membership
- Enable Push Notifications capability in Xcode
- Background notifications work automatically

## 🔔 Native Notification Display

### Automatic Foreground Notifications

By default, when `showForegroundNotifications: true` is set in `setup()`, the SDK automatically displays received notifications as **native push notifications** even when your app is in the foreground. This provides a consistent user experience.

### Notification Behavior

| App State      | Notification Display                         |
| -------------- | -------------------------------------------- |
| **Foreground** | Native notification banner/alert (automatic) |
| **Background** | System notification (handled by OS)          |
| **Terminated** | System notification (handled by OS)          |

### Customization Options

```dart
await NotificationAPI.setup(
  // ... other parameters
  showForegroundNotifications: true,  // Enable native notifications in foreground
);

// You can also toggle this later
NotificationAPI.setShowForegroundNotifications(false); // Disable
NotificationAPI.setShowForegroundNotifications(true);  // Re-enable
```

## 🔧 API Reference

### NotificationAPI

| Method                             | Description                                                                         | Returns                    |
| ---------------------------------- | ----------------------------------------------------------------------------------- | -------------------------- |
| `setup()`                          | One-call setup with initialization, identification, and optional permission request | `Future<void>`             |
| `requestPermission()`              | Request push notification permission                                                | `Future<bool>`             |
| `getToken()`                       | Get the current push token (FCM on Android, APN on iOS)                             | `Future<String?>`          |
| `onMessage`                        | Stream of foreground notifications (auto-displayed as native notifications)         | `Stream<PushNotification>` |
| `onMessageOpenedApp`               | Stream of notifications that opened the app                                         | `Stream<PushNotification>` |
| `currentUser`                      | Get current user info                                                               | `NotificationUser?`        |
| `isReady`                          | Check if SDK is ready                                                               | `bool`                     |
| `setShowForegroundNotifications()` | Enable/disable automatic native notification display                                | `void`                     |

### Setup Parameters

```dart
await NotificationAPI.setup({
  required String clientId,                  // Your NotificationAPI client ID
  required String userId,                    // User's unique identifier
  String? hashedUserId,                     // Hashed user ID for privacy (optional)
  String region = 'us',                     // 'us' (default), 'eu', or 'ca'
  bool autoRequestPermission = true,        // Auto-request push permission (optional)
  bool showForegroundNotifications = true,  // Auto-show native notifications (optional)
});
```

## 🔒 Privacy & Security

- User IDs can be hashed for additional privacy
- All communication uses HTTPS
- Push tokens are securely stored in NotificationAPI backend

## 🛠️ Platform Setup

### Android (Firebase Required)

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android app to the project
3. Download `google-services.json` and place it in `android/app/`
4. Follow the [FlutterFire setup guide](https://firebase.flutter.dev/docs/overview#installation)

### iOS (No Firebase Required!)

1. Requires Apple Developer Program membership ($99/year)
2. Enable Push Notifications capability in Xcode
3. Create APNs key in Apple Developer Console
4. Configure your server to send notifications directly to APNs

## 🐛 Troubleshooting

### Common Issues

1. **Notifications not received**

   - **Android**: Verify Firebase setup is correct
   - **iOS**: Ensure APNs key is configured correctly
   - Check if permission was granted: `await NotificationAPI.requestPermission()`
   - Ensure your NotificationAPI client ID is correct

2. **Foreground notifications not showing**

   - Make sure `showForegroundNotifications: true` in setup
   - Check that notification permissions are granted
   - Verify app is actually in foreground

3. **Token is null**

   - **Android**: Firebase may not be properly initialized
   - **iOS**: APNs may not be properly configured
   - Check device/simulator supports push notifications

4. **iOS Specific Issues**

   - Ensure you have an Apple Developer Program membership
   - Push Notifications capability must be enabled in Xcode
   - APNs keys must be properly configured on your server

5. **Android Specific Issues**
   - Verify `google-services.json` is in the correct location
   - Check that Firebase project includes your Android app's package name

## 📞 Support

- [Documentation](https://docs.notificationapi.com)
- [GitHub Issues](https://github.com/notificationapi-com/notificationapi-flutter-sdk/issues)
- [Email Support](mailto:support@notificationapi.com)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
