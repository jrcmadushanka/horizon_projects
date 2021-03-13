
import 'package:flutter/material.dart';
import 'package:horizon_projects/model/models.dart';


class UserCardItem extends StatelessWidget{

  final UserModel user;
  final Animation animation;
  final VoidCallback onClick;

  const UserCardItem({Key key, @required this.user, @required this.animation, @required this.onClick}) : super(key: key);

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
         onLongPress: onClick,
         // onTap: ,
          // child: SizedBox(
          //   height: 80.0,
          child: Card(
            color: Colors.purple[400],
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
                            Text(user.full_name,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Padding(padding: EdgeInsets.all(3)),
                            Text(user.email,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text("User ID : " + user.uid,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ],
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(user.type == "ADMIN"
                            ? Icons.admin_panel_settings_outlined
                            : user.type == "MANAGER"
                            ? Icons.supervised_user_circle
                            : Icons.construction_rounded),
                        Text(user.type,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
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
