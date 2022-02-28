import 'dart:convert';

import 'package:meta/meta.dart';

import '../exceptions/validation_exception.dart';

@immutable
class Email {
  Email(
    this.email,
  ) {
    if (!email.contains('@')) {
      //Validation at the time of construction
      throw ValidationException('Your email must contain "@"');
    }
  }

  final String email;

  Email copyWith({
    String? email,
  }) {
    return Email(
      email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }

  factory Email.fromMap(Map<String, dynamic> map) {
    return Email(
      map['email'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Email.fromJson(String source) => Email.fromMap(json.decode(source));

  @override
  String toString() => 'Email(email: $email)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Email && o.email == email;
  }

  @override
  int get hashCode => email.hashCode;
}
