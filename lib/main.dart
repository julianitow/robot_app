import 'dart:io';

import 'package:flutter/material.dart';
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

class MyApp extends StatefulWidget {
  IOWebSocketChannel channel;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Hexapod(
        title: 'Hexapod S.C',
        channel: widget.channel,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
