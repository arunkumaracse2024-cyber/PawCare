import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] User tapped notification: ${details.payload}');
      },
    );

    _initialized = true;
    debugPrint('[NotificationService] Initialized Flutter Local Notifications.');
  }

  Future<void> requestPermissions() async {
    debugPrint('[NotificationService] Requesting notification channel permissions...');
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  Future<void> scheduleReminderNotification(PetReminder reminder, String petName) async {
    if (!_initialized) await initialize();

    final id = reminder.id.hashCode;
    final title = '$petName\'s ${reminder.type} Reminder';
    final body = reminder.title;
    
    final scheduledDate = reminder.dateTime;
    
    // If it's in the past and not repeating, ignore
    if (scheduledDate.isBefore(DateTime.now()) && reminder.repeatOption.toLowerCase() == 'none') {
      debugPrint('[NotificationService] Reminder is in the past, skipping schedule.');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'pawcare_reminders_channel',
      'PawCare Reminders',
      channelDescription: 'Notifications for pet reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      
      // Determine repeat interval
      DateTimeComponents? matchDateTimeComponents;
      switch (reminder.repeatOption.toLowerCase()) {
        case 'daily':
          matchDateTimeComponents = DateTimeComponents.time;
          break;
        case 'weekly':
          matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case 'monthly':
          matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        default:
          matchDateTimeComponents = null; // None
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOf(tzScheduledDate, reminder.repeatOption.toLowerCase()),
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: reminder.id,
      );

      debugPrint('[NotificationService] Scheduled notification ID: $id | Repeat: ${reminder.repeatOption}');
    } catch (e) {
      debugPrint('[NotificationService] Failed to schedule notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOf(tz.TZDateTime target, String repeatOption) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = target;

    // Fast-forward next occurrence if the initial target time is past
    if (scheduled.isBefore(now)) {
      if (repeatOption == 'daily') {
        while (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
      } else if (repeatOption == 'weekly') {
        while (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 7));
        }
      } else if (repeatOption == 'monthly') {
        while (scheduled.isBefore(now)) {
          int nextMonth = scheduled.month + 1;
          int nextYear = scheduled.year;
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }
          scheduled = tz.TZDateTime(tz.local, nextYear, nextMonth, scheduled.day, scheduled.hour, scheduled.minute, scheduled.second);
        }
      }
    }
    return scheduled;
  }

  Future<void> cancelReminderNotification(String reminderId) async {
    if (!_initialized) return;
    try {
      final id = reminderId.hashCode;
      await _notificationsPlugin.cancel(id: id);
      debugPrint('[NotificationService] Canceled notification ID: $id');
    } catch (e) {
      debugPrint('[NotificationService] Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) return;
    await _notificationsPlugin.cancelAll();
    debugPrint('[NotificationService] Canceled all scheduled notifications.');
  }
}
