import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robot_app/Distance.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;
  Stream stream;

  HomePage({Key key, this.title, @required this.channel}) : super(key: key) {
    this.stream = this.channel.stream.asBroadcastStream();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _sendMessage(String message) {
    widget.channel.sink.add(message);
    print("send: " + message);
  }

  String _parseData(dynamic data) {
    try {
      Map<String, dynamic> dataJson = json.decode(data);

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
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 60,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        this._sendMessage("left");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        this._sendMessage("right");
                      },
                    )
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
            Center(
              child: StreamBuilder(
                stream: widget.stream,
                builder: (context, snapshot) {
                  print(snapshot.error);
                  return Text(snapshot.hasData
                      ? this._parseData(snapshot.data)
                      : 'Empty response');
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    this._sendMessage("distance");
                  },
                ),
                StreamBuilder(
                  stream: widget.stream,
                  builder: (context, snapshot) {
                    snapshot.hasError ? print(snapshot.error) : '';
                    return Text(snapshot.hasData
                        ? this._parseData(snapshot.data)
                        : 'Empty response');
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
