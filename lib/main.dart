import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Program {
  final String date;
  final String time;
  final String title;

  Program({this.date, this.time, this.title});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
        date: json['date'], time: json['time'], title: json['title']);
  }
}

void main() async {
  runApp(new MoorishTVApp());
}

class MoorishTVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TV Schedule for Al Aoula',
      theme: new ThemeData(
        primaryColor: Colors.lightGreen[300],
      ),
      home: MoorishTV(),
    );
  }
}

class MoorishTVState extends State<MoorishTV> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var _programs;
  var _isLoading = false;
  final prodUrl = 'http://api.norhaaklabs.com/programs';
  final devUrl = 'http://192.168.1.15:5000/programs';
  final Set<Program> _saved = new Set<Program>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);
  }

  _fetchTVPrograms() async {
    final response = await http.get(prodUrl);

    var programs = <Program>[];
    if (response.statusCode == 200) {
      final map = json.decode(response.body);
      final programsJson = map["programs"];
      programsJson.forEach((programJson) {
        Program program = new Program.fromJson(programJson);
        programs.add(program);
      });
    } else {
      throw Exception('Faild to load programs');
    }

    setState(() {
      this._isLoading = false;
      this._programs = programs;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final arabicTitle = 'شبكة البرامج ';
    final frenchTitle = 'Aujourd\'hui sur Al Aoula';
    return Scaffold(
      appBar: AppBar(title: Text(frenchTitle), actions: <Widget>[
        new IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _pushSaved,
        ),
        new IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            print("Reloading...");
            setState(() {
              _isLoading = true;
            });
            _fetchTVPrograms();
          },
        )
      ]),
      body: new Center(
        child: _isLoading ? new CircularProgressIndicator() : _buildPrograms(),
      ),
    );
  }

  Widget _buildPrograms() {
    if (this._programs == null) {
      _fetchTVPrograms();
      return new CircularProgressIndicator();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0.0),
      itemCount: this._programs != null ? this._programs.length : 0,
      itemBuilder: (context, i) {
        final program = this._programs[i];
        return new Column(
          children: <Widget>[_buildRow(program), new Divider()],
        );
      },
    );
  }

  Widget _buildRow(Program program) {
    final bool alreadySaved = _saved.contains(program);
    return ListTile(
        leading: Text(program.time, style: _biggerFont),
        title: Text(
          program.title,
          style: _biggerFont,
          textAlign: TextAlign.left, // right for Arabic
          textDirection: TextDirection.rtl, // ltr for Arabic
        ),
        trailing: new Icon(
          alreadySaved ? Icons.notifications_active : Icons.notifications_none,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () async {
          await _scheduleNotification(program);
          setState(() {
            if (alreadySaved) {
              _saved.remove(program);
            } else {
              _saved.add(program);
            }
          });
        });
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (Program program) {
              return new ListTile(
                title: new Text(
                  program.title,
                  style: _biggerFont,
                  textAlign: TextAlign.left,
                ),
                leading: new Text(
                  program.time,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Notifications'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future _scheduleNotification(Program program) async {
    var _programStartDateTime =
        DateTime.parse("${program.date} ${program.time}");
    var scheduledNotificationDateTime =
        _programStartDateTime.subtract(new Duration(minutes: 15));
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: '@mipmap/ic_launcher',
        sound: 'slow_spring_board',
        largeIcon: '@mipmap/ic_launcher',
        largeIconBitmapSource: BitmapSource.Drawable,
        vibrationPattern: vibrationPattern,
        color: const Color.fromARGB(255, 255, 0, 0));
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        program.title,
        'this program starts in 15min',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }
}

class MoorishTV extends StatefulWidget {
  @override
  MoorishTVState createState() => new MoorishTVState();
}
