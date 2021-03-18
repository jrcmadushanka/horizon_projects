
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:horizon_projects/employeeDashboard.dart';
import 'package:horizon_projects/widget/defaultButton.dart';

import 'adminDashboard.dart';
import 'managerDashBoard.dart';

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
  StreamSubscription<User> authListener;

  UserCredential userCredential;

  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');
  final TextEditingController adminIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    authListener = auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        _getUser();
      //  _getItems();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    authListener.cancel();
  }

  Future<void> _getUser() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: auth.currentUser.uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) {
          //setState(() {
          if (doc["type"].toString() == "ADMIN") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AdminDashboard()));
          } else if (doc["type"].toString() == "MANAGER") {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ManagerDashboard()));
          } else{
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => EmployeeDashBoard()));
          }
          // });
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
          email:  _emailController.text,
          password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(new SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
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
                        Visibility(
                          child: new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Enter Email",
                                fillColor: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: MultiValidator([
                              EmailValidator(errorText: "Invalid Email"),
                              RequiredValidator(errorText: "* Required"),
                            ]),
                          ),
                          visible: _adminEmail == "",
                        ),
                        new TextFormField(
                            decoration: new InputDecoration(
                              labelText: "Enter Password",
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            validator: MultiValidator([
                              RequiredValidator(errorText: "* Required"),
                              MinLengthValidator(6,
                                  errorText:
                                  "Password should be atleast 6 characters"),
                              MaxLengthValidator(15,
                                  errorText:
                                  "Password should not be greater than 15 characters")
                            ])),
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
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
