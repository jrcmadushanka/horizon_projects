import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:horizon_projects/manageProjects.dart';
import 'package:horizon_projects/widget/ProjectCardItem.dart';
import 'package:horizon_projects/widget/defaultButton.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'model/models.dart';

class ManagerDashboard extends StatefulWidget {
  ManagerDashboard({Key key, this.projectModel, this.animation, this.onClick})
      : super(key: key) {
    _getAllEmployees();
    //  _getAllProjects();
    // _getOnHoldProjects();
    _getAllTasks();
  }

//  final superkey = GlobalKey<AnimatedListState>();
  final List<UserModel> _managers = [];
  final List<DropdownMenuItem> _managerDropDownItems = [];
  final List<UserModel> _employee = [];
  final List<DropdownMenuItem> _employeeDropDownItems = [];
  final List<ProjectModel> _project = [];
  final List<Task> _task = [];
  final taskkey = GlobalKey<AnimatedListState>();

//  final List<ProjectModel> _projects = [];
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

  _getAllTasks() async {
    try {
      FirebaseFirestore.instance
          .collection('tasks')
          .snapshots()
          .listen((event) {
        for (var i = 0; i <= _task.length - 1; i++) {
          taskkey.currentState.removeItem(0,
                  (BuildContext context, Animation<double> animation) {
                return Container();
              });
        }
        _task.clear();
        event.docs.forEach((element) {
          Task taskModel = Task(
                        element.data().containsKey("title") ? element["title"] : "",
            element.data().containsKey("description")
                ? element["description"]
                : "",
            element.data().containsKey("employee") ? element["employee"] : "",
            element.data().containsKey("employeeName") ? element["employeeName"] : "",
            element.data().containsKey("status") ? element["status"] : "",
              element.id
          );
          _task.add(taskModel);
//          taskkey.currentState.insertItem(_task.length - 1);
        });
      });
    } on FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  @override
  State<StatefulWidget> createState() {
    return new ManagerDashBoardState(
      _managerDropDownItems,
      _employeeDropDownItems,
      _employee,
      _project,
      _managers,
      //   _projects,
      projectModel,
      animation,
      onClick,
      _task
      /* _onHoldProjects*/
    );
  }
}

class ManagerDashBoardState extends State<ManagerDashboard>
    with SingleTickerProviderStateMixin {
  final ProjectModel projectModel;
  final Animation animation;
  final Function(ProjectModel) onClick;

  final onHoldListSuperKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState> allProjectListSuperKey;

  final List<DropdownMenuItem> _managerDropDownItems;
  final List<DropdownMenuItem> _employeeDropDownItems;
  final List<UserModel> _employee;
  final List<UserModel> _manager;
  List<Widget> _taskItems = [];
  final List<Task> _tasks;
  final List<ProjectModel> _projects = [];
  final List<ProjectModel> _onHoldProjects = [];

  final TextEditingController projectStatusController =
      new TextEditingController();
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectCostController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();

  bool isProjectUpdating = false;
  ProjectModel selectedProjectModel;

  String _taskStatus = "Created";
  String _projectStatus = "Created";
  String _assignedEmployee;
  String _assignedManager;
  String _assignedManagerName;

  DateTime startDate;
  DateTime endDate;

  final List<ProjectModel> _project;

  ManagerDashBoardState(
    this._managerDropDownItems,
    this._employeeDropDownItems,
    this._employee,
    this._project,
    this._manager,
    this.projectModel,
    this.animation,
    this.onClick,
      this._tasks
  );

  final key = GlobalKey<FormState>();
  CollectionReference projects =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference tasksRef = FirebaseFirestore.instance.collection('tasks');

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
              onTap: (value) => {
                print(value),
                if(value == 1){
                  //_getAllProjects()
                  allProjectListSuperKey.currentState.reassemble()
                }
              },
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
                  text: 'Report',
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
                                  DateTime.now().millisecondsSinceEpoch) {
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
                                  DateTime.now().millisecondsSinceEpoch) {
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
                            onChanged: (val) => {
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
                            onChanged: (val) => {_projectStatus = val},
                            hint: Text("Select the status"),
                            value: "Created",
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
              ManageProjects(),
              PdfPreview(
                build: (format) => _generatePdf(format),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    print("Calling init");
    allProjectListSuperKey = GlobalKey<AnimatedListState>();
    _getOnHoldProjects();
    super.initState();
  }

  _getOnHoldProjects() async {
    FirebaseFirestore.instance
        .collection('projects')
        .where('status', whereIn: ['onHold'])
        .get()
        .then((value) {
          print("Length of project list " + value.docs.length.toString());

          for (var i = 0; i <= _onHoldProjects.length - 1; i++) {
            onHoldListSuperKey.currentState.removeItem(0,
                (BuildContext context, Animation<double> animation) {
              return Container();
            });
          }
          _onHoldProjects.clear();

          ProjectModel projectModel;
          value.docs.forEach((element) {
            projectModel = ProjectModel(
                element.data().containsKey("pid") ? element["pid"] : "",
                element.data().containsKey("name")
                    ? element["name"]
                    : "",
                element.data().containsKey("start_date")
                    ? element["start_date"]
                    : "",
                element.data().containsKey("end_date")
                    ? element["end_date"]
                    : "",
                element.data().containsKey("cost")
                    ? element["cost"]
                    : "",
                element.data().containsKey("manager_name")
                    ? element["manager_name"]
                    : "",
                element.data().containsKey("client") ? element["client"] : "",
                element.data().containsKey("status") ? element["status"] : "",
                element.data().containsKey("manager") ? element["manager"] : "",
              element.id
            );

            _onHoldProjects.add(projectModel);
          });
          // print(_onHoldProjects.length);
          //  print(_onHoldProjects);
        });
  }

  _createProject() {
    projects.add({
      'client': clientController.text,
      'end_date': endDate.millisecondsSinceEpoch,
      'start_date': startDate.millisecondsSinceEpoch,
      'cost': projectCostController.text,
      'manager': _assignedManager,
      'manager_name': _assignedManagerName,
      'name': projectNameController.text,
      'status': _projectStatus
    }).then((value) {
      print("User Added");
      print(value.id);
      clientController.clear();
      projectNameController.clear();
      _assignedManager = "";
      _assignedManagerName = "";
      _projectStatus = "created";
      endDate = null;
      startDate = null;
      key.currentState.reset();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Successfully created the project..")));

      _tasks.forEach((task) async {
        await tasksRef.add({
          'project_id': value.id,
          'title': task.title,
          'description': task.description,
          'employee': task.employee,
          'employeeName': task.employeeName,
          'status': task.status
        });
      });

      _reset();

      setState(() {
        _tasks.clear();
      });
    }).catchError((error) => print("Failed to add user: $error"));
  }

  void _reset() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => ManagerDashboard(),
      ),
    );
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
                      value: "Created",
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
                              status, "");

                          _taskItems.add(addTaskItem(task));
                          this.setState(() {
                            _taskItems = _taskItems;
                          });
                          _tasks.add(task);
                          taskTitleController.clear();
                          taskDescriptionController.clear();
                          key.currentState.reset();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Task added"),
                          ));
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
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(
              "Status : Created",
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            tileColor: Colors.deepPurpleAccent[100],
          ),
          ListTile(
            title: Text("Description",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
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

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    const tableHeaders = ['Project Name', 'Reason'];
    const taskTableHeaders = ['Task Name', 'Employee Name'];

    const taskDataTable = [
      ['Design the solution', 'Chris'],
      ['Prepare for implementation', 'Hemsworth'],
      ['Prepare the test/QA ', 'William'],
      ['Install the product', 'Benito'],
      ['Implement distributed', 'Da Vinci'],
      ['Implement a business system', 'Leonardo'],
      ['Implement distributed data ', 'Homes'],
    ];

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
                _onHoldProjects[index].name,
                _onHoldProjects[index].status,
              ],
            ),
            headerHeight: 5,
            headerStyle: pw.TextStyle(
              color: PdfColors.red400,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(),
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
              pw.Text('Horizon PMS',
                  style: pw.TextStyle(
                    fontSize: 40,
                  )),
              pw.Text('On Hold Projects Report',
                  style: pw.TextStyle(
                    fontSize: 30,
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

    //Add 2nd page
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          // Data table
          final table = pw.Table.fromTextArray(
            border: null,
            headers: taskTableHeaders,
            data: List<List<dynamic>>.generate(
              _tasks.length,
              (index) => <dynamic>[
                _tasks[index].description,
                _tasks[index].employeeName,
              ],
            ),
            headerHeight: 5,
            headerStyle: pw.TextStyle(
              color: PdfColors.red400,
              fontSize: 25,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: pw.BoxDecoration(),
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  width: .5,
                ),
              ),
            ),
            cellAlignment: pw.Alignment.centerRight,
            cellAlignments: {0: pw.Alignment.centerLeft},
          );

          // Page layout
          return pw.Column(
            children: [
              pw.Text('Horizon PMS',
                  style: pw.TextStyle(
                    fontSize: 40,
                  )),
              pw.Text('Assigned Tasks Report',
                  style: pw.TextStyle(
                    fontSize: 30,
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
