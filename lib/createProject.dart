import 'dart:math';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:item_selector/item_selector.dart';
import 'package:select_form_field/select_form_field.dart';
import 'projectList.dart';

/// Flutter code sample for TabBar

// This sample shows the implementation of [TabBar] and [TabBarView] using a [DefaultTabController].
// Each [Tab] corresponds to a child of the [TabBarView] in the order they are written.

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final pages = <PageData>[

  PageData(
    title: 'ListView',
    icon: Icons.view_headline,
    builder: (_) => ListViewPage(),
  ),
];

class PageData {
  const PageData({this.title, this.icon, this.builder});
  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

/// This is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

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

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);



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

  @override
  Widget build(BuildContext context) {

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
//              Tab(
//                icon: Icon(Icons.brightness_5_sharp),
//              ),
            ],
          ),
        ),


        body: TabBarView(
          children: <Widget>[

            Container(
              padding: const EdgeInsets.all(20.0),
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
                      validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                      onDateSelected: (DateTime value) {
                        print(value);
                      },
                    ),

                    new Padding(
                        padding: const EdgeInsets.only(top: 10.0)
                    ),

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
                      validator: (e) => (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                      onDateSelected: (DateTime value) {
                        print(value);
                      },
                    ),

                    new TextFormField(
                      decoration: new InputDecoration(
                        labelText: "Project Cost",
                        hintText: 'Rs.'
                      ),
                    ),

                    new SelectFormField(
                      type: SelectFormFieldType.dropdown, // or can be dialog
                      initialValue: 'circle',
                      icon: Icon(Icons.account_circle),
                      labelText: 'Project Manager',
//                      items: _items,
                      onChanged: (val) => print(val),
                      onSaved: (val) => print(val),
                      ),




                  ],
                ),
              ),
            ),

            ItemSelectionController(
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index){
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
