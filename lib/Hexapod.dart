import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:robot_app/Home.dart';
import 'package:robot_app/RemoteControl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Hexapod extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;
  Stream stream;

  Hexapod({Key key, this.title, @required this.channel}) : super(key: key) {
    this.stream = this.channel.stream.asBroadcastStream();
  }

  @override
  _HexapodState createState() => _HexapodState();
}

class _HexapodState extends State<Hexapod> {
  Widget rcp;
  Widget hp;
  Widget view;

  @override
  void initState() {
    super.initState();
    this.rcp = RemoteControlPage(channel: widget.channel);
    this.hp = HomePage(channel: widget.channel);
    this.view = hp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hexapod SC.")),
      resizeToAvoidBottomInset: false,
      body: view,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Hexapod System Control'),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  view = this.hp;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_remote),
              title: Text('Remote control'),
              onTap: () {
                setState(() {
                  view = this.rcp;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Réglages'),
              onTap: () {
                setState(() {
                  view = Text("Je suis un text");
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
