import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/Constant.dart';

import '../main.dart';
import '../screens/main_screen.dart';

class FirebaseInitialize {
  static void initFirebaseState(BuildContext context) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'msg_channel', // id
        'High Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
        playSound: true);

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    Future<void> generateSimpleNotication(String title, String msg) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        playSound: true,
        icon: notificationIcon,
      );
      var iosDetail = IOSNotificationDetails();

      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iosDetail);
      await flutterLocalNotificationsPlugin.show(
          0, title, msg, platformChannelSpecifics);
    }

    // Future<String> _downloadAndSaveImage(String url, String fileName) async {
    //   var directory = await getApplicationDocumentsDirectory();
    //   var filePath = '${directory.path}/$fileName';
    //   var response = await http.get(Uri.parse(url));

    //   var file = File(filePath);
    //   await file.writeAsBytes(response.bodyBytes);
    //   return filePath;
    // }

    Future<void> generateImageNotication(
        String title, String msg, String image) async {
      // var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
      // var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
      var bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(image),
          hideExpandedLargeIcon: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: msg,
          htmlFormatSummaryText: true);
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          channel.id, channel.name,
          channelDescription: channel.description,
          playSound: true,
          icon: notificationIcon,
          largeIcon: FilePathAndroidBitmap(image),
          styleInformation: bigPictureStyleInformation);

      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        msg,
        platformChannelSpecifics,
      );
    }

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('messgae1 $message.data');
      }
    });

    _firebaseMessaging.getToken().then((value) {
      print('--token--$value');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification!;
      var title = notification.title ?? '';
      var body = notification.body ?? '';
      var image = null;
      if (image != null && image != 'null' && image != '') {
        generateImageNotication(title, body, image);
      } else {
        generateSimpleNotication(title, body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      RemoteNotification notification = message.notification!;
      var title = notification.title ?? '';
      var body = notification.body ?? '';
      PendingDynamicLinkData? dynamicLinkData;
      if (Uri.parse(body).host != '') {
        dynamicLinkData =
            await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(body));
      }
      print('===body==$body==');
      if (dynamicLinkData != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => MyHomePage(
                    webUrl: dynamicLinkData!.link.toString(),
                    isDeepLink: true,
                  )),
          (route) => false,
        );
      }
    });
  }
}
