import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import './LoadingPage.dart';
import './ImageViewPage.dart';
import './ImageButton.dart';

class SearchPage extends StatefulWidget {

  SearchPage({Key key, this.title, this.search, this.page}) : super(key: key);

  final String title;
  final String search;
  final int page;

  @override
  _SearchPageState createState() => new _SearchPageState(title, search, page);
}

class _SearchPageState extends State<SearchPage> {

  _SearchPageState(this.title, this.search, this.page);

  final String title;
  final String search;
  final int page;
  Widget _currentComponent;
  Queue<Map> _imageQueue = new Queue();

  _forward() {
    Navigator.of(context).pop();
    Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return new SearchPage(title: 'Search - page ' + (page + 1).toString(), search: search, page: page + 1);
      }
    ));
  }

  _back() {
    Navigator.of(context).pop();
    Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return new SearchPage(title: 'Search - page ' + (page - 1).toString(), search: search, page: page - 1);
      }
    ));
  }

  _load() async {
    Widget forwardButton = new RaisedButton (onPressed: _forward,
      child: new Icon(Icons.chevron_right));

    Widget backButton = new RaisedButton (onPressed: _back,
      child: new Icon(Icons.chevron_left));

    var httpClient = createHttpClient();
    var res = await httpClient.read("https://e621.net/post/index.json?limit=60&page=" + page.toString() + "&tags=" + search,
      headers: {"User-Agent" : "MobiSix v0.2a"});
    var json = JSON.decode(res);
    httpClient.close();
    _imageQueue.addAll(json);

    var ch = <Widget>[];

    if (/*page > 9 ||*/ _imageQueue.length < 60){
      ch.add(backButton);
    } else if (page == 1 && _imageQueue.length == 60) {
      ch.add(forwardButton);
    } else {
      ch = [new Container (
        child: backButton,
        margin: const EdgeInsets.only(right: 4.0)
      ), forwardButton];
    }

    Widget _buttonComponent = new Center (
      child: new Row (
        children: ch,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.up
      )
    );

    setState((){
      _currentComponent = new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: new Column(
          children: <Widget>[
            new Flexible(
              flex: 6,
              child: new GridView.builder(
                itemCount : _imageQueue.length,
                padding: const EdgeInsets.all(10.0),
                itemBuilder: ibuilder,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4.0, crossAxisSpacing: 4.0)
              )
            ),
            new Flexible(
              flex: 1,
              child: _buttonComponent
            )
          ]
        )
      );
    });
  }

  _fetch() async {
    return _imageQueue.removeFirst();
  }

  Future<Map> req(index) {
      return _fetch().then((m) {return m;});
  }


  Widget ibuilder(BuildContext context, int index) {
    return new FutureBuilder<Map>(
      future: req(index),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Container();
          case ConnectionState.waiting: return new Container(color: Colors.grey.shade300);
          default:
            if (snapshot.hasError){
              return new Container(color: Colors.red.shade300);
            } else {
              return new Stack(
                children: <Widget>[
                  new Positioned.fill(
                    child: new Image.network(
                      snapshot.data["preview_url"],
                      fit: BoxFit.cover
                    )
                  ),
                  new Positioned.fill(
                    child: new ImageButton(
                      json: snapshot.data,
                      color: Colors.grey.shade300,
                      context: context,
                      child: new Container(
                        color: new Color(0x00000000)
                      )
                    )
                  )
                ]
              );
          }
        }
      }
    );
  }

  @override
  void initState() {
    super.initState();

    _currentComponent = new LoadingPage (title: title);

    _load();
  }

  @override
  Widget build(BuildContext context) {
    return _currentComponent;
  }
}
