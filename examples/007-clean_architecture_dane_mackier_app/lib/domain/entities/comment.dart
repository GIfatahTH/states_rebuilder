import '../exceptions/validation_exception.dart';
import '../value_objects/email.dart';

class Comment {
  int id;
  int postId;
  String name;
  //Email is a value object
  Email email;
  String body;

  Comment({this.id, this.postId, this.name, this.email, this.body});

  Comment.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    id = json['id'];
    name = json['name'];
    email = Email(json['email']);
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email.email;
    data['body'] = this.body;
    return data;
  }

  _validation() {
    if (postId == null) {
      throw ValidationException('No post is associated with this comment');
    }
  }
}
