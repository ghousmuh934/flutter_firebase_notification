

import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'messaging_screen.dart';

class NotificationServices {

  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising firebase message plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message) async{

    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload){
        // This payload will sent to us our backend developer
        // handle interaction when app is active for android
       handleMessage(context, message);
      }
    );
  }

  // function to request notifications permissions
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: true,
       sound: true,
      criticalAlert: true ,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print('user permission granted');
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('user permission provisional granted');
    }else{
      print('user denied granted');
    }
  }

  void firebaseInit(BuildContext context) {

    FirebaseMessaging.onMessage.listen((message) {

      print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      print(message.data['type'].toString());
      print(message.data['id'].toString());
      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotifications(message);
      }
      else{
        showNotifications(message);
      }
    });
  }

  // function to show visible notification when app is active
  Future<void> showNotifications (RemoteMessage message) async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(10000).toString(),
        'High Importance Notifications',
      importance: Importance.max,
      showBadge: true
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero,() {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    },

    );
  }

  Future<void> setupInteractMessage(BuildContext context) async{

    // when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage (BuildContext context, RemoteMessage message){
    if(message.data['type'] == 'msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> MessageScreen(
        id: message.data['id'],
      )));
    }
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('Refresh');
    });
  }

}