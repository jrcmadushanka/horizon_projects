import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'defaultButton.dart';

class AddNewUserDialog extends StatefulWidget {
  final TextEditingController adminIdController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function onSubmitPressed;
  final Function onDeletePressed;
  final Function(String) onTypeSelect;

  const AddNewUserDialog(
      {Key key,
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed,
      this.onTypeSelect,
      this.onDeletePressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new AddNewUserDialogState(
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed,
      this.onTypeSelect,
      this.onDeletePressed);
}

class AddNewUserDialogState extends State<AddNewUserDialog> {
  final TextEditingController adminIdController;
  final TextEditingController passwordController;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController typeController;
  final Function onSubmitPressed;
  final Function onDeletePressed;
  final Function(String) onTypeSelect;

  bool _showAdminFields = false;
  bool _isEdit = false;

  AddNewUserDialogState(
      this.adminIdController,
      this.passwordController,
      this.emailController,
      this.nameController,
      this.typeController,
      this.onSubmitPressed,
      this.onTypeSelect,
      this.onDeletePressed) {
    _showAdminFields = typeController.text == "ADMIN";
    _isEdit = typeController.text == "";
  }

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
                    ),
                  ],
                  onChanged: _isEdit
                      ? (value) => {
                            this.setState(() {
                              _showAdminFields = value == "ADMIN";
                              onTypeSelect(value);
                            })
                          }
                      : null,
                  value: typeController.text == "" ? null : typeController.text,
                  disabledHint: Text(typeController.text),
                  hint: Text("Select the user type"),
                ),
                if (_showAdminFields)
                  new TextFormField(
                    decoration: new InputDecoration(
                        labelText: "Admin ID", fillColor: Colors.white),
                    obscureText: true,
                    controller: adminIdController,
                    autovalidateMode: AutovalidateMode.always,
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(4,
                          errorText: "ID should be atleast 4 characters"),
                      MaxLengthValidator(15,
                          errorText:
                              "ID should not be greater than 15 characters")
                    ]),
                  ),
                new TextFormField(
                  enabled: _isEdit,
                  decoration: new InputDecoration(
                      labelText: "Email", fillColor: Colors.white),
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.always,
                  validator: MultiValidator([
                    EmailValidator(errorText: "Invalid Email"),
                    RequiredValidator(errorText: "* Required")
                  ]),
                ),
                new TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Full Name", fillColor: Colors.white),
                  controller: nameController,
                  autovalidateMode: AutovalidateMode.always,
                  validator: RequiredValidator(errorText: "* Required"),
                ),
                new TextFormField(
                    decoration: new InputDecoration(
                        labelText: "Password", fillColor: Colors.white),
                    obscureText: true,
                    controller: passwordController,
                    autovalidateMode: AutovalidateMode.always,
                    validator: MultiValidator([
                      RequiredValidator(errorText: "* Required"),
                      MinLengthValidator(6,
                          errorText: "Password should be atleast 6 characters"),
                      MaxLengthValidator(15,
                          errorText:
                              "Password should not be greater than 15 characters")
                    ])),
                new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                new DefaultButton("Submit", () => { onSubmitPressed() } ),
                if (!_isEdit)
                  new DefaultButton("Delete", () => onDeletePressed()),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            nameController.text = "";
            passwordController.text = "";
            typeController.text = "";
            adminIdController.text = "";
            emailController.text = "";
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
