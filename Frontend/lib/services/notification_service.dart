// notification_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mypr/Globals/global_components.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔙 Handling background message: ${message.messageId}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  static String? token;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      await FirebaseMessaging.instance.requestPermission();

      // Ensure notifications are displayed while the app is in the foreground on iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      token = await FirebaseMessaging.instance.getToken();
      successPrint(token!);

      await _setupNotificationChannel();
      _handleForegroundMessages();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e, stackTrace) {
      errorPrint('NotificationService initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<void> _setupNotificationChannel() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.data}');

      // Try to get notification and data content
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // NotificationDetails notificationDetails = NotificationDetails(
      //   android: AndroidNotificationDetails(_channel.id, _channel.name,
      //       icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      //       color: Color.fromARGB(255, 255, 0, 0)),
      // );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          color: const Color.fromARGB(255, 255, 0, 0),
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      if (notification != null && message.data.isEmpty) {
        // Show only the notification payload
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          notificationDetails,
        );
      } else if (notification == null && message.data.isNotEmpty) {
        // Fallback to data payload only if no notification exists
        _localNotificationsPlugin.show(
          0,
          message.data['title'] ?? 'Data title',
          message.data['body'] ?? 'Data body',
          notificationDetails,
        );
      }
    });
  }
}
