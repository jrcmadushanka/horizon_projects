import 'dart:math';
import 'dart:ui';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:horizon_projects/widget/defaultButton.dart';
import 'package:item_selector/item_selector.dart';
import 'package:horizon_projects/widget/ProjectCardItem.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import 'model/models.dart';

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
    addAll(ItemSelection.copy(newSelection)
      ..removeAll(oldSelection));
    removeAll(ItemSelection.copy(oldSelection)
      ..removeAll(newSelection));

    oldSelection = newSelection;
    return true;
  }
}

class ManagerDashboard extends StatefulWidget {
  ManagerDashboard({Key key, this.projectModel, this.animation, this.onClick}) : super(key: key) {
    _getAllEmployees();
    _getAllProjects();
    _getOnHoldProjects();
  }

  final superkey = GlobalKey<AnimatedListState>();
  final List<UserModel> _managers = [];
  final List<DropdownMenuItem> _managerDropDownItems = [];
  final List<UserModel> _employee = [];
  final List<DropdownMenuItem> _employeeDropDownItems = [];
  final List<ProjectModel> _project = [];
  final List<ProjectModel> _projects = [];
  final List<ProjectModel> _onHoldProjects = [];

  final ProjectModel projectModel;
  final Animation animation;
  final Function(ProjectModel) onClick;

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
          _employeeDropDownItems.add(new DropdownMenuItem(
              child: Text(userModel.full_name), value: userModel.uid));
        }
      });

      print(_employee.length.toString() +
          " Man =>  " +
          _managers.length.toString());
    });
  }

  _getOnHoldProjects() async {

    FirebaseFirestore.instance
        .collection('projects')
        .where('status', whereIn: ['onHold'])
        .get()
        .then((value) {
      print("Length of project list " + value.docs.length.toString());

      for (var i = 0; i <= _onHoldProjects.length - 1; i++) {
        superkey.currentState.removeItem(0,
                (BuildContext context, Animation<double> animation) {
              return Container();
            });
      }
      _onHoldProjects.clear();

      ProjectModel projectModel;
      value.docs.forEach((element) {
        projectModel = ProjectModel(
            element.data().containsKey("pid")
                ? element["pid"]
                : "",
            element.data().containsKey("project_name")
                ? element["project_name"]
                : "",
            element.data().containsKey("start_date")
                ? element["start_date"]
                : "",
            element.data().containsKey("end_date") ? element["end_date"] : "",
            element.data().containsKey("project_cost")
                ? element["project_cost"]
                : "",
            element.data().containsKey("project_manager")
                ? element["project_manager"]
                : "",
            element.data().containsKey("client") ? element["client"] : "",
            element.data().containsKey("status") ? element["status"] : ""
//            element.id);
        );

        _onHoldProjects.add(projectModel);
//        superkey.currentState.insertItem(_onHoldProjects.length - 1);
      });
      print(_onHoldProjects.length);
      print(_onHoldProjects);
    });
  }

  _getAllProjects() async {

    FirebaseFirestore.instance.collection('projects').get().then((value) {
      print("Length of project list " + value.docs.length.toString());

      for (var i = 0; i <= _projects.length - 1; i++) {
        superkey.currentState.removeItem(0,
                (BuildContext context, Animation<double> animation) {
              return Container();
            });
      }
      _projects.clear();

      ProjectModel projectModel;
      value.docs.forEach((element) {
        projectModel = ProjectModel(
            element.data().containsKey("pid")
                ? element["pid"]
                : "",
            element.data().containsKey("project_name")
                ? element["project_name"]
                : "",
            element.data().containsKey("start_date")
                ? element["start_date"]
                : "",
            element.data().containsKey("end_date") ? element["end_date"] : "",
            element.data().containsKey("project_cost")
                ? element["project_cost"]
                : "",
            element.data().containsKey("project_manager")
                ? element["project_manager"]
                : "",
            element.data().containsKey("client") ? element["client"] : "",
            element.data().containsKey("status") ? element["status"] : ""
//            element.id);
        );

        _projects.add(projectModel);
        superkey.currentState.insertItem(_projects.length - 1);
      });
      print(_projects.length);
      print(_projects);
    });
  }

  @override
  State<StatefulWidget> createState() {
    return new ManagerDashBoardState(
        _managerDropDownItems, _employeeDropDownItems, _employee, _project,
        _managers, superkey,_projects,projectModel,animation,onClick,_onHoldProjects);
  }
}

class ManagerDashBoardState extends State<ManagerDashboard> {

