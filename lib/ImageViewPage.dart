import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import './LoadingPage.dart';

class ImageViewPage extends StatefulWidget {

  ImageViewPage({Key key, this.title, this.url}) : super(key: key);

  final String title;
  final String url;

  @override
  _ImageViewPageState createState() => new _ImageViewPageState(title, url);
}

class _ImageViewPageState extends State<ImageViewPage> {
  static const platform = const MethodChannel('mobisix/perms');

  final String title;
  final String url;
  String img_url;
  String img_path;
  int _perm = 0;
  Widget _currentComponent;

  _ImageViewPageState(this.title, this.url);

  Widget generateImagePage(Map json) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new Center(
        child: new ListView(
          padding: const EdgeInsets.all(10.0),
          children: <Widget>[
            new Container(
              margin: new EdgeInsets.only(bottom: 4.0),
              child: new Image.network(json['file_url'])
            ),
            new RaisedButton(onPressed: _save,
              child: new Text('Download',
            textAlign: TextAlign.center)
            ),
          ],
        ),
      ),
    );
  }

  _load() async {
    var httpClient = createHttpClient();
    var response = await httpClient.read(url, headers: {"User-Agent" : "MobiSix v0.1"});
    if (!mounted) return;
    var json = JSON.decode(response);
    var newComponent = generateImagePage(json);
    setState((){
      _currentComponent = newComponent;
      img_url = json['file_url'];
      img_path = json['md5'] + '_' +  new DateTime.now().millisecondsSinceEpoch.toString() + '.' + json['file_ext'];
    });
  }

  _save() async {
    await _getPerms();
    if (_perm == 0){
      return;
    } else {
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
  void initState() {
    super.initState();

    _currentComponent = new LoadingPage (title: title);

    _load();
  }

  @override
  Widget build(BuildContext context) {
    print("Building");
    return _currentComponent;
  }
}
