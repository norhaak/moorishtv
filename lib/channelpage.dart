import 'package:flutter/material.dart';
import 'package:moorishtv/appdrawer.dart';

class ChannelPage extends StatelessWidget {
  final _channelName;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: new AppDrawer(),
      appBar: new AppBar(title: new Text("$_channelName")),
      body: new Text("Page content goes here"),
    );
  }

  ChannelPage(this._channelName);
}
