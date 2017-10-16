import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
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

  /*It's extremely hard to make what I want when dealing with async so I'm putting it off for now.*/
  /*Future req() {
    page++;
    return httpClient.read("https://e621.net/post/index.json?limit=30&page=" + page.toString() + "&tags=" + search,
      headers: {"User-Agent" : "MobiSix v0.1"}).then((res) {return res;});
  }

  Widget ibuilder (BuildContext context, int index) {
    if (ind > 29 || page == 0){
      var future = req();
      future.then( (res) {
        this.response = res;
        this.json = JSON.decode(response);
        this.ind = 0;
        if (page > 300 || ind > json.length) return null;
        Map img = json[ind];
        ind++;
        return new Container(
          color: Colors.grey.shade300,
          child: new Image.network(
            img["sample_url"],
            fit: BoxFit.cover
          )
        );
      });
    } else {
      if (page > 300 || ind > json.length) return null;
      Map img = json[ind];
      ind++;
      return new Container(
        color: Colors.grey.shade300,
        child: new Image.network(
          img["sample_url"],
          fit: BoxFit.cover
        )
      );
    }
  }*/

  Future<List> req(index) {
    var httpClient = createHttpClient();
    return httpClient.read("https://e621.net/post/index.json?limit=1&page=" + index.toString() + "&tags=" + search,
      headers: {"User-Agent" : "MobiSix v0.1"}).then((res) {httpClient.close(); return JSON.decode(res);});
  }

/*  Widget ibuilder (BuildContext context, int index) {
    if (index > 750) return null;
    Future<List> future = req(index);
    future.then((res){
      if (res.length==0) return null;
      Map img = res[0];
      print(img);
      return new Container(
        color: Colors.grey.shade300,
        child: new Image.network(
          img["sample_url"],
          fit: BoxFit.cover
        )
      );
    });
  } */

  Widget ibuilder(BuildContext context, int index) {
    return new FutureBuilder<List>(
      future: req(index),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none: return new Container();
          case ConnectionState.waiting: return new Container(color: Colors.grey.shade300);
          default:
            if (snapshot.hasError){
              return new Container(color: Colors.red.shade300);
              print (snapshot.error);
            } else {
              return new Container(
                color: Colors.grey.shade300,
                child: new Image.network(
                  snapshot.data[0]["sample_url"],
                  fit: BoxFit.cover
                )
              );
            }
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new GridView.builder(
        padding: const EdgeInsets.all(20.0),
        itemBuilder: ibuilder,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2.0, crossAxisSpacing: 2.0)
      )
    );
  }
}
