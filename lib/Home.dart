import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  WebSocketChannel channel;
  Stream stream;

  HomePage({Key key, @required this.channel}) : super(key: key) {
    // this.stream = this.channel.stream.asBroadcastStream();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAlarmActive = false;
  TextEditingController _controller = TextEditingController();
  DateTime currentTime;
  String currentName;
  List<String> alarmsString = [];
  List<String> namesString = [];
  Map<String, Widget> _cards = Map();

  final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  void _sendMessage(String message) {
    widget.channel.sink.add(message);
    print("send: " + message);
  }

  String getAlarmTime() {
    this._sendMessage("alarmState");
    StreamBuilder(
        stream: widget.stream,
        builder: (context, snapshot) {
          print(snapshot.error);
          if (snapshot.hasData) {
            print(snapshot.data);
          }
        });
  }

  void removeAlarm() {}

  void saveAlarmsSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('alarms');
    prefs.remove('names');
    prefs.setStringList('alarms', this.alarmsString);
    prefs.setStringList('names', this.namesString);
  }

  void loadAlarmsSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('alarms') == null ||
        prefs.getStringList("names") == null) {
      return;
    }
    this.alarmsString = prefs.getStringList('alarms');
    this.namesString = prefs.getStringList('names');
    int i = 0;
    if (this.alarmsString == null || this.namesString == null) {
      return;
    }
    this.alarmsString.forEach((time) {
      String name = this.namesString[i];
      this._cards.putIfAbsent(name, () => createCard(name, time));
      i++;
    });
    setState(() {});
  }

  Card createCard(String name, String time) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.timer),
            title: Text(name),
            subtitle: Text(time),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      this._cards.remove(name);
                      this.alarmsString.remove(time);
                      this.namesString.remove(name);
                      this.saveAlarmsSharedPrefs();
                    });
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              Padding(padding: EdgeInsets.only(right: 10)),
              OutlinedButton(
                  onPressed: () {
                    if (!this.isAlarmActive) {
                      this._sendMessage('wut: ' + time);
                      //this._sendMessage('alarmState');
                      setState(() {
                        this.isAlarmActive = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Alarm set: " + time)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Alarm already active !")));
                    }
                  },
                  child: Text(
                    'Set',
                    style: TextStyle(color: Colors.green),
                  )),
              Padding(padding: EdgeInsets.only(right: 10)),
            ],
          ),
        ],
      ),
    );
  }

  void addAlarm(String name, DateTime time) {
    this.alarmsString.add(time.toString());
    this.namesString.add(name);
    this.saveAlarmsSharedPrefs();
    Widget card = this.createCard(this.currentName, time.toString());
    this._cards.putIfAbsent(name, () => card);
    print(this._cards);
  }

  @override
  void initState() {
    super.initState();
    this.loadAlarmsSharedPrefs();
    // this._sendMessage("alarmState");
  }

  @override
  void dispose() {
    super.dispose();
    this.saveAlarmsSharedPrefs();
  }

  List<Widget> getAllCards() {
    List<Widget> cards = [];
    this._cards.forEach((name, card) {
      cards.add(card);
    });
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [],
          ),
          Column(children: this.getAllCards()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  MaterialButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Icon(Icons.stop),
                    padding: EdgeInsets.all(14),
                    shape: CircleBorder(),
                    onPressed: () {
                      setState(() {
                        if (this.isAlarmActive) {
                          this._sendMessage("buzz: stop");
                          this.isAlarmActive = false;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('No active alarm !')));
                        }
                      });
                    },
                  )
                ],
              ),
              MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Icon(Icons.add),
                padding: EdgeInsets.all(16),
                shape: CircleBorder(),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext builder) {
                        return AlertDialog(
                          content: Stack(
                            children: [
                              Container(
                                width: 250,
                                height: 180,
                                child: Form(
                                  child: Column(
                                    children: [
                                      Form(
                                        child: Column(children: [
                                          TextField(
                                            controller: this._controller,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Name',
                                            ),
                                            onChanged: (String name) async {
                                              setState(() {
                                                print(name);
                                                this.currentName = name;
                                              });
                                            },
                                          ),
                                          DateTimeFormField(
                                            decoration: const InputDecoration(
                                              hintStyle: TextStyle(
                                                  color: Colors.black45),
                                              errorStyle: TextStyle(
                                                  color: Colors.redAccent),
                                              border: OutlineInputBorder(),
                                              suffixIcon:
                                                  Icon(Icons.event_note),
                                              labelText: 'Wake up time',
                                            ),
                                            mode: DateTimeFieldPickerMode.time,
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            validator: (e) => (e?.day ?? 0) == 1
                                                ? 'Please not the first day'
                                                : null,
                                            onDateSelected: (DateTime value) {
                                              setState(() {
                                                this.currentTime = value;
                                                /*this.wakeUpTime = value;
                                            this._sendMessage('wut: ' +
                                                this.wakeUpTime.toString());*/
                                                //this.addAlarm(value.toString());
                                              });
                                            },
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 10)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              MaterialButton(
                                                  color: Colors.green,
                                                  textColor: Colors.white,
                                                  child: Icon(Icons.check),
                                                  padding: EdgeInsets.all(16),
                                                  shape: CircleBorder(),
                                                  onPressed: () {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                      this.addAlarm(
                                                          this.currentName,
                                                          this.currentTime);
                                                    });
                                                  }),
                                            ],
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ],
          ),
          /*Center(
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
                  if (snapshot.hasError) print(snapshot.error);
                  return Text(snapshot.hasData
                      ? this._parseData(snapshot.data)
                      : 'Empty response');
                },
              )
            ],
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    this.getAlarmTime();
                  }),
            ],
          ),*/
        ],
      ),
    );
  }
}
