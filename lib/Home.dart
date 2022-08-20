import 'dart:convert';

import 'package:demo/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  static const String _title = 'Aakalp App';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(_title),
          backgroundColor: Color.fromRGBO(61, 62, 63, 1),
        ),
        body: const MyStatefulWidget(),
      ),
      debugShowCheckedModeBanner: false,
    );
    ;
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  "Login",
                  style: TextStyle(
                      color: Color.fromRGBO(61, 62, 63, 1),
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User ID',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                /*   final flutterLocalNotificationsPlugin =
                    FlutterLocalNotificationsPlugin();
                const AndroidInitializationSettings
                    initializationSettingsAndroid =
                    AndroidInitializationSettings("@mipmap/ic_launcher");
                final InitializationSettings initializationSettings =
                    InitializationSettings(
                  android: initializationSettingsAndroid,
                );
                await flutterLocalNotificationsPlugin
                    .initialize(initializationSettings,
                        onSelectNotification: (String? payload) async {
                  if (payload != null) {
                    debugPrint('notification payload: $payload');
                  }
                });
                AndroidNotificationDetails androidPlatformChannelSpecifics =
                    AndroidNotificationDetails(
                        'your channel id', 'your channel name',
                        channelDescription: 'your channel description',
                        importance: Importance.max,
                        priority: Priority.high,
                        ticker: 'ticker');
                NotificationDetails platformChannelSpecifics =
                    NotificationDetails(
                        android: androidPlatformChannelSpecifics);
                await flutterLocalNotificationsPlugin.show(
                    0, 'plain title', 'plain body', platformChannelSpecifics,
                    payload: 'item x');*/
              },
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(color: Color.fromRGBO(61, 62, 63, 1)),
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                    child: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(61, 62, 63, 1),
                    ),
                    onPressed: () async {
                      checkUser();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CurrentLocationScreen()));
                    })),
          ],
        ));
  }

  Future<void> checkUser() async {
    String apiUrl =
        "https://heroku-backend-hackathone.herokuapp.com/api/user/login";
    var data = {
      "email": nameController.text,
      "password": passwordController.text,
    };
    var response = await http.post(Uri.parse(apiUrl),
        body: json.encode(data),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });
    Map res = jsonDecode(response.body);
    Map Data = res["data"];

    if (res["status"] == 200) {
    } else {
      print("===error");
    }
  }
}
