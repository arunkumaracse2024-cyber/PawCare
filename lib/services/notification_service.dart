import 'dart:async';
import 'package:flutter/foundation.dart';

class NotificationPayload {
  final int id;
  final String title;
  final String body;

  NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;
  final StreamController<NotificationPayload> _streamController =
      StreamController<NotificationPayload>.broadcast();

  Stream<NotificationPayload> get onNotificationTriggered =>
      _streamController.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    debugPrint('[NotificationService] Initializing notifications platform...');
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    debugPrint(
      '[NotificationService] Requesting notification channel permissions...',
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    debugPrint(
      '[NotificationService] Triggered Instant Alert - ID: $id | $title: $body',
    );
    _streamController.add(
      NotificationPayload(id: id, title: title, body: body),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final diff = scheduledDate.difference(DateTime.now());
    debugPrint(
      '[NotificationService] Scheduled Alert - ID: $id | $title | In: ${diff.inSeconds} seconds (At: ${scheduledDate.toIso8601String()})',
    );

    // Simulate real-time background countdown timer for short delays (triggers in-app during demo!)
    if (diff.inSeconds > 0 && diff.inSeconds <= 120) {
      Timer(diff, () {
        debugPrint(
          '[NotificationService] Timer Fired: showing scheduled notification!',
        );
        showNotification(id: id, title: title, body: body);
      });
    }
  }

  Future<void> cancelAllNotifications() async {
    debugPrint('[NotificationService] Canceling all scheduled alarms.');
  }
}
