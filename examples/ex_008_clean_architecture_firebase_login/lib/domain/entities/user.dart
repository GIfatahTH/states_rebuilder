class User {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;

  User({
    this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is User &&
        o.uid == uid &&
        o.email == email &&
        o.displayName == displayName &&
        o.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode;
  }
}

class UnLoggedUser extends User {}

class UserParam {
  final String email;
  final String password;
  final SignIn signIn;
  final SignUp signUp;
  UserParam({
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
