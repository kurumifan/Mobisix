import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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
  int _perm = 0;
  Widget _currentComponent;

  _ImageViewPageState(this.title, this.json);

  Widget _build(BuildContext context) {
    return new Center(
      child: new ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          new Container(
            margin: new EdgeInsets.only(bottom: 4.0),
            child: new Image.network(json['sample_url'])
          ),
          new RaisedButton(
            child: new Text('Download',
              textAlign: TextAlign.center),
            onPressed: (){_save(context);}
          ),
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
    }
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
  Widget build(BuildContext context) {
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
