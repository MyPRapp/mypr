// notification_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mypr/Globals/global_components.dart';

// TODO: Change notification style while not in foreground too
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

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.requestPermission();
    successPrint('${await FirebaseMessaging.instance.getToken()}');
    await _setupNotificationChannel();
    _handleForegroundMessages();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> _setupNotificationChannel() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/mypr_icon');
    const initSettings = InitializationSettings(android: androidSettings);

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

      //TODO: Fix notification icon style
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name,
            icon: android?.smallIcon ?? '@drawable/mypr_icon',
            color: Color.fromARGB(255, 255, 0, 0)),
      );

      // Check if the notification part exists, then display it
      if (notification != null && android != null) {
        // If the notification field is present, show it
        _localNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, notificationDetails);
      } else if (message.data.isNotEmpty) {
        // If there is no notification but data exists, use data for the notification
        _localNotificationsPlugin.show(
            0,
            message.data['title'] ??
                'Data title', // Title from data or fallback
            message.data['body'] ?? 'Data body', // Body from data or fallback,

            notificationDetails);
      }
    });
  }
}
