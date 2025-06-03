import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notification_models.dart';

/// Service for handling API communication with NotificationAPI
class NotificationAPIService {
  final String clientId;
  final String userId;
  final String? hashedUserId;
  final String apiRegion;

  NotificationAPIService({
    required this.clientId,
    required this.userId,
    this.hashedUserId,
    this.apiRegion = APIRegion.us,
  });

  String get _baseUrl => 'https://$apiRegion';

  /// Generate basic auth token for user
  String _generateBasicToken() {
    final token = hashedUserId != null
        ? '$clientId:$userId:$hashedUserId'
        : '$clientId:$userId';
    return base64Encode(utf8.encode(token));
  }

  /// Make authenticated API request
  Future<Map<String, dynamic>?> _apiRequest(String method, String resource,
      {Map<String, dynamic>? data}) async {
    final url = Uri.parse(
        '$_baseUrl/$clientId/users/${Uri.encodeComponent(userId)}/$resource');

    final headers = {
      'Authorization': 'Basic ${_generateBasicToken()}',
      'Content-Type': 'application/json',
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: data != null ? jsonEncode(data) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw NotificationAPIException('Unsupported HTTP method: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return null;
      }
    } else {
      throw NotificationAPIException(
        'API request failed: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  /// Get in-app notifications
  Future<Map<String, dynamic>?> getNotifications(
      String before, int count) async {
    return _apiRequest('GET',
        'notifications/INAPP_WEB?count=$count&before=${Uri.encodeComponent(before)}');
  }

  /// Update in-app notifications status
  Future<Map<String, dynamic>?> patchNotifications(
      Map<String, dynamic> params) async {
    return _apiRequest('PATCH', 'notifications/INAPP_WEB', data: params);
  }

  /// Get user preferences
  Future<GetPreferencesResponse> getPreferences() async {
    final response = await _apiRequest('GET', 'preferences');
    if (response == null) {
      throw NotificationAPIException('Failed to get preferences');
    }
    return GetPreferencesResponse.fromJson(response);
  }

  /// Update user preferences
  Future<void> postPreferences(List<Preference> preferences) async {
    final data = {'preferences': preferences.map((p) => p.toJson()).toList()};
    await _apiRequest('POST', 'preferences', data: data);
  }

  /// Update user information (identify)
  Future<void> postUser(User user) async {
    await _apiRequest('POST', '', data: user.toJson());
  }

  /// Get user account metadata
  Future<UserAccountMetadata> getUserAccountMetadata() async {
    final response = await _apiRequest('GET', 'account_metadata');
    if (response == null || response['userAccountMetadata'] == null) {
      throw NotificationAPIException('Failed to get user account metadata');
    }
    return UserAccountMetadata.fromJson(response['userAccountMetadata']);
  }

  /// Get in-app notifications with pagination logic
  Future<GetInAppNotificationsResult> getInAppNotifications({
    required String before,
    int maxCount = 100,
    String? oldestNeeded,
  }) async {
    oldestNeeded ??=
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

    List<InAppNotification> result = [];
    String oldestReceived = before;
    bool hasMore = true;
    bool shouldLoadMore = true;

    while (shouldLoadMore) {
      final response = await getNotifications(oldestReceived, maxCount);
      if (response == null || response['notifications'] == null) {
        break;
      }

      final notifications = (response['notifications'] as List)
          .map((n) => InAppNotification.fromJson(n))
          .toList();

      // Remove duplicates
      final notificationsWithoutDuplicates = notifications
          .where((n) => !result.any((existing) => existing.id == n.id))
          .toList();

      if (notificationsWithoutDuplicates.isNotEmpty) {
        oldestReceived = notificationsWithoutDuplicates
            .map((n) => n.date)
            .reduce((min, date) => min.compareTo(date) < 0 ? min : date);
      }

      result.addAll(notificationsWithoutDuplicates);

      hasMore = notificationsWithoutDuplicates.isNotEmpty;
      shouldLoadMore = hasMore &&
          result.length < maxCount &&
          oldestReceived.compareTo(oldestNeeded) > 0;
    }

    return GetInAppNotificationsResult(
      items: result,
      hasMore: hasMore,
      oldestReceived: oldestReceived,
    );
  }

  /// Update in-app notifications status
  Future<void> updateInAppNotifications({
    required List<String> ids,
    bool? archived,
    bool? clicked,
    bool? opened,
  }) async {
    final body = <String, dynamic>{
      'trackingIds': ids,
    };

    if (archived == true) {
      body['archived'] = DateTime.now().toIso8601String();
    } else if (archived == false) {
      body['archived'] = null;
    }

    if (clicked == true) {
      body['clicked'] = DateTime.now().toIso8601String();
    } else if (clicked == false) {
      body['clicked'] = null;
    }

    if (opened == true) {
      body['opened'] = DateTime.now().toIso8601String();
    } else if (opened == false) {
      body['opened'] = null;
    }

    await patchNotifications(body);
  }

  /// Update delivery option for a specific notification
  Future<void> updateDeliveryOption({
    required String notificationId,
    String? subNotificationId,
    required Channel channel,
    required DeliveryOption delivery,
  }) async {
    final preference = Preference(
      notificationId: notificationId,
      subNotificationId: subNotificationId,
      channel: channel,
      delivery: delivery,
    );
    await postPreferences([preference]);
  }

  /// Identify user (alias for postUser)
  Future<void> identify(User user) async {
    if (user.id != userId) {
      throw NotificationAPIException(
          'The id in the parameters does not match the initialized userId.');
    }
    await postUser(user);
  }
}
