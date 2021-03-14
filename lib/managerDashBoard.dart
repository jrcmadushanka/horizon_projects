import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:item_selector/item_selector.dart';
import 'package:select_form_field/select_form_field.dart';

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
  ManagerDashboard({Key key}) : super(key: key){
    _getAllEmployees();
  }

  final List<UserModel> _managers = [];
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
    UserModel user;
    FirebaseFirestore.instance
        .collection('users')
        .where('type', arrayContainsAny: ["MANAGER", "EMPLOYEE"])
        .get()
        .then((value) => {
              value.docs.forEach((element) => {
                    user = UserModel(
                        element.data().containsKey("uid") ? element["uid"] : "",
                        element.data().containsKey("full_name")
                            ? element["full_name"]
                            : "",
                        element.data().containsKey("admin_id")
                            ? element["admin_id"]
                            : "",
                        element.data().containsKey("email")
                            ? element["email"]
                            : "",
                        element.data().containsKey("type")
                            ? element["type"]
                            : "",
                        "",
                        element.id)
                  }),
              if (user.type == "MANAGER")
                {_managers.add(user)}
              else
                {_employee.add(user)}
            });
  }

  @override
  State<StatefulWidget> createState() {
    return new ManagerDashBoardState();
  }
}

class ManagerDashBoardState extends State<ManagerDashboard>{

  @override
  Widget build(BuildContext context) {
    {
      return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
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
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Project Name",
                                fillColor: Colors.white),
                            keyboardType: TextInputType.emailAddress,
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
                            mode: DateTimeFieldPickerMode.date,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (e) => (e?.day ?? 0) == 1
                                ? 'Please not the first day'
                                : null,
                            onDateSelected: (DateTime value) {
                              print(value);
                            },
                          ),
                          new Padding(padding: const EdgeInsets.only(top: 10.0)),
                          DateTimeFormField(
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(color: Colors.black45),
                              errorStyle: TextStyle(color: Colors.redAccent),
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.event_note),
                              labelText: 'End Date',
                            ),
                            mode: DateTimeFieldPickerMode.date,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (e) => (e?.day ?? 0) == 1
                                ? 'Please not the first day'
                                : null,
                            onDateSelected: (DateTime value) {
                              print(value);
                            },
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Project Cost", hintText: 'Rs.'),
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Client", hintText: 'Client name'),
                          ),
                          new SelectFormField(
                            type: SelectFormFieldType.dropdown,
                            // or can be dialog
                            initialValue: 'circle',
                            icon: Icon(Icons.account_circle),
                            labelText: 'Project Manager',
//                      items: _items,
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
                          )
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
