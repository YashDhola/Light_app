import 'dart:async';
import 'package:flutter/material.dart';
import 'Home.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(61, 62, 63, 1),
      height: 20,
      width: 20,
      child: const Center(
          child: ImageIcon(
        AssetImage("image/aakalp2.png"),
        color: Colors.white,
        size: 130,
      )),
    );
  }
}
