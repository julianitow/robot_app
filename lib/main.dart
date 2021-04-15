import 'dart:io';

import 'package:flutter/material.dart';
import 'package:robot_app/Home.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final channel = IOWebSocketChannel.connect("wss://10.0.0.15:3000");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(
        title: 'Hexapod S.C',
        channel: IOWebSocketChannel.connect(
          "wss://robotpaesgi.ovh:3000",
        ),
      ),
    );
  }
}
