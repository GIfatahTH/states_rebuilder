import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../value_object/token.dart';

@immutable
class User {
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final Token token;
  User({
    required this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.token,
  });

  User copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    Token? token,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      token: token ?? this.token,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'token': token.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      token: Token.fromMap(map['token']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, displayName: $displayName, '
        'photoUrl: $photoUrl, token: $token)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is User &&
        o.userId == userId &&
        o.email == email &&
        o.displayName == displayName &&
        o.photoUrl == photoUrl &&
        o.token == token;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode ^
        token.hashCode;
  }
}

class UserParam {
  final String email;
  final String password;
  UserParam({
    required this.email,
    required this.password,
  });
}
