import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/push.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'models/push_notification.dart';
import 'models/notification_models.dart';
import 'services/notificationapi_service.dart';

/// Simplified NotificationAPI interface for end-developers
class NotificationAPI {
  static NotificationAPI? _singleton;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static bool _showForegroundNotifications = true;

  final Push _push = Push.instance;
  NotificationAPIService? _notificationApiService;
  String? _userId;

  final StreamController<PushNotification> _messageController =
      StreamController<PushNotification>.broadcast();
  final StreamController<PushNotification> _messageOpenedController =
      StreamController<PushNotification>.broadcast();

  /// Private constructor for singleton pattern
  NotificationAPI._internal();

  /// Get the singleton instance
  static NotificationAPI get _instance {
    _singleton ??= NotificationAPI._internal();
    return _singleton!;
  }

  /// Setup NotificationAPI with one simple call
  ///
  /// This combines initialization and user identification into a single step.
  ///
  /// [clientId] - Your NotificationAPI client ID
  /// [userId] - The user's unique identifier
  /// [hashedUserId] - Hashed user ID for privacy (optional)
  /// [autoRequestPermission] - Automatically request push notification permission (default: true)
  /// [showForegroundNotifications] - Show native notifications when app is in foreground (default: true)
  static Future<void> setup({
    required String clientId,
    required String userId,
    String? hashedUserId,
    bool autoRequestPermission = true,
    bool showForegroundNotifications = true,
  }) async {
    try {
      _showForegroundNotifications = showForegroundNotifications;

      // Initialize local notifications if enabled
      if (_showForegroundNotifications) {
        await _initializeLocalNotifications();
      }

      // Store user info
      _instance._userId = userId;

      // Initialize NotificationAPI service
      _instance._notificationApiService = NotificationAPIService(
        clientId: clientId,
        userId: userId,
        hashedUserId: hashedUserId,
      );

      // Initialize push notifications
      await _instance._initializePushNotifications();

      // Check if we already have a token (user has permission)
      final existingToken = await _instance._push.token;

      if (existingToken != null && existingToken.isNotEmpty) {
        // Scenario 3: User already has permission, sync existing token
        await _instance._identifyWithToken(existingToken);
      } else if (autoRequestPermission) {
        // Scenario 1: Request permission and sync token if granted
        final permissionGranted = await requestPermission();
        if (permissionGranted) {
          // Give a small delay for token generation, then sync
          await Future.delayed(const Duration(milliseconds: 500));
          final newToken = await _instance._push.token;
          if (newToken != null && newToken.isNotEmpty) {
            await _instance._identifyWithToken(newToken);
          }
        }
        // Scenario 2: Permission rejected - nothing happens (handled automatically)
      }

      // Setup automatic foreground notification display
      if (_showForegroundNotifications) {
        _setupForegroundNotificationHandler();
      }
    } catch (e) {
      throw NotificationAPIException('Failed to setup NotificationAPI: $e');
    }
  }

