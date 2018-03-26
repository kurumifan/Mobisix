import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import './LoadingPage.dart';

class ImageViewPage extends StatefulWidget {

  ImageViewPage({Key key, this.title, this.json}) : super(key: key);

  final String title;
  final Map json;

  @override
  _ImageViewPageState createState() => new _ImageViewPageState(title, json);
}

class _ImageViewPageState extends State<ImageViewPage> {
  static const platform = const MethodChannel('mobisix/perms');

  final String title;
  final Map json;
  String img_url;
  String img_path;
  List<Map> commentsjson;
  int _perm = 0;
  Widget _currentComponent;
  bool _loading;

  _ImageViewPageState(this.title, this.json);

  Widget _build(BuildContext context) {
    Widget ch;
    TextStyle scorestyle;
    Text ratingtext;
    var comments = <Widget>[];

    TextStyle defaultstyle = new TextStyle(fontSize: 18.0);

    // none of this works rn so if you try to pull up a video youre gonna get an error
    if (json['file_ext'] == "webm" || json['file_ext'] == "mp4") {
      ch = new Chewie (
        new VideoPlayerController(json['file_url']),
        aspectRatio: json['width']/json['height'],
        autoPlay: true,
        looping: true
      );
      //for debugging purposes
      //ch = new Image.network("https://vignette.wikia.nocookie.net/gtawiki/images/b/bd/BigSmoke-GTASA.jpg");
    } else {
      ch = new Image.network(json['sample_url']);
    }

    if (json['score'] < 0) {
      scorestyle = new TextStyle(color: Colors.red.shade700, fontSize: 18.0);
    } else if (json['score'] == 0) {
      scorestyle = new TextStyle(color: Colors.white, fontSize: 18.0);
    } else {
      scorestyle = new TextStyle(color: Colors.lightGreen.shade700, fontSize: 18.0);
    }

    if (json['rating'] == 'e') {
      ratingtext = new Text (
        "Explicit",
        textAlign: TextAlign.right,
        style: new TextStyle(color: Colors.red.shade700, fontSize: 18.0)
      );
    } else if (json['rating'] == 'q') {
      ratingtext = new Text (
        "Questionable",
        textAlign: TextAlign.right,
        style: new TextStyle(color: Colors.yellowAccent, fontSize: 18.0)
      );
    } else {
      ratingtext = new Text (
        "Safe",
        textAlign: TextAlign.right,
        style: new TextStyle(color: Colors.lightGreen.shade700, fontSize: 18.0)
      );
    }
    RegExp exp = new RegExp(r']"(.*)":\/');
    for (var comment in commentsjson) {
      var body = "";
      var name = "";
      var match = exp.firstMatch(comment["body"]);
      if (match == null) {
        body = comment['body'];
      } else {
        // dart pls add end of string indexes for substring so i can do name = (match.group(0)).substring(2, -3)
        name = ((match.group(0)).replaceAll(new RegExp(r']"'), '')).replaceAll(new RegExp(r'":\/'), '');
        body = comment['body'].replaceAll(new RegExp(r'\[quote\]((.|\n|\r|\r\n)*)\[\/quote\]'), '@' + name + "\n");
      }
      comments.add(new Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(4.0),

        color: Colors.blueAccent.shade700,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              "Posted by " + comment['creator'] + " at " + comment['created_at'] + "\n",
              style: new TextStyle(fontStyle: FontStyle.italic)
            ),

            new Text(
              body
            )
          ]
        )
      ));
    }

    return new Center(
      child: new ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            child: ch
          ),
          new Container(
            margin: const EdgeInsets.only(bottom: 8.0, left: 12.0, right: 12.0),
            child: new RaisedButton(
              child: new Text("Download",
                textAlign: TextAlign.center),
              onPressed: (){_save(context);}
            )
          ),
          new Container(
            padding: const EdgeInsets.only(left: 48.0, right: 48.0, bottom: 12.0),
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Text(
                      "Score:",
                      style: new TextStyle(fontSize: 18.0)
                    ),
                    new Expanded(
                      child: new Text(
                        json["score"].toString(),
                        textAlign: TextAlign.right,
                        style: scorestyle
                      )
                    )
                  ]
                ),

                new Row(
                  children: <Widget>[
                    new Text(
                      "Favorites:",
                      style: new TextStyle(fontSize: 18.0)
                    ),
                    new Expanded(
                      child: new Text(
                        json["fav_count"].toString(),
                        textAlign: TextAlign.right,
                        style: new TextStyle(fontSize: 18.0)
                      )
                    )
                  ]
                ),

                new Row(
                  children: <Widget>[
                    new Text(
                      "Rating:",
                      style: new TextStyle(fontSize: 18.0)
                    ),
                    new Expanded(
                      child: ratingtext
                    )
                  ]
                )
              ]
            )
          ),

          new Column(
            children: comments
          )

        ],
      ),
    );


  }

  _snack(BuildContext ctx) async {
    Scaffold.of(ctx).showSnackBar(
      new SnackBar(
        content: new Text ("Downloading $img_url"),
        duration: new Duration(seconds: 2)
      )
    );
  }

  _save(BuildContext ctx) async {
    await _getPerms();
    if (_perm == 0){
      return;
    } else {
      _snack(ctx);
      var httpClient = createHttpClient();
      var response = await httpClient.readBytes(img_url, headers: {"User-Agent" : "MobiSix v0.1"});
      var dir = (await getExternalStorageDirectory()).path;
      var file = await new File('$dir/Pictures/Mobisix/$img_path').create(recursive: true);
      await file.writeAsBytes(response);
      await platform.invokeMethod('mediaScan', {'filepath' : '$dir/Pictures/Mobisix/$img_path'});
      httpClient.close();
    }
  }

  _load() async {
    var httpClient = createHttpClient();
    var res = await httpClient.read("https://e621.net/comment/index.json?post_id=" + json['id'].toString(),
      headers: {"User-Agent" : "MobiSix v0.3a"});
    httpClient.close();
    setState((){
      commentsjson = JSON.decode(res);
      _loading = false;
    });
  }

  _getPerms() async {
    try {
      int permResult = await platform.invokeMethod('getPermissions');
      _perm = permResult;
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _loading = true;

    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new LoadingPage (title: title);
    } else {
      img_url = json['file_url'];
      img_path = json['md5'] + '.' + json['file_ext'];
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: new Builder(
          builder: _build
        )
      );
    }
  }
}
