import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notification_firebase/notification_services.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();

    //notificationServices.isTokenRefresh();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value) {
      print('Device token');
      print(value.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            notificationServices.getDeviceToken().then((value) async{
              var data = {
                'to' : value.toString(),
                'priority' : 'high',
                'notification' : {
                  'title' : 'Testing Notification',
                  'body' : 'It is only for testing'
                },
                'data' : {
                  'type' : 'msg',
                  'id' : '12356'
                }

              };
                await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                body: jsonEncode(data),
                headers: {
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Authorization' : 'key=AAAA7fUA6FE:APA91bGYk3S2mesTocLYLTXLn5Zip_bmkPEkFTpZLQt3y_fGgr_TwOEniUWxSeyfvbalKKl-xJUVwUcCufEva-9Sau6pGe7vq_Y5nlQ4AXNEXCMI7jB4CPX9QEjPGraVgtKkVnay6nkD'

                }
              );
            });
          },
          child: Text('Send Notification'),
        ),
      ),
    );
  }
}
