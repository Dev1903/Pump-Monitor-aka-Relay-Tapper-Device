import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'helpers/notifications_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Subscribe to topic "all" so the function’s message is received
  await FirebaseMessaging.instance.subscribeToTopic("all");

  // Initialize local notifications
  await initializeNotifications();

  // Set background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Request notification permission
  await requestNotificationPermission();

  // Foreground notification listener
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    showLocalNotification(title, body);
  });

  // Print FCM token
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $token");

  runApp(const PumpApp());
}

/// Requests notification permission (Android 13+)
Future<void> requestNotificationPermission() async {
  final status = await Permission.notification.status;

  if (status.isDenied) {
    final result = await Permission.notification.request();
    debugPrint('Notification permission status: $result');
  } else if (status.isGranted) {
    debugPrint('Notification permission already granted');
  } else if (status.isPermanentlyDenied) {
    debugPrint('Notification permission is permanently denied. Ask user to enable in settings.');
  }
}

class PumpApp extends StatelessWidget {
  const PumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0d1117),
        primaryColor: const Color(0xFF58a6ff),
      ),
      home: const HomeScreen(),
    );
  }
}
