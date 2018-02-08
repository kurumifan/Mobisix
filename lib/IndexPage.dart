import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './ImageViewPage.dart';
import './SearchPage.dart';

class IndexPage extends StatefulWidget {

  IndexPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IndexPageState createState() => new _IndexPageState(title);
}

class _IndexPageState extends State<IndexPage> {
  static const platform = const MethodChannel('mobisix/perms');

  final String title;
  String search;

  _IndexPageState(this.title);

  void _updateSearch(String val){
   search = val;
  }

  void _search(){
    Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return new SearchPage(title: 'Search - page 1', search: search, page: 1);
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new Center(
        child: new Container(
          margin: const EdgeInsets.all(20.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                child: new TextField(
                  style: new TextStyle(height: 2.0),
                  onChanged: _updateSearch,
                  textAlign: TextAlign.center
                )
              ),
              new RaisedButton(
                child: new Text('Search',
                  textAlign: TextAlign.center
                ),
                onPressed: _search
              )
            ]
          )
        )
      ),
    );
  }
}
