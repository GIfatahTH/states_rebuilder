import 'dart:convert';

import '../exceptions/validation_exception.dart';
import '../value_objects/email.dart';

class Comment {
  final int id;
  final int postId;
  final String name;
  //Email is a value object
  final Email email;
  final String body;

  Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  Comment copyWith({
    int? id,
    int? postId,
    String? name,
    Email? email,
    String? body,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      name: name ?? this.name,
      email: email ?? this.email,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email.email,
      'body': body,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      name: map['name'],
      email: Email(map['email']),
      body: map['body'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, name: $name, email: $email, body: $body)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Comment &&
        o.id == id &&
        o.postId == postId &&
        o.name == name &&
        o.email == email &&
        o.body == body;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        postId.hashCode ^
        name.hashCode ^
        email.hashCode ^
        body.hashCode;
  }
}
