import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../constants/firebase_paths.dart';
import 'notification_service.dart';
import 'audio_service.dart';

/// Background service that monitors alarm states even when the app is
/// minimized. Listens to Firebase RTDB alarm paths and triggers
/// notifications + audio when alarms are activated.
class BackgroundAlarmService {
  static BackgroundAlarmService? _instance;
  static BackgroundAlarmService get instance {
    _instance ??= BackgroundAlarmService._();
    return _instance!;
  }

  BackgroundAlarmService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, bool> _lastAlarmStates = {};
  bool _isRunning = false;

  /// Start listening to all alarm paths in the background.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    _listenToAlarm(
      path: FirebasePaths.occlusion,
      key: 'occlusion',
      notificationId: 10,
      title: 'Occlusion Detected',
      body: 'Line blockage detected. Check IV tubing immediately.',
    );

    _listenToAlarm(
      path: FirebasePaths.bubble,
      key: 'bubble',
      notificationId: 11,
      title: 'Air Bubble Detected',
      body: 'Air detected in the IV line. Infusion paused for safety.',
    );

    _listenToAlarm(
      path: FirebasePaths.bagEmpty,
      key: 'bagEmpty',
      notificationId: 12,
      title: 'Bag Empty',
      body: 'IV bag is empty. Replace fluid bag.',
    );

    _listenToAlarm(
      path: FirebasePaths.alarmComplete,
      key: 'complete',
      notificationId: 13,
      title: 'Infusion Complete',
      body: 'The prescribed infusion volume has been delivered.',
      isInfoLevel: true,
    );
  }

  /// Stop all listeners.
  void stop() {
    _isRunning = false;
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _lastAlarmStates.clear();
    AudioService.stopAlarm();
  }

  void _listenToAlarm({
    required String path,
    required String key,
    required int notificationId,
    required String title,
    required String body,
    bool isInfoLevel = false,
  }) {
    final sub = _db.ref(path).onValue.listen((event) {
      final value = _toBool(event.snapshot.value);
      final previous = _lastAlarmStates[key] ?? false;

      if (value && !previous) {
        // Alarm just triggered
        if (isInfoLevel) {
          NotificationService.showInfoNotification(
            id: notificationId,
            title: title,
            body: body,
          );
        } else {
          AudioService.playAlarm();
          NotificationService.showAlarmNotification(
            id: notificationId,
            title: title,
            body: body,
          );
        }
      } else if (!value && previous) {
        // Alarm cleared
        NotificationService.cancel(notificationId);
        // If no alarms active, stop audio
        _lastAlarmStates[key] = value;
        if (!_lastAlarmStates.values.any((v) => v)) {
          AudioService.stopAlarm();
        }
        return;
      }

      _lastAlarmStates[key] = value;
    });

    _subscriptions[key] = sub;
  }

  bool _toBool(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}
