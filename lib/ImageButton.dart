/*
 * dumb workaround because theres no way to pass arguments to onpressed of normal buttons
 * i just copied the code from here https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/flat_button.dart
 * and then redid it to what i needed
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/src/material/button.dart';
import 'package:flutter/src/material/theme.dart';
import './ImageViewPage.dart';

class ImageButton extends StatelessWidget {
  const ImageButton({
    Key key,
    this.onPressed,
    this.textColor,
    this.disabledTextColor,
    this.color,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.textTheme,
    this.colorBrightness,
    @required this.child,
    @required this.json,
    @required this.context
  }) : assert(child != null),
       super(key: key);
  final VoidCallback onPressed;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color splashColor;
  final Color highlightColor;
  final Color disabledColor;
  final ButtonTextTheme textTheme;
  final Brightness colorBrightness;
  final Widget child;
  final Map json;
  final BuildContext context;
  bool get enabled => onPressed != null;

  _showImage() {
    Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return new ImageViewPage(title: json['id'].toString(), json: json);
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialButton(
      onPressed: _showImage,
      textColor: enabled ? textColor : disabledTextColor,
      color: enabled ? color : disabledColor,
      highlightColor: highlightColor ?? Theme.of(context).highlightColor,
      splashColor: splashColor ?? Theme.of(context).splashColor,
      textTheme: textTheme,
      colorBrightness: colorBrightness,
      child: child
    );
  }
}
