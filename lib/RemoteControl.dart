import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class RemoteControlPage extends StatefulWidget {
  WebSocketChannel channel;
  Stream stream;

  RemoteControlPage({Key key, this.channel}) : super(key: key) {
    // this.stream = this.channel.stream.asBroadcastStream();
  }

  @override
  _RemoteControlPageState createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  void _sendMessage(String message) {
    widget.channel.sink.add(message);
    print("send: " + message);
  }

  void connect() {
    widget.channel = IOWebSocketChannel.connect("wss://10.0.0.15:3000");
  }

  void disconnect() {
    widget.channel.sink.close();
  }

  String _parseData(dynamic data) {
    try {
      Map<String, dynamic> dataJson = json.decode(data);
      print(dataJson);
      if (dataJson.containsKey('distance')) {
        print(dataJson['distance']);
        return dataJson['distance'].toString();
      }
    } on FormatException catch (err) {
      print(err.message);
    }
    return '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  this._sendMessage("forward");
                },
              )
            ],
          ),
        ),
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    this._sendMessage("stop");
                  },
                ),

              ],
            ),
          ],
        ),
        Center(
          child: Column(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () {
                  this._sendMessage("back");
                },
              )
            ],
          ),
        ),
      ],
    ));
  }
}
