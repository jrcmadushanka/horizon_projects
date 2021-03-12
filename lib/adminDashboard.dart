import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horizon_projects/main.dart';
import 'package:horizon_projects/widget/UserCard.dart';
import 'package:horizon_projects/widget/UserListView.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  QueryDocumentSnapshot _user;

  // List
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<int> _list = ListModel<int>();
  int _selectedItem;
  int _nextItem = 0; // The next item inserted when the user presses the '+' button.
  ////

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

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return UserCard(
      animation: animation,
      item: _list[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
      },
    );
  }

  Widget _buildRemovedItem(
      int item, BuildContext context, Animation<double> animation) {
    return UserCard(
      animation: animation,
      item: item,
      selected: false,
      // No gesture detector here: we don't want removed items to be interactive.
    );
  }

  // Insert the "next item" into the list model.
  void _insert() {
    final int index =
    _selectedItem == null ? _list.length : _list.indexOf(_selectedItem);
    _list.insert(index, _nextItem++);
  }

  // Remove the selected item from the list model.
  void _remove() {
    if (_selectedItem != null) {
      _list.removeAt(_list.indexOf(_selectedItem));
      setState(() {
        _selectedItem = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Admin panel"),
        backgroundColor: Color.fromARGB(100, 212, 56, 255),
      ),
      body:
       Stack(fit: StackFit.expand, children: <Widget>[
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
              child: UserListView(
                _listKey,
                _list,
                _selectedItem
              ),
            )),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _insert,
        icon: Icon(Icons.add_circle_outline),
        label: Text('Add User'),
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
                focusColor: Colors.black87,
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

      _list = ListModel<int>(
        listKey: _listKey,
        initialItems: <int>[],
        removedItemBuilder: _buildRemovedItem,
      );
      _nextItem = 0;
    }
  }
}

class ListModel<E> {
  ListModel({
    this.listKey,
    this.removedItemBuilder,
    Iterable<E> initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}
