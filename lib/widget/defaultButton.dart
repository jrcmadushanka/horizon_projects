import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget{
  final String text;
  final Function onClick;

  DefaultButton(this.text, this.onClick);

  @override
  Widget build(BuildContext context) {
    return new MaterialButton(
      height: 30.0,
      minWidth: 150.0,
      color: Colors.purple,
      splashColor: Colors.black,
      textColor: Colors.white,
      child: new Text(text, textScaleFactor: 1.1),
      onPressed: onClick
    );
  }
}