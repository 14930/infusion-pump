import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'shared/router/app_router.dart';

/// Whether Firebase was successfully initialized.
bool firebaseInitialized = false;

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (gracefully handle missing config)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    firebaseInitialized = false;
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('   The app will run in offline/demo mode.');
    debugPrint('   To fix: run "flutterfire configure" to set up your Firebase project.');
  }

  // Initialize notifications (works without Firebase)
  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('⚠️ Notification init failed: $e');
  }

  // Set up FCM only if Firebase is available
  if (firebaseInitialized) {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _setupFCM();
      BackgroundAlarmService.instance.start();
    } catch (e) {
      debugPrint('⚠️ FCM setup failed: $e');
    }
  }

  // Allow all orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style for the dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: InfusionPumpApp()));
}

/// Set up Firebase Cloud Messaging and store FCM token.
Future<void> _setupFCM() async {
  final messaging = FirebaseMessaging.instance;

  // Request notification permissions (required on iOS and Android 13+)
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    criticalAlert: true,
  );

  // Get the FCM token and store it in Firebase RTDB
  try {
    final token = await messaging.getToken();
    if (token != null) {
      await _storeFCMToken(token);
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen(_storeFCMToken);
  } catch (e) {
    debugPrint('FCM token error: $e');
  }

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService.showAlarmNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification!.title ?? 'Infusion Pump Alert',
        body: message.notification!.body ?? '',
      );
    }
  });
}

/// Store the FCM token in Firebase RTDB for Cloud Function push notifications.
Future<void> _storeFCMToken(String token) async {
  try {
    final deviceId = token.substring(0, 20).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    await FirebaseDatabase.instance.ref('users/$deviceId/fcmToken').set(token);
  } catch (e) {
    debugPrint('Failed to store FCM token: $e');
  }
}

/// Root application widget.
class InfusionPumpApp extends StatelessWidget {
  const InfusionPumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Infusion Pump Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
