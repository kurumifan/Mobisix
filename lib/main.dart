import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import './ImageViewPage.dart';

void main() {
  runApp(new MobiSix());
}

class MobiSix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Mobisix',
      theme: new ThemeData(
        primaryColor: Colors.indigo,
        backgroundColor: Colors.white,
        canvasColor: Colors.blue.shade900,
        accentColor: Colors.lightBlueAccent.shade100,
        brightness: Brightness.dark,
      ),
      home: new ImageViewPage(title: 'Mobisix', url: 'https://e621.net/post/show.json?id=1356446'),
    );
  }
}