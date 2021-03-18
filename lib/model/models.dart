class UserModel{
  final String uid;
  final String doc;
  final String full_name;
  final String admin_id;
  final String email;
  final String type;
  final String password;

  UserModel(this.uid, this.full_name, this.admin_id, this.email, this.type, this.password, this.doc);
}

class Task{
  final String title;
  final String description;
  final String employee;
  final String employeeName;
  final String status;

  Task(this.title, this.description, this.employee, this.employeeName, this.status);
}

class ProjectModel{
  final String pid;
  final String name;
  final int start_date;
  final int end_date;
  final String cost;
  final String manager_name;
  final String manager;
  final String client;
  final String status;

  ProjectModel(this.pid, this.name, this.start_date, this.end_date, this.cost, this.manager_name, this.client, this.status, this.manager);

}