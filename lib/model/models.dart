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