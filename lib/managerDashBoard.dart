import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:horizon_projects/widget/defaultButton.dart';
import 'package:item_selector/item_selector.dart';

import 'model/models.dart';

Widget buildListItem(BuildContext context, int index, bool selected) {
  return Card(
    margin: EdgeInsets.all(10),
    elevation: selected ? 2 : 10,
    child: ListTile(
      leading: Icon(Icons.insert_drive_file),
      contentPadding: EdgeInsets.all(10),
      title: Text('Project ' + index.toString()),
    ),
  );
}

class ListViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ItemSelectionController(
      child: ListView.builder(
        itemCount: 50,
        itemBuilder: (BuildContext context, int index) {
          return ItemSelectionBuilder(
            index: index,
            builder: buildListItem,
          );
        },
      ),
    );
  }
}

class RectSelection extends ItemSelection {
  RectSelection(this.columns);

  final int columns;
  ItemSelection oldSelection = ItemSelection();

  int rowAt(int index) => index ~/ columns;

  int columnAt(int index) => index % columns;

  int indexAt(int row, int column) => column + row * columns;

  bool start(int start, int end) {
    oldSelection = ItemSelection(start, end);
    return false;
  }

  bool update(int start, int end) {
    // calculate rectangular selection bounds
    final startRow = rowAt(min(start, end));
    final endRow = rowAt(max(start, end));
    final startColumn = columnAt(min(start, end));
    final endColumn = columnAt(max(start, end));

    // construct new rectangular selection row by row
    final newSelection = ItemSelection();
    for (int r = startRow; r <= endRow; ++r) {
      final startIndex = indexAt(r, startColumn);
      final endIndex = indexAt(r, endColumn);
      newSelection.add(startIndex, endIndex);
    }

    // apply selection changes
    addAll(ItemSelection.copy(newSelection)..removeAll(oldSelection));
    removeAll(ItemSelection.copy(oldSelection)..removeAll(newSelection));

    oldSelection = newSelection;
    return true;
  }
}

class ManagerDashboard extends StatefulWidget {
  ManagerDashboard({Key key}) : super(key: key) {
    _getAllEmployees();
  }

  final List<UserModel> _managers = [];
  final List<DropdownMenuItem> _managerDropDownItems = [];
  final List<UserModel> _employee = [];

  final List<Map<String, dynamic>> _items = [
    {
      'value': 'boxValue',
      'label': 'Box Label',
      'icon': Icon(Icons.stop),
    },
    {
      'value': 'circleValue',
      'label': 'Circle Label',
      'icon': Icon(Icons.fiber_manual_record),
      'textStyle': TextStyle(color: Colors.red),
    },
    {
      'value': 'starValue',
      'label': 'Star Label',
      'enable': false,
      'icon': Icon(Icons.grade),
    }
  ];

  _getAllEmployees() async {
    FirebaseFirestore.instance
        .collection('users')
        .where('type', whereIn: ['MANAGER', 'EMPLOYER'])
        .get()
        .then((value) {
          print(value.docs.length.toString());
          UserModel userModel;
          value.docs.forEach((element) {
            userModel = UserModel(
                element.data().containsKey("uid") ? element["uid"] : "",
                element.data().containsKey("full_name")
                    ? element["full_name"]
                    : "",
                element.data().containsKey("admin_id")
                    ? element["admin_id"]
                    : "",
                element.data().containsKey("email") ? element["email"] : "",
                element.data().containsKey("type") ? element["type"] : "",
                "",
                element.id);

            if (userModel.type == "MANAGER") {
              _managers.add(userModel);
              _managerDropDownItems.add(new DropdownMenuItem(
                  child: Text(userModel.full_name), value: userModel.uid));
            } else {
              _employee.add(userModel);
            }
          });

          print(_employee.length.toString() +
              " Man =>  " +
              _managers.length.toString());
        });
  }

  @override
  State<StatefulWidget> createState() {
    return new ManagerDashBoardState(_managerDropDownItems);
  }
}

class ManagerDashBoardState extends State<ManagerDashboard> {
  final List<DropdownMenuItem> _managerDropDownItems;

  ManagerDashBoardState(this._managerDropDownItems);

  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    {
      return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(100, 212, 56, 255),
            title: Text('Projects'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: 'Create Project',
                  icon: Icon(Icons.add),
                ),
                Tab(
                  text: 'Project List',
                  icon: Icon(Icons.line_style),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: new Form(
                      key: key,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Project Name",
                                fillColor: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            validator: RequiredValidator(errorText: "Required"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          new Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                          ),
                          DateTimeFormField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_note),
                              labelText: 'Start Date',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (DateTime dateTime) {
                              if (dateTime == null) {
                                return "Date Time Required";
                              } else if (dateTime.millisecondsSinceEpoch <
                                  DateTime.now().millisecondsSinceEpoch) {
                                return "Date must be in future";
                              }
                              return null;
                            },
                            onDateSelected: (DateTime value) {
                              print(value);
                            },
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(top: 10.0)),
                          DateTimeFormField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_note),
                              labelText: 'End Date',
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (DateTime dateTime) {
                              if (dateTime == null) {
                                return "Date Time Required";
                              } else if (dateTime.millisecondsSinceEpoch <
                                  DateTime.now().millisecondsSinceEpoch) {
                                return "Date must be in future";
                              }
                              return null;
                            },
                            onDateSelected: (DateTime value) {
                              print(value);
                            },
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Project Cost", hintText: 'Rs.'),
                            validator: RequiredValidator(errorText: "Required"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Client", hintText: 'Client name'),
                            validator: RequiredValidator(errorText: "Required"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          new DropdownButtonFormField(
                            icon: Icon(Icons.account_circle),
                            items: _managerDropDownItems,
                            hint: Text("Select a Project Manager"),
                            validator: (value) {
                              if (value == null) {
                                return "Required";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (val) => print(val),
                            onSaved: (val) => print(val),
                          ),
                          new DropdownButtonFormField(
                            items: [
                              new DropdownMenuItem(
                                child: Text("Created"),
                                value: "created",
                              ),
                              new DropdownMenuItem(
                                  child: Text("Ongoing"), value: "onGoing"),
                              new DropdownMenuItem(
                                child: Text("Finished"),
                                value: "finished",
                              ),
                              new DropdownMenuItem(
                                child: Text("Cancelled"),
                                value: "cancelled",
                              ),
                              new DropdownMenuItem(
                                child: Text("On Hold"),
                                value: "onHold",
                              ),
                            ],
                            onChanged: (val) => {},
                            hint: Text("Select the status"),
                            value: "created",
                          ),
                          DefaultButton("Create Project", () {
                            key.currentState.validate();
                          })
                        ],
                      ),
                    ),
                  )),

              ItemSelectionController(
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    return ItemSelectionBuilder(
                      index: index,
                      builder: buildListItem,
                    );
                  },
                ),
              ),

//            Center(
//              child: Text('It\'s sunny here'),
//            ),
            ],
          ),
        ),
      );
    }
  }
}
