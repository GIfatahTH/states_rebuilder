class User {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? token;

  User({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.token,
  });

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode;
  }
}

class AuthParam {
  final String? email;
  final String? password;
  final SignIn? signIn;
  final SignUp? signUp;
  AuthParam({
    this.email,
    this.password,
    this.signIn,
    this.signUp,
  });
}

enum SignIn {
  anonymously,
  withApple,
  withGoogle,
  withEmailAndPassword,
}
enum SignUp { withEmailAndPassword }
