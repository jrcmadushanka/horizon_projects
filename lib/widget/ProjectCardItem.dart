
import 'package:flutter/material.dart';
import 'package:horizon_projects/model/models.dart';


class ProjectCardItem extends StatelessWidget{

  final ProjectModel project;
  final Animation animation;
  final Function(ProjectModel) onClick;

  const ProjectCardItem({Key key, @required this.project, @required this.animation, @required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => onClick(project),
          // onTap: ,
          // child: SizedBox(
          //   height: 80.0,
          child: Card(
            color: Colors.pinkAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Project Name : " + project.name,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Padding(padding: EdgeInsets.all(6)),
                            Text("Project Manager : "+ project.manager_name,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Padding(padding: EdgeInsets.all(6)),
                            Text("Status : "+ project.status,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Padding(padding: EdgeInsets.all(6)),
                            Text("Cost : "+ project.cost,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Padding(padding: EdgeInsets.all(6)),
                            Text("Client : "+ project.client,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        )),
                  ]
                // children[]: Text('Item $item', style: textStyle),
              ),
            ),
          ),
        ),
      ),
      //  ),
    );
  }
}
