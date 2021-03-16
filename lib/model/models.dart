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
  final String project_name;
  final String start_date;
  final String end_date;
  final String project_cost;
  final String project_manager;
  final String client;
  final String status;

  ProjectModel(this.pid, this.project_name, this.start_date, this.end_date, this.project_cost, this.project_manager, this.client, this.status);

}