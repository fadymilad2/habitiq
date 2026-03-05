import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

/// Singleton service that manages all local notification scheduling.
/// Compatible with flutter_local_notifications v21+.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId =
      'habitiq_daily_v3'; // fixed VIBRATE permission, recreating channel
  static const _channelName = 'Daily Reminders';
  static const _notifId = 1;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      log('NotificationService: Timezone set to ${timezoneInfo.identifier}');
    } catch (e) {
      log('NotificationService: Failed to get timezone - $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinInit = DarwinInitializationSettings(
      // Permissions are requested at init time on iOS/macOS
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // v21+: all parameters are named
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (details) {
        log('NotificationService: tapped → ${details.payload}');
      },
    );

    // Request permissions proactively on startup for Android 13+
    await requestPermissions();
  }

  // ── Permissions ───────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      return granted ?? false;
    }
    // iOS/macOS: permissions are requested automatically at init time
    // via DarwinInitializationSettings fields set to true.
    return true;
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  /// Schedules a daily notification every day at [hour]:[minute] (24h).
  /// Default: 8:00 PM (20:00).
  Future<void> scheduleDailyReminder({int hour = 20, int minute = 0}) async {
    // v21+: zonedSchedule uses all named parameters
    await _plugin.zonedSchedule(
      id: _notifId,
      title: 'HabitIQ Reminder 🌟',
      body: "Don't forget to track your habits today!",
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily habit reminder',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          icon: '@mipmap/launcher_icon',
          color: const Color(0xFF7C3AED),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
    log('NotificationService: Daily reminder scheduled at $hour:$minute');
  }

  /// Schedules a daily reminder for a specific habit.
  /// Uses a hash of the [habitId] to generate a stable, unique integer ID.
  Future<void> scheduleHabitReminder(
    String habitId,
    String habitTitle,
    int hour,
    int minute,
  ) async {
    await requestPermissions(); // Ensure permissions are granted before scheduling
    final int notifId = habitId.hashCode;
    await _plugin.zonedSchedule(
      id: notifId,
      title: 'Time for $habitTitle! 🌟',
      body: "Don't break your streak! Mark your habit as done today.",
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Per-habit daily reminders',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF7C3AED),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
    log(
      'NotificationService: Scheduled habit [$habitTitle] at $hour:$minute (ID: $notifId)',
    );
  }

  /// Cancels a specific habit's reminder.
  Future<void> cancelHabitReminder(String habitId) async {
    final int notifId = habitId.hashCode;
    await _plugin.cancel(id: notifId);
    log('NotificationService: Cancelled habit reminder (ID: $notifId)');
  }

  /// Shows an immediate notification for testing purposes.
  Future<void> showInstantNotification() async {
    await _plugin.show(
      id:
          _notifId +
          1, // different ID so it doesn't overwrite the scheduled one
      title: 'HabitIQ Reminders Active! 🌟',
      body: "You will now receive daily reminders.",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily habit reminder',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          icon: '@mipmap/launcher_icon',
          color: Color(0xFF7C3AED),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    log('NotificationService: All notifications cancelled');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
