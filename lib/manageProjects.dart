import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horizon_projects/widget/ProjectCardItem.dart';
import 'package:horizon_projects/widget/defaultButton.dart';

import 'model/models.dart';

class ManageProjects extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ManageProjectsState();
  }
}

class ManageProjectsState extends State<ManageProjects>{

  final allProjectListSuperKey =  GlobalKey<AnimatedListState>();
  final List<ProjectModel> _projects = [];

  var _assignedPid;

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: allProjectListSuperKey,
      initialItemCount: _projects.length,
      itemBuilder: (context, index, animation) =>
          buildListItem(_projects[index], index, animation),
    );
  }


  @override
  void initState() {
    _getAllProjects();
    super.initState();
  }

  _getAllProjects() async {
    FirebaseFirestore.instance.collection('projects').get().then((value) {
      print("Length of project list " + value.docs.length.toString());

      for (var i = 0; i <= _projects.length - 1; i++) {
        allProjectListSuperKey.currentState.removeItem(0,
                (BuildContext context, Animation<double> animation) {
              return Container();
            });
      }
      _projects.clear();

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
            element.data().containsKey("end_date") ? element["end_date"] : "",
            element.data().containsKey("cost")
                ? element["cost"]
                : "",
            element.data().containsKey("manager_name")
                ? element["manager_name"]
                : "",
            element.data().containsKey("client") ? element["client"] : "",
            element.data().containsKey("status") ? element["status"] : "",
            element.data().containsKey("manager") ? element["manager"] : "",
        );

        _projects.add(projectModel);
        allProjectListSuperKey.currentState.insertItem(_projects.length - 1);
      });
    });
  }

  Widget buildListItem(
      ProjectModel project, int index, Animation<double> animation) {
    print("Index : " + index.toString());

    return ProjectCardItem(
      project: project,
      animation: animation,
      onClick: (project) => _showUpdateDialog(project),
    );
  }

  _showUpdateDialog(ProjectModel project) {
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
                      onChanged: (val) => {status = val},
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
                            }
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

}