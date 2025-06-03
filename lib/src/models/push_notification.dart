import 'package:push/push.dart';

/// Represents a push notification received from NotificationAPI
class PushNotification {
  /// Unique identifier for the notification
  final String? id;

  /// Title of the notification
  final String? title;

  /// Body text of the notification
  final String? body;

  /// Additional data payload
  final Map<String, dynamic> data;

  /// Image URL for the notification
  final String? imageUrl;

  /// Deep link URL
  final String? deepLink;

  /// Timestamp when notification was received
  final DateTime receivedAt;

  /// Creates a new PushNotification instance
  PushNotification({
    this.id,
    this.title,
    this.body,
    this.data = const {},
    this.imageUrl,
    this.deepLink,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  /// Creates a PushNotification from Push package RemoteMessage
  factory PushNotification.fromPushMessage(RemoteMessage message) {
    final dataMap =
        message.data?.cast<String, dynamic>() ?? <String, dynamic>{};

    // Extract title and body from data field (FCM) or alert field (APN) first,
    // then fall back to standard notification fields
    String? title;
    String? body;

    // For FCM: title and body are in the data field
    if (dataMap.containsKey('title')) {
      title = dataMap['title'] as String?;
    }
    if (dataMap.containsKey('body')) {
      body = dataMap['body'] as String?;
    }

    // For APN: title and body might be in an alert object
    if (dataMap.containsKey('alert')) {
      final alert = dataMap['alert'];
      if (alert is Map<String, dynamic>) {
        title ??= alert['title'] as String?;
        body ??= alert['body'] as String?;
      }
    }

    // Fall back to standard notification fields if not found in data
    title ??= message.notification?.title;
    body ??= message.notification?.body;

    return PushNotification(
      id: dataMap['messageId'] as String?,
      title: title,
      body: body,
      data: dataMap,
      imageUrl: dataMap['imageUrl'] as String?,
      deepLink: dataMap['deepLink'] as String?,
    );
  }

  /// Creates a PushNotification from notification tap data
  factory PushNotification.fromNotificationTap(Map<String, dynamic> data) {
    // Extract title and body from data field (FCM) or alert field (APN) first,
    // then fall back to direct data fields
    String? title;
    String? body;

    // For FCM: title and body are in the data field
    if (data.containsKey('title')) {
      title = data['title'] as String?;
    }
    if (data.containsKey('body')) {
      body = data['body'] as String?;
    }

    // For APN: title and body might be in an alert object
    if (data.containsKey('alert')) {
      final alert = data['alert'];
      if (alert is Map<String, dynamic>) {
        title ??= alert['title'] as String?;
        body ??= alert['body'] as String?;
      }
    }

    return PushNotification(
      id: data['messageId'] as String?,
      title: title,
      body: body,
      data: data,
      imageUrl: data['imageUrl'] as String?,
      deepLink: data['deepLink'] as String?,
    );
  }

  /// Creates a PushNotification from Firebase RemoteMessage (for backward compatibility)
  factory PushNotification.fromRemoteMessage(dynamic message) {
    // This is now deprecated and should be replaced with fromPushMessage
    if (message is Map<String, dynamic>) {
      return PushNotification.fromNotificationTap(message);
    }

    return PushNotification(
      id: message.toString(),
      title: 'Legacy notification',
      body: 'Please update to use push package',
      data: {},
    );
  }

  /// Creates a PushNotification from JSON
  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      id: json['id'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      imageUrl: json['imageUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the PushNotification to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      'data': data,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (deepLink != null) 'deepLink': deepLink,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this notification with updated properties
  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? deepLink,
    DateTime? receivedAt,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      deepLink: deepLink ?? this.deepLink,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PushNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PushNotification(id: $id, title: $title, body: $body, data: $data)';
  }
}
