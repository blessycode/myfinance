import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNotificationService {
  PhoneNotificationService._();

  static final instance = PhoneNotificationService._();
  static const _channel = MethodChannel('com.example.myfinance/notifications');
  static const _seenKey = 'phone_notification_seen_ids';

  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod<void>('requestPermission');
    } on PlatformException catch (_) {
      // Notifications may be unavailable or disabled on this device.
    } on MissingPluginException {
      // Notifications may be unavailable or disabled on this device.
    }
  }

  Future<void> showNewNotifications(List<Map<String, dynamic>> rows) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getStringList(_seenKey);
    final current = rows.map((row) => row['id'].toString()).toSet();

    // Establish a baseline on first run so old inbox items do not pop at once.
    if (saved == null) {
      await preferences.setStringList(_seenKey, current.toList());
      return;
    }

    final seen = saved.toSet();
    final fresh = rows.where((row) => !seen.contains(row['id'].toString())).toList();
    for (final row in fresh.reversed) {
      try {
        await _channel.invokeMethod<void>('show', {
          'id': row['id'].toString(),
          'title': (row['title'] ?? 'Provida update').toString(),
          'body': (row['body'] ?? '').toString(),
        });
      } on PlatformException {
        break;
      } on MissingPluginException {
        break;
      }
    }
    await preferences.setStringList(_seenKey, current.toList());
  }
}
