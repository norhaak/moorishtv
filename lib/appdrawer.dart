import 'package:flutter/material.dart';
import 'package:moorishtv/channelpage.dart';

class AppDrawer extends StatelessWidget {
  final _channelsNames = [
    'Al Oula',
    'Arrayadia',
    'Assadissa',
    'Aflam TV',
    'Attakafia',
    'Laayoune'
  ];

  @override
  Widget build(BuildContext context) {
    final drawerItems = <Widget>[];
    drawerItems.add(getDrawerHeader());
    drawerItems.addAll(buildChanelsTiles(_channelsNames, context));
    Drawer drawer = new Drawer(
      child: new ListView(children: drawerItems),
    );

    return drawer;
  }

  DrawerHeader getDrawerHeader() {
    return new DrawerHeader(
      child: new Text(
        "MoorishTV",
        style: new TextStyle(
          fontSize: 28.0,
        ),
      ),
      decoration: new BoxDecoration(color: Colors.lightGreen[300]),
      margin: EdgeInsets.only(bottom: 0.0),
    );
  }

  buildChanelsTiles(_channelsNames, context) {
    final _channelsTiles = <Widget>[];
    _channelsNames.forEach((channelName) {
      _channelsTiles.add(_buildChannelTile(channelName, context));
      _channelsTiles.add(new Divider());
    });
    return _channelsTiles;
  }

  Widget _buildChannelTile(channelName, context) {
    final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
    return ListTile(
        title: Text(
          channelName,
          style: _biggerFont,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        ),
        leading: new Icon(
          Icons.favorite_border,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new ChannelPage(channelName)));
        });
  }
}

