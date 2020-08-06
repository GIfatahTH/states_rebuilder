import '../exceptions/validation_exception.dart';

class User {
  int id;
  String name;
  String username;

  //Typically called form service layer to create a new user
  User({this.id, this.name, this.username});

  //Typically called from data_source layer after getting data from external source.
  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
  }

  //Typically called from service or data_source layer just before persisting data.
  //It is important to check data validity before persistance.
  Map<String, dynamic> toJson() {
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    return data;
  }

  _validation() {
    if (name == null) {
      throw ValidationException('You can not persist null name');
    }
  }
}