  final ProjectModel projectModel;
  final Animation animation;
  final Function(ProjectModel) onClick;

  final superkey;
  final List<DropdownMenuItem> _managerDropDownItems;
  final List<DropdownMenuItem> _employeeDropDownItems;
  final List<UserModel> _employee;
  final List<UserModel> _manager;
  List<Widget> _taskItems = [];
  final List<Task> _tasks = [];
  final List<ProjectModel> _projects;
  final List<ProjectModel> _onHoldProjects;

  final TextEditingController projectStatusController = new TextEditingController();
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectCostController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController taskDescriptionController =
  TextEditingController();

  bool isProjectUpdating = false;
  ProjectModel selectedProjectModel;

  String _assignedPid;
  String _taskStatus = "created";
  String _projectStatus = "created";
  String _assignedEmployee;
  String _assigned;
  String _assignedManager;
  String _assignedManagerName;

  DateTime startDate;
  DateTime endDate;

  final List<ProjectModel> _project;

  ManagerDashBoardState(this._managerDropDownItems, this._employeeDropDownItems,
      this._employee, this._project, this._manager, this.superkey,
      this._projects, this.projectModel, this.animation, this.onClick, this._onHoldProjects);

  final key = GlobalKey<FormState>();
  CollectionReference projects =
  FirebaseFirestore.instance.collection('projects');

