import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'defaultButton.dart';

class AddNewUserDialog extends StatefulWidget {
  final TextEditingController adminIdController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function onSubmitPressed;
  final Function(String) onTypeSelect;

  const AddNewUserDialog(
      {Key key,
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed, this.onTypeSelect})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new AddNewUserDialogState(
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed,
  this.onTypeSelect);

}

class AddNewUserDialogState extends State<AddNewUserDialog> {
  final TextEditingController adminIdController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function onSubmitPressed;
  final Function(String) onTypeSelect;

  bool _showAdminFields = false;
  String _newUserType = "";

  AddNewUserDialogState(
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed, this.onTypeSelect);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: const Text('Please insert your admin ID'),
      scrollable: true,
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Form(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new DropdownButtonFormField(
                  items: [
                    new DropdownMenuItem(
                      child: Text("Admin"),
                      value: "ADMIN",
                    ),
                    new DropdownMenuItem(
                        child: Text("Manager"), value: "MANAGER"),
                    new DropdownMenuItem(
                      child: Text("Employer"),
                      value: "EMPLOYER",
                    )
                  ],
                  onChanged: (value) => {
                    this.setState(() {
                      _showAdminFields = value == "ADMIN";
                      _newUserType = value;

                      print(_showAdminFields);
                      onTypeSelect(value);
                    })
                  },
                  hint: Text("Select the user type"),
                ),
                if (_showAdminFields)
                  new TextFormField(
                    decoration: new InputDecoration(
                        labelText: "Admin ID", fillColor: Colors.white),
                    obscureText: true,
                    controller: adminIdController,
                  ),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Email", fillColor: Colors.white),
                  controller: emailController,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Full Name", fillColor: Colors.white),
                  controller: nameController,
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Password", fillColor: Colors.white),
                  obscureText: true,
                  controller: passwordController,
                ),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                new DefaultButton("Submit", () => onSubmitPressed()),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
