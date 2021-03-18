import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizon_projects/model/models.dart';
import 'package:horizon_projects/widget/defaultButton.dart';

import 'login.dart';

class EmployeeDashBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EmployeeDashBoardState();
  }
}

class EmployeeDashBoardState extends State<EmployeeDashBoard> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  QueryDocumentSnapshot _user;
  final key = GlobalKey<AnimatedListState>();
  final List<Task> _tasks = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Employee Dashboard"),
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
                initialItemCount: _tasks.length,
                itemBuilder: (context, index, animation) =>
                    buildItem(_tasks[index], index, animation),
              ),
            )),
      ]),
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

  Widget buildItem(Task task, int index, Animation<double> animation) {
    return GestureDetector(
        onLongPress: () {
          _showUpdateProjectPopUp(task.status, task);
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                title: Text(task.title.toString(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "Status : " + task.status,
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
                tileColor: Colors.deepPurpleAccent[100],
              ),
              ListTile(
                title: Text("Description",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  task.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ),
              ListTile(
                title: Text(task.employeeName),
                subtitle: Text(
                  "EID : " + task.employee,
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              )
            ],
          ),
        ));
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  _getMyTasks() {
    try {
      FirebaseFirestore.instance
          .collection('tasks')
          .where('employee', isEqualTo: auth.currentUser.uid)
          .snapshots()
          .listen((QuerySnapshot querySnapshot) => {
                for (var i = 0; i <= _tasks.length - 1; i++)
                  {
                    if(key.currentState != null){
                      key.currentState.removeItem(0,
                              (BuildContext context,
                              Animation<double> animation) {
                            return Container();
                          })
                    }
                  },
                _tasks.clear(),
                querySnapshot.docs.forEach((element) {
                  Task task = Task(
                      element.data().containsKey("title")
                          ? element["title"]
                          : "",
                      element.data().containsKey("description")
                          ? element["description"]
                          : "",
                      element.data().containsKey("employee")
                          ? element["employee"]
                          : "",
                      element.data().containsKey("employeeName")
                          ? element["employeeName"]
                          : "",
                      element.data().containsKey("status")
                          ? element["status"]
                          : "",
                      element.id);
                  _tasks.add(task);

                  if(key.currentState != null) {
                    key.currentState.insertItem(_tasks.length - 1);
                  }
                })
              })
          .onError((error, stackTrace) => {print(stackTrace)});
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getUser() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: auth.currentUser.uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                _getMyTasks(),
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

  _updateStatus(String status, Task task) async {
    await FirebaseFirestore.instance
        .collection("tasks")
        .doc(task.id)
        .update({'status': status})
        .then((value) => {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Task updated"))),
              Navigator.of(context, rootNavigator: true).pop(),
            })
        .catchError((error) => print("Failed to update user: $error"));
  }

  _showUpdateProjectPopUp(String status, Task task) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final key = new GlobalKey<FormState>();
          return new AlertDialog(
            content: Form(
                key: key,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Update Project Status"),
                    new DropdownButtonFormField(
                      items: [
                        new DropdownMenuItem(
                          child: Text("Created"),
                          value: "Created",
                        ),
                        new DropdownMenuItem(
                            child: Text("Ongoing"), value: "Ongoing"),
                        new DropdownMenuItem(
                          child: Text("Finished"),
                          value: "Finished",
                        ),
                        new DropdownMenuItem(
                          child: Text("Cancelled"),
                          value: "Cancelled",
                        ),
                        new DropdownMenuItem(
                          child: Text("On Hold"),
                          value: "On Hold",
                        ),
                      ],
                      onChanged: (val) => {status = val},
                      hint: Text("Select the status"),
                      value: status,
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: DefaultButton("Update Project", () {
                        _updateStatus(status, task);
                      }),
                    )
                  ],
                )),
            actions: <Widget>[
              new TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }
}
