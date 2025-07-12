// notification_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔙 Handling background message: ${message.messageId}');
}

class FirebaseService {
  static String? token;

  static final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      // ignore: unused_local_variable
      FirebaseAnalytics analytics = FirebaseAnalytics.instance;

      registerDevice();

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
      errorPrint('❌ FirebaseService initialization failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static Future<bool> registerDevice() async {
    final prefs = await SharedPreferences.getInstance();

    final bool hasSentFirebaseToken =
        prefs.getBool('hasSentFirebaseToken') ?? false;

    if (hasSentFirebaseToken) {
      return true;
    }

    String? token = await FirebaseMessaging.instance.getToken();

    if (token == null) {
      errorPrint('Firebase token not found');
      return false;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$apiUrl/register_device/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_token': token}),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        return http.Response('Error: Timeout', 408); // 408 Request Timeout
      });

      if (response.statusCode == 200) {
        await prefs.setBool('hasSentFirebaseToken', true);

        successPrint('Device was registered');

        return true;
      } else {
        errorPrint(
            'Error while registering device: ${response.statusCode}\n${response.body}');

        return false;
      }
    } catch (e) {
      throw Exception('Error while registering device: $e');
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

      if (Platform.isAndroid) {
        // Check if the notification part exists, then display it
        if (notification != null && android != null) {
          // If the notification field is present, show it
          _localNotificationsPlugin.show(notification.hashCode,
              notification.title, notification.body, notificationDetails);
        } else if (message.data.isNotEmpty) {
          // If there is no notification but data exists, use data for the notification
          _localNotificationsPlugin.show(
              0,
              message.data['title'] ?? 'MyPR', // Title from data or fallback
              message.data['body'] ?? ' ', // Body from data or fallback,
              notificationDetails);
        }
      }

      if (Platform.isIOS) {
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
      }
    });
  }
}
