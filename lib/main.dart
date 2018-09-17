import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Program {
  final String time;
  final String title;

  Program({this.time, this.title});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(time: json['time'], title: json['title']);
  }
}

void main() => runApp(new MoorishTVApp());

class MoorishTVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Schedule for Al Aoula',
      theme: new ThemeData(
        primaryColor: Colors.lightGreen[300],
      ),
      home: MoorishTV(),
    );
  }
}

class MoorishTVState extends State<MoorishTV> {
  var _programs;
  var _isLoading = false;
  final prodUrl = 'http://api.norhaaklabs.com/programs';
  final devUrl = 'http://192.168.1.15:5000/programs';
  final Set<Program> _saved = new Set<Program>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

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
    final arabic_title = 'شبكة البرامج ';
    final french_title = 'Aujourd\'hui sur Al Aoula';
    return Scaffold(
        appBar:
            AppBar(title: Text(french_title), actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.list),
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
          child:
              _isLoading ? new CircularProgressIndicator() : _buildPrograms(),
        ));
  }

  Widget _buildPrograms() {
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
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
        ),
        onTap: () {
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
                  textAlign: TextAlign.right,
                ),
                trailing: new Text(
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
              title: const Text('Vos Favoris'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }
}

class MoorishTV extends StatefulWidget {
  @override
  MoorishTVState createState() => new MoorishTVState();
}
