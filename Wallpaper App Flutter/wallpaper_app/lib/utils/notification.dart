import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

Future<void> displayNotification(
      String title, String body, String imagePath,FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
        print('Kal Ana');
    flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails('channel id', 'channel name',
              priority: Priority.max),
        ),
        payload: imagePath);
  }

  Future selectNotification(NotificationResponse payload) async {
    debugPrint('notification payload: ${payload.toString()}');
    OpenFile.open(payload.toString());
  }