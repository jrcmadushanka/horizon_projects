import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:horizon_projects/adminDashboard.dart';
import 'package:horizon_projects/widget/defaultButton.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  var _adminName = "";
  var _adminEmail = "";
  TextEditingController _emailController = TextEditingController(text: "");
  final FirebaseAuth auth = FirebaseAuth.instance;

  UserCredential userCredential;

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final TextEditingController adminIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        _getUser();
      }
    });
  }

  Future<void> _getUser() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: auth.currentUser.uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  setState(() {
                    if (doc["type"].toString() == "ADMIN") {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminDashboard()));
                    }
                  });
                })
              })
          .onError((error, stackTrace) => {print(stackTrace)});
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _firebaseLogin() async {
    try {
      print("clicked");
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _adminEmail == "" ? _emailController.text : _adminEmail,
          password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(new SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _adminVerification() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('admin_id', isEqualTo: adminIdController.text)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                print("Got it" + querySnapshot.docs.toString()),
                querySnapshot.docs.forEach((doc) {
                  print(doc["full_name"]);
                  print(doc["email"]);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Welcome " + doc["full_name"]),
                  ));
                  setState(() {
                    _adminName = doc["full_name"];
                    _adminEmail = doc["email"];
                    _emailController.text = "**************************";
                  });
                  Navigator.pop(context);
                  return doc["full_name"];
                })
              })
          .onError((error, stackTrace) => {print(stackTrace)});
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  void _showAdminPopup() {
    if (_adminEmail == "")
      showDialog(
          context: context,
          builder: (BuildContext context) {
            final key = new GlobalKey<ScaffoldState>();
            return new AlertDialog(
              key: key,
              title: const Text('Please insert your admin ID'),
              content: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Form(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new TextFormField(
                          decoration: new InputDecoration(
                              labelText: "Admin ID", fillColor: Colors.white),
                          controller: adminIdController,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                        ),
                        new DefaultButton("Submit", () => _adminVerification())
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
                new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Skip'),
                ),
              ],
            );
          });
    else
      passwordController.text = "";

    setState(() {
      _adminName = "";
      _adminEmail = "";
      _emailController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: new Stack(fit: StackFit.expand, children: <Widget>[
        new Image(
          image: new AssetImage("assets/background.jpeg"),
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black87,
        ),
        new Theme(
          data: new ThemeData(
              brightness: Brightness.dark,
              inputDecorationTheme: new InputDecorationTheme(
                  // hintStyle: new TextStyle(color: Colors.blue, fontSize: 20.0),
                  labelStyle: new TextStyle(
                      color: Color.fromARGB(100, 224, 146, 252),
                      fontSize: 22.0),
                  focusColor: Color.fromARGB(100, 224, 146, 252))),
          // isMaterialAppTheme: true,
          child: Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Text(
                  "Welcome " +
                      (_adminName != "" ? _adminName + " " : "") +
                      "to Horizon Project Management System ",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Color.fromARGB(100, 212, 56, 255),
                      fontWeight: FontWeight.bold),
                  textScaleFactor: 2,
                ),
                new Container(
                  padding: const EdgeInsets.all(40.0),
                  child: new Form(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new TextFormField(
                          decoration: new InputDecoration(
                              labelText: "Enter Email",
                              fillColor: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          readOnly: _adminEmail != "",
                        ),
                        new TextFormField(
                          decoration: new InputDecoration(
                            labelText: "Enter Password",
                          ),
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                        ),
                        new Padding(
                          padding: const EdgeInsets.only(top: 60.0),
                        ),
                        new DefaultButton(
                            "Login",
                            () => _emailController.text != "" &&
                                    passwordController.text != ""
                                ? _firebaseLogin()
                                : ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please insert both email & password")),
                                  ))
                      ],
                    ),
                  ),
                ),
                new MaterialButton(
                  onPressed: _showAdminPopup,
                  color: Colors.black,
                  splashColor: Colors.grey,
                  textColor: Colors.white,
                  child: new Text(
                      (_adminEmail == "" ? "Administrator " : "User") +
                          " Login"),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
