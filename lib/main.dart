import 'dart:io';

import 'package:flutter/material.dart';
import 'package:robot_app/Home.dart';
import 'package:web_socket_channel/io.dart';

import 'Hexapod.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  // final channel = IOWebSocketChannel.connect("wss://hexapod.local:3000");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Hexapod(
        title: 'Hexapod S.C',
        channel: IOWebSocketChannel.connect(
          "wss://10.33.0.230:3000",
        ),
      ),
    );
  }
}
