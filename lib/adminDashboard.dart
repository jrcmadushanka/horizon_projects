import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {

  final FirebaseAuth auth = FirebaseAuth.instance;
  var _user = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        body: new Stack(fit: StackFit.expand, children: <Widget>[
          Text(_user)
        ])
    );
  }

  @override
  void initState() {
    super.initState();

    if (auth.currentUser != null) {
      _user = auth.currentUser.uid;
    }
  }
}