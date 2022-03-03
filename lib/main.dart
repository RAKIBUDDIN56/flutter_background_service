import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'uniqueKey') {
      var url = Uri.parse('https://reqres.in/api/users/2');
      var response = await http.get(url);
      Map<String, dynamic> dataComingFromServer = json.decode(response.body);

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('channel', 'channel name',
              channelDescription: 'description',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false);

      const NotificationDetails platformChannelSpecifies =
          NotificationDetails(android: androidNotificationDetails);

      await flutterLocalNotificationsPlugin.show(
          0,
          dataComingFromServer['data']['first_name'],
          dataComingFromServer['data']['email'],
          platformChannelSpecifies,
          payload: 'item x');
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask('1', 'uniqueKey',
      frequency: const Duration(minutes: 15));

  runApp(const MyApp());
}

Future selectNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FlutterBackgroundService(),
    );
  }
}
