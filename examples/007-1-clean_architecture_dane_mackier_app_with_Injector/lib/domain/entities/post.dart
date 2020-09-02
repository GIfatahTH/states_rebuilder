import '../exceptions/validation_exception.dart';

class Post {
  int id;
  int userId;
  String title;
  String body;
  int likes;

  Post({this.id, this.userId, this.title, this.body, this.likes});

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
    likes = 0;
  }

  Map<String, dynamic> toJson() {
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['likes'] = this.likes;
    return data;
  }

  //Entities should contain all the logic that it controls
  incrementLikes() {
    likes++;
  }

  _validation() {
    if (userId == null) {
      throw ValidationException('No user is associated with this post');
    }
  }
}