  /// Initialize push notifications with the push package
  Future<void> _initializePushNotifications() async {
    // Handle foreground messages
    _push.addOnMessage((message) {
      final notification = PushNotification.fromPushMessage(message);
      _messageController.add(notification);
    });

    // Handle background messages
    _push.addOnBackgroundMessage((message) {
      final notification = PushNotification.fromPushMessage(message);
      _messageController.add(notification);
    });

    // Handle notification taps
    _push.addOnNotificationTap((data) {
      final dataMap = Map<String, dynamic>.from(data);
      final notification = PushNotification.fromNotificationTap(dataMap);
      _messageOpenedController.add(notification);
    });

    // Handle messages when app is terminated
    _push.notificationTapWhichLaunchedAppFromTerminated.then((data) {
      if (data != null) {
        final dataMap = Map<String, dynamic>.from(data);
        final notification = PushNotification.fromNotificationTap(dataMap);
        _messageOpenedController.add(notification);
      }
    });

    // Handle token refresh AND initial token - this is the main sync point
    _push.addOnNewToken((token) async {
      try {
        await _identifyWithToken(token);
      } catch (e) {
        print('Error handling new token: $e');
        // Retry once after a delay
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            await _identifyWithToken(token);
          } catch (retryError) {
            print('Retry failed for new token: $retryError');
          }
        });
      }
    });
  }

  /// Identify user with backend when token is available
  Future<void> _identifyWithToken(String token) async {
    if (_userId == null || _notificationApiService == null) return;

    try {
      // Get device information
      final device = await _createDeviceInfo();

      // Create push token with appropriate type based on platform
      final pushToken = PushToken(
        type: Platform.isIOS ? PushProvider.apn : PushProvider.fcm,
        token: token,
        device: device,
      );

      // Create User object for identify call
      final apiUser = User(
        id: _userId!,
        pushTokens: [pushToken],
      );

      // Identify user with the backend
      await _notificationApiService!.identify(apiUser);
    } catch (e) {
      print('Error identifying user with token: $e');
    }
  }

  /// Create device information for the current platform
  Future<Device> _createDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId;
    String? manufacturer;
    String? model;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // Android ID
      manufacturer = androidInfo.manufacturer;
      model = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      manufacturer = 'Apple';
      model = iosInfo.model;
    } else {
      deviceId = 'unknown_device';
    }

    return Device(
      deviceId: deviceId,
      platform: _getPlatform(),
      manufacturer: manufacturer,
      model: model,
    );
  }

  /// Get current platform string
  String _getPlatform() {
    if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isAndroid) {
      return 'android';
    } else {
      return 'flutter';
    }
  }

  /// Initialize local notifications plugin
  static Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(initSettings);
  }

  /// Setup automatic foreground notification display
  static void _setupForegroundNotificationHandler() {
    onMessage.listen((notification) async {
      if (_localNotifications != null) {
        await _showLocalNotification(notification);
      }
    });
  }

  /// Show a local notification
  static Future<void> _showLocalNotification(
      PushNotification notification) async {
    if (_localNotifications == null) return;

    const androidDetails = AndroidNotificationDetails(
      'notificationapi_channel',
      'NotificationAPI',
      channelDescription: 'NotificationAPI push notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications!.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.deepLink,
    );
  }

  /// Request permission for push notifications
  ///
  /// Returns true if permission was granted, false otherwise
  static Future<bool> requestPermission() async {
    try {
      // Request local notification permission if enabled
      if (_showForegroundNotifications && _localNotifications != null) {
        await _localNotifications!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        await _localNotifications!
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      return await _instance._push.requestPermission();
    } catch (e) {
      // Return false instead of throwing to make it more user-friendly
      return false;
    }
  }

  /// Stream of notifications received while app is in foreground
  /// Note: If showForegroundNotifications is enabled in setup(), these will automatically
  /// be displayed as native notifications
  static Stream<PushNotification> get onMessage {
    try {
      return _instance._messageController.stream;
    } catch (e) {
      // Return empty stream instead of throwing
      return const Stream.empty();
    }
  }

  /// Stream of notifications that opened the app from background/terminated state
  static Stream<PushNotification> get onMessageOpenedApp {
    try {
      return _instance._messageOpenedController.stream;
    } catch (e) {
      // Return empty stream instead of throwing
      return const Stream.empty();
    }
  }

  /// Get the current user information
  ///
  /// Returns null if no user is identified
  static String? get currentUser => _instance._userId;

  /// Check if NotificationAPI is properly initialized and user is identified
  static bool get isReady => _instance._userId != null;

  /// Enable or disable automatic foreground notification display
  static void setShowForegroundNotifications(bool enabled) {
    _showForegroundNotifications = enabled;
    if (enabled && _localNotifications == null) {
      _initializeLocalNotifications().then((_) {
        _setupForegroundNotificationHandler();
      });
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
    _messageOpenedController.close();
  }
}

/// Simple exception class for NotificationAPI errors
class NotificationAPIException implements Exception {
  final String message;

  const NotificationAPIException(this.message);

  @override
  String toString() => 'NotificationAPIException: $message';
}
