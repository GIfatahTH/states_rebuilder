import 'dart:convert';

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  int likes = 0;
  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  //Entities should contain all the logic that it controls
  incrementLikes() {
    likes++;
  }

  Post copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    int? likes,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Post(id: $id, userId: $userId, title: $title, body: $body, likes: $likes)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Post &&
        o.id == id &&
        o.userId == userId &&
        o.title == title &&
        o.body == body &&
        o.likes == likes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        body.hashCode ^
        likes.hashCode;
  }
}
