import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import './LoadingPage.dart';

class SearchPage extends StatefulWidget {

  SearchPage({Key key, this.title, this.search}) : super(key: key);

  final String title;
  final String search;

  @override
  _SearchPageState createState() => new _SearchPageState(title, search);
}

class _SearchPageState extends State<SearchPage> {

  _SearchPageState(this.title, this.search);

  final String title;
  final String search;
  Widget _currentComponent;
  Queue<Map> _imageQueue = new Queue();
  int _page = 0;
  bool _stopped = false;
  var _loadingMutex = new SynchronizedLock();

  _load() async{
    print("loading!");
    print(_page);
    var httpClient = createHttpClient();
    var res = await httpClient.read("https://e621.net/post/index.json?limit=100&page=" + _page.toString() + "&tags=" + search,
      headers: {"User-Agent" : "MobiSix v0.1"});
    var json = JSON.decode(res);
    httpClient.close();
    _imageQueue.addAll(json);
    if (_page == 0) {
      if (_imageQueue.length < 100) _page = 10;
      setState((){
        _currentComponent = new Scaffold(
          appBar: new AppBar(
            title: new Text(title),
          ),
          body: new GridView.builder(
            padding: const EdgeInsets.all(10.0),
            itemBuilder: ibuilder,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4.0, crossAxisSpacing: 4.0)
          )
        );
      });
    } else {
      if (_imageQueue.length < 100) _page = 10;
    }
  }

  _fetch() async {
    if (_imageQueue.length < 20 && _page < 10) {
      while (_loadingMutex.locked) {
        await new Future.delayed(new Duration(milliseconds: 1));
      }
      await _loadingMutex.synchronized(() async{
        if (_imageQueue.length < 20) {
          _page++;
          await _load();
        }
      });
    }
    return _imageQueue.removeFirst();
  }

  Future<Map> req(index) {
      return _fetch().then((m) {
        if (_imageQueue.length == 0) {
          return {'undefined' : true};
        } else {
          return m;
        }
      });
  }


  Widget ibuilder(BuildContext context, int index) {
    if (_stopped) {return null;} else{
    return new FutureBuilder<Map>(
      future: req(index),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Container();
          case ConnectionState.waiting: return new Container(color: Colors.grey.shade300);
          default:
            if (snapshot.hasError){
              print(snapshot.error);
              return new Container(color: Colors.red.shade300);
            } else {
              if (snapshot.data.containsKey('undefined')) {
                _stopped = true;
                return new Container();
              } else {
                return new Container(
                  color: Colors.grey.shade300,
                  child: new Image.network(
                    snapshot.data["sample_url"],
                    fit: BoxFit.cover
                  )
                );
              }
            }
        }
      }
    );
  }}

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
