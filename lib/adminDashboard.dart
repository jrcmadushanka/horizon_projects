import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:horizon_projects/model/models.dart';
import 'package:horizon_projects/widget/AddUserDialog.dart';
import 'package:horizon_projects/widget/UserCardItem.dart';
import 'package:horizon_projects/widget/defaultButton.dart';

import 'login.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController adminIdController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController typeController = new TextEditingController();

  // Query get query => FirebaseFirestore.instance.collection('users').limit(20);

  final List<UserModel> _users = [];
  final key = GlobalKey<AnimatedListState>();
  QueryDocumentSnapshot _user;
  String userType;
  bool isUserUpdating = false;
  UserModel selectedUserModel;

  Future<void> _getUser() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: auth.currentUser.uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  setState(() {
                    _user = doc;
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

  _getAllUsers() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .listen((event) {
        for (var i = 0; i <= _users.length - 1; i++) {
          key.currentState.removeItem(0,
              (BuildContext context, Animation<double> animation) {
            return Container();
          });
        }
        _users.clear();
        event.docs.forEach((element) {
          UserModel user = UserModel(
              element.data().containsKey("uid") ? element["uid"] : "",
              element.data().containsKey("full_name")
                  ? element["full_name"]
                  : "",
              element.data().containsKey("admin_id") ? element["admin_id"] : "",
              element.data().containsKey("email") ? element["email"] : "",
              element.data().containsKey("type") ? element["type"] : "",
              "",
              element.id);
          _users.add(user);
          key.currentState.insertItem(_users.length - 1);
        });
      });
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  _logout() {
    try {
      auth
          .signOut()
          .then((value) => {
                Navigator.pop(context),
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()))
              })
          .onError((error, stackTrace) => {
                ScaffoldMessenger.of(context)
                    .showSnackBar(new SnackBar(content: Text("Logout Failed")))
              });
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Admin panel"),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: Stack(fit: StackFit.expand, children: <Widget>[
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedList(
                key: key,
                initialItemCount: _users.length,
                itemBuilder: (context, index, animation) =>
                    buildItem(_users[index], index, animation),
              ),
            )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add_circle_outline),
        label: Text('Add User'),
        backgroundColor: Colors.deepPurple[700],
        onPressed: () => {_showInsertUserPopup(), isUserUpdating = false},
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.jpeg"),
                fit: BoxFit.cover,
                colorFilter:
                    new ColorFilter.mode(Colors.black54, BlendMode.hardLight)),
          ),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Center(
                    child: Text(
                  _user != null
                      ? "Welcome " + _user["full_name"].toString()
                      : "",
                  textScaleFactor: 1.5,
                  style: new TextStyle(color: Colors.white),
                )),
                decoration: BoxDecoration(
                  color: Color.fromARGB(100, 138, 57, 162),
                ),
              ),
              ListTile(
                title: Text('logout',
                    style: new TextStyle(color: Colors.white, fontSize: 19)),
                tileColor: Color.fromARGB(100, 192, 65, 182),
                onTap: () {
                  _logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    if (mounted) {
      super.initState();
      _getUser();
      _getAllUsers();
    }
  }

  _showUpdateDialog(UserModel user) {
    adminIdController.text = user.admin_id;
    emailController.text = user.email;
    nameController.text = user.full_name;
    typeController.text = user.type;
    isUserUpdating = true;
    selectedUserModel = user;

    _showInsertUserPopup();
  }

  Widget buildItem(UserModel user, int index, Animation<double> animation) {
    return UserCardItem(
      user: user,
      animation: animation,
      onClick: (user) => _showUpdateDialog(user),
    );
  }

  _onSubmitCall() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    if (!isUserUpdating) {
      try {
        await auth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((value) => {
                  //auth.signOut(),
                  users
                      .add({
                        'full_name': nameController.text,
                        'uid': value.user.uid,
                        'type': userType,
                        'email': emailController.text,
                        'admin_id': adminIdController.text
                      })
                      .then((value) => {
                            print("User Added"),
                            Navigator.of(context, rootNavigator: true).pop(),
                            nameController.text = "",
                            passwordController.text = "",
                            adminIdController.text = "",
                            emailController.text = "",
                            typeController.text = ""
                          })
                      .catchError(
                          (error) => print("Failed to add user: $error"))
                });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    } else {
      if (selectedUserModel != null) {
        await users
            .doc(selectedUserModel.doc)
            .update({
              'full_name': nameController.text,
              'email': emailController.text,
              'admin_id': adminIdController.text
            })
            .then((value) => {
                  print("User Updated"),
                  Navigator.of(context, rootNavigator: true).pop(),
                  nameController.text = "",
                  passwordController.text = "",
                  adminIdController.text = "",
                  emailController.text = "",
                  typeController.text = ""
                })
            .catchError((error) => print("Failed to update user: $error"));
      }
    }
  }

  _onUserTypeSelect(String type) {
    this.userType = type;
  }

  _deleteUser(String doc) async {
    if (selectedUserModel != null) {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      await users
          .doc(selectedUserModel.doc)
          .delete()
          .then((value) => {
                print("User Deleted"),
                selectedUserModel = null,
                Navigator.of(context, rootNavigator: true).pop(),
                nameController.text = "",
                passwordController.text = "",
                adminIdController.text = "",
                emailController.text = "",
                typeController.text = ""
              })
          .catchError((error) => print("Failed to delete user: $error"));
    }
  }

  _showInsertUserPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AddNewUserDialog(
          adminIdController: adminIdController,
          emailController: emailController,
          nameController: nameController,
          passwordController: passwordController,
          typeController: typeController,
          onSubmitPressed: () => {_onSubmitCall()},
          onTypeSelect: (type) => {_onUserTypeSelect(type)},
          onDeletePressed: () => {_deleteUser(selectedUserModel.doc)},
        );
      },
    );
  }
}
