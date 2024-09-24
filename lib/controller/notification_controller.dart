import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize the Flutter Local Notification Plugin for foreground notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      _showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'A new onMessageOpenedApp event was published: ${message.messageId}');
    });

    // Handle terminated state messages
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('Received terminated state message: ${message.messageId}');
      }
    });

    // Get the FCM token for the device
    getToken();
  }

  // Retrieve the FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
    // print("FCM Token: $token");
    // You can send this token to your server for future use
  }

  // Display notifications for foreground messages
  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'data',
    );
  }

  final String fcmUrl =
      'https://fcm.googleapis.com/v1/projects/authentication-47be6/messages:send';

  // Use your service account JSON file
  Future<void> sendNotificationWithBearerToken({
    required List<String> userTokens,
    required String title,
    required String body,
  }) async {
    // Load the service account JSON file from assets using rootBundle
    final serviceAccountJson =
        await rootBundle.loadString('assets/fcm-service-account.json');

    // Parse the JSON file
    final serviceAccount = json.decode(serviceAccountJson);

    final _credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    // Generate OAuth 2.0 token
    final client = await clientViaServiceAccount(
        _credentials, ['https://www.googleapis.com/auth/cloud-platform']);

    try {
      // Build the notification message
      for (String token in userTokens) {
        final message = {
          'message': {
            'token': token, // Device token
            'notification': {
              'title': title,
              'body': body,
            },
          }
        };

        final response = await http.post(
          Uri.parse(fcmUrl),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'Bearer ${client.credentials.accessToken.data}',
          },
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully');
        } else {
          print('Failed to send notification: ${response.body}');
        }
      }
    } finally {
      client.close();
    }
  }
}
