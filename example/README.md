# NotificationAPI Flutter SDK Example

This example app demonstrates how to integrate and test the NotificationAPI Flutter SDK locally without publishing to pub.dev.

## Setup Instructions

### 1. Prerequisites

- Flutter SDK installed (3.0.0 or higher)
- iOS Simulator/Android Emulator or physical device
- NotificationAPI account and client ID

### 2. Configure the Example App

1. **Update Client ID**: Open `lib/main.dart` and replace the hardcoded values:

   ```dart
   String _userId = 'user123';  // Change to your test user ID
   String _clientId = 'your-client-id-here';  // Change to your actual client ID
   ```

2. **Configure for iOS** (if testing on iOS):

   - Open `ios/Runner.xcworkspace` in Xcode
   - Configure push notification capabilities
   - Add your provisioning profile and signing

3. **Configure for Android** (if testing on Android):
   - Add your `google-services.json` file to `android/app/`
   - Ensure Firebase is properly configured

### 3. Run the Example

```bash
cd example
flutter run
```

## Features Demonstrated

The example app showcases all major SDK features:

### ✅ Initialization

- Simple one-call setup with `NotificationAPI.setup()`
- Configuration options (client ID, user ID, permissions, foreground notifications)

### ✅ Permission Management

- Automatic permission requests
- Manual permission requests
- Permission status monitoring

### ✅ Notification Handling

- Foreground notification display
- Background notification handling
- Notification tap handling
- Deep link support

### ✅ User Management

- User identification
- Token synchronization
- Device information collection

### ✅ Configuration Options

- Toggle foreground notifications on/off
- Real-time status monitoring
- Debug logging

## How to Test

### Basic Flow

1. **Configure**: Enter your client ID and user ID
2. **Initialize**: Tap "Initialize SDK" to set up the SDK
3. **Grant Permission**: Tap "Request Permission" if needed
4. **Send Test Notification**: Use your NotificationAPI dashboard to send a test notification
5. **Observe**: Check the "Notifications" tab to see received notifications

### Testing Scenarios

#### Scenario 1: Foreground Notifications

1. Keep the app open
2. Send a notification from your dashboard
3. Verify it appears both as a native notification and in the app's notification list

#### Scenario 2: Background Notifications

1. Send the app to background (home button)
2. Send a notification
3. Verify the native notification appears
4. Tap the notification to open the app
5. Check the "Notifications" tab

#### Scenario 3: App Terminated

1. Force close the app
2. Send a notification
3. Tap the notification to launch the app
4. Verify the notification appears in the "Notifications" tab

#### Scenario 4: Permission Scenarios

1. Test with permission granted
2. Test with permission denied
3. Test with permission initially denied, then granted later

## Debugging

### Logs Tab

The "Logs" tab shows real-time debug information including:

- SDK initialization status
- Permission requests and responses
- Token generation events
- Error messages

### Console Logs

Check the Flutter console/logs for additional debugging information:

```bash
flutter logs
```

## Common Issues

### Import Errors

If you see import errors, ensure you've run:

```bash
flutter pub get
```

### Permission Issues

- **iOS**: Ensure proper provisioning and capabilities are configured
- **Android**: Verify Firebase configuration and google-services.json

### Notifications Not Received

1. Check your client ID is correct
2. Verify user ID matches what you're targeting
3. Ensure device has internet connection
4. Check NotificationAPI dashboard for delivery status

## Local Development

This example uses the local SDK via:

```yaml
notificationapi_flutter_sdk:
  path: ../
```

This means any changes you make to the main SDK will be reflected immediately in the example app with hot reload.

## Testing Different Configurations

You can modify the hardcoded values and initialization parameters in `main.dart` to test different configurations:

```dart
// Change these values in the class
String _userId = 'your-test-user';
String _clientId = 'your-actual-client-id';

// Modify setup parameters in _initializeNotificationAPI()
await NotificationAPI.setup(
  clientId: _clientId,
  userId: _userId,
  hashedUserId: 'optional-hashed-id', // Add this for privacy
  autoRequestPermission: false,        // Test manual permission flow
  showForegroundNotifications: false,  // Test background-only mode
);
```

## Next Steps

Once you've verified the SDK works correctly with this example:

1. Integrate the SDK into your actual app
2. Test in production environment
3. Publish the SDK to pub.dev
4. Update your app to use the published version