  @override
  Widget build(BuildContext context) {
    {
      return DefaultTabController(
        initialIndex: 1,
        length: 3,
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
                Tab(
                  text: 'Project Report',
                  icon: Icon(Icons.print),
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
                            controller: projectNameController,
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
                                  DateTime
                                      .now()
                                      .millisecondsSinceEpoch) {
                                return "Date must be in future";
                              }
                              return null;
                            },
                            onDateSelected: (DateTime value) {
                              startDate = value;
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
                                  DateTime
                                      .now()
                                      .millisecondsSinceEpoch) {
                                return "Date must be in future";
                              }
                              return null;
                            },
                            onDateSelected: (DateTime value) {
                              endDate = value;
                            },
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Project Cost", hintText: 'Rs.'),
                            validator: RequiredValidator(errorText: "Required"),
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: projectCostController,
                          ),
                          new TextFormField(
                            decoration: new InputDecoration(
                                labelText: "Client", hintText: 'Client name'),
                            validator: RequiredValidator(errorText: "Required"),
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            controller: clientController,
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
                            onChanged: (val) =>
                            {
                              print(val),
                              _assignedManager = val,
                              _manager.forEach((element) {
                                if (_assignedManager == element.uid) {
                                  _assignedManagerName = element.full_name;
                                }
                              })
                            },
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
                            onChanged: (val) => { _projectStatus = val},
                            hint: Text("Select the status"),
                            value: "created",
                          ),
                          MaterialButton(
                              onPressed: () {
                                _showTaskAddingPopUp();
                              },
                              padding: EdgeInsets.only(top: 20, bottom: 10),
                              child: Container(
                                padding: EdgeInsets.all(15),
                                color: Colors.deepPurple[200],
                                child: Row(
                                  children: [
                                    Text(
                                      "Add a Task",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    Icon(
                                      Icons.library_add,
                                      color: Colors.white,
                                    )
                                  ],
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                ),
                              )),
                          Column(
                            children: _taskItems,
                          ),
                          DefaultButton("Create Project", () {
                            if (key.currentState.validate()) {
                              _createProject();
                            }
                          })
                        ],
                      ),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedList(
                  key: superkey,
                  initialItemCount: _projects.length,
                  itemBuilder: (context, index, animation) =>
                      buildListItem(_projects[index], index, animation),
                ),
              ),
              PdfPreview(
                  build: (format) => _generatePdf(format),
                ),
            ],
          ),
        ),
      );
    }
  }

  _createProject() {
    projects
        .add({
      'client': clientController.text,
      'end_date': endDate.millisecondsSinceEpoch,
      'start_date': startDate.millisecondsSinceEpoch,
      'cost': projectCostController.text,
      'manager': _assignedManager,
      'manager_name': _assignedManagerName,
      'project_name': projectNameController.text,
      'status': _projectStatus
    })
        .then((value) =>
    {
      print("User Added"),
      print(value.id),
      clientController.text = "",
      projectCostController.text = "",
      projectNameController.text = "",
      _assignedManager = "",
      _assignedManagerName = "",
      _projectStatus = "created",
      endDate = null,
      startDate = null
    })
        .catchError((error) => print("Failed to add user: $error"));
  }


  _showTaskAddingPopUp() {
    String status = "created";
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
                    Text("Enter Task Details"),
                    TextFormField(
                      decoration: new InputDecoration(
                          labelText: "Title", hintText: 'Enter the task title'),
                      validator: RequiredValidator(errorText: "Required"),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: taskTitleController,
                    ),
                    TextFormField(
                      decoration: new InputDecoration(
                          labelText: "Description",
                          hintText: 'Enter task description'),
                      validator: RequiredValidator(errorText: "Required"),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: taskDescriptionController,
                    ),
                    new DropdownButtonFormField(
                      icon: Icon(Icons.account_circle),
                      items: _employeeDropDownItems,
                      hint: Text("Assign an Employee"),
                      validator: (value) {
                        if (value == null) {
                          return "Required";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (val) {
                        _assignedEmployee = val;
                      },
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
                      onChanged: (val) => { status = val},
                      hint: Text("Select the status"),
                      value: "created",
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: DefaultButton("Submit Task", () {
                        if (key.currentState.validate()) {
                          String userName = "";

                          _employee.forEach((element) {
                            if (_assignedEmployee == element.uid) {
                              userName = element.full_name;
                            }
                          });

                          Task task = Task(
                              taskTitleController.text,
                              taskDescriptionController.text,
                              _assignedEmployee,
                              userName,
                              status);

                          _taskItems.add(addTaskItem(task));
                          this.setState(() {
                            _taskItems = _taskItems;
                          });
                        }
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

  _showUpdateDialog(ProjectModel project) {
    isProjectUpdating = true;
    selectedProjectModel = project;

    _showUpdateProjectPopUp();
  }

  _showUpdateProjectPopUp() {
    String status = "created";
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
                      onChanged: (val) => { status = val},
                      hint: Text("Select the status"),
                      value: "created",
                    ),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: DefaultButton("Update Project", () {
                        if (key.currentState.validate()) {
                          String projectStatus = "";

                          _projects.forEach((element) {
                            if (_assignedPid == element.pid) {
                              projectStatus = element.status;
                              print("aaaaaaaaaaaaaaaaa =======> " + projectStatus);
                            }
                          });

//                          ProjectModel project = ProjectModel(
//                              taskTitleController.text,
//                              taskDescriptionController.text,
//                              _assignedEmployee,
//                              userName,
//                              status);

                        }
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


  Widget addTaskItem(Task task) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text(task.title.toString(),
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Status : Created",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            tileColor: Colors.deepPurpleAccent[100],
          ),
          ListTile(
            title: Text("Description",
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(
              task.description,
              style: TextStyle(color: Colors.black.withOpacity(0.8)),
            ),
          ),
          ListTile(
            title: Text(task.employeeName),
            subtitle: Text(
              "EID : " + task.employee,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          )
        ],
      ),
    );
  }

//Widget buildListItem(ProjectModel context, int index, Animation<double> animation) {
//  return Card(
//    margin: EdgeInsets.all(10),
//    child: ListTile(
//      leading: Icon(Icons.insert_drive_file),
//      contentPadding: EdgeInsets.all(10),
//      title: Text( 'Name : ' + context.project_name),
//      subtitle: Text('Status : ' + context.status),
//      onTap: _textMethod,
//    ),
//  );
//}

  Widget buildListItem(ProjectModel project, int index,
      Animation<double> animation) {
    return ProjectCardItem(
      project: project,
      animation: animation,
      onClick: (project) => _showUpdateDialog(project),
    );
  }
  
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    const tableHeaders = ['Project Name', 'Reason'];

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {

          // Data table
          final table = pw.Table.fromTextArray(
            border: null,
            headers: tableHeaders,
            data: List<List<dynamic>>.generate(
              _onHoldProjects.length,
                  (index) => <dynamic>[
                    _onHoldProjects[index].project_name,
                    _onHoldProjects[index].status,
              ],
            ),
            headerHeight: 5,
            headerStyle: pw.TextStyle(
              color: PdfColors.red400,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(
            ),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  width: .5,
                ),
              ),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {0: pw.Alignment.centerLeft},
          );

          // Page layout
          return pw.Column(
            children: [
              pw.Text('On Hold Projects Report',
                  style: pw.TextStyle(
                    fontSize: 40,
                  )),
              pw.Divider(thickness: 4),
              pw.Expanded(
                flex: 2,
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 10),
                    pw.Expanded(child: table),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

            ],
          );
        },
      ),
    );

    return pdf.save();
  }

}
