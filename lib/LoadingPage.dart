import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

class LoadingPage extends StatelessWidget{
  LoadingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new Center(
        //child: new CupertinoActivityIndicator(animating: true),
        child: new Image.asset('assets/loading.gif')
      ),
    );
  }
}
