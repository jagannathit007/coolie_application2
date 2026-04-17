import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  AudioPlayer player = AudioPlayer();

  Future<void> _whistle(String sound) async {
    await player.setSource(AssetSource(sound)).then((value) {
      player.play(AssetSource(sound));
    });
    player.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.completed) {
        await player.pause();
      }
    });
  }

  Future<void> init() async {
    _requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  Future<void> _requestPermission() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      openAppSettings();
    }
  }

  void showRemoteNotificationAndroid(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    AppleNotification? apple = message.notification?.apple;
    if (notification != null) {
      NotificationDetails notificationDetails = NotificationDetails(
        android: android != null
            ? const AndroidNotificationDetails(
                "booking_channel",
                "Booking Channel",
                ticker: 'ticker',
                showWhen: true,
                playSound: true,
                enableLights: true,
                enableVibration: true,
                priority: Priority.high,
                importance: Importance.max,
                visibility: NotificationVisibility.public,
                channelDescription: "The event reminder system for planora user to manage booking_channel",
              )
            : null,
        iOS: apple != null ? const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true) : null,
      );
      _whistle("slow_spring_board.mp3");
      await flutterLocalNotificationsPlugin.show(id: notification.hashCode, title: notification.title, body: notification.body, notificationDetails: notificationDetails);
    }
  }

  Future<String?> getToken() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        token = await FirebaseMessaging.instance.getToken();
      }
      return token;
    } catch (err) {
      return null;
    }
  }
}

NotificationService notificationService = NotificationService();
