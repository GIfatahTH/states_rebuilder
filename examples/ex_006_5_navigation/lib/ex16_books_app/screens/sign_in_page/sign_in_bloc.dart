import 'package:flutter/cupertino.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../ex18_books_app.dart';

/// A mock authentication service
@immutable
class _SignInBloc {
  final _signedIn = RM.inject<bool>(
    () => false,
    sideEffects: SideEffects.onData(
      (data) {
        if (navigator.routeData.redirectedFrom != null) {
          navigator.toDeeply(navigator.routeData.redirectedFrom!.location);
        } else {
          navigator.onNavigate();
        }
      },
    ),
  );
  bool get isSignedIn => _signedIn.state;

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    _signedIn.state = false;
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn.state = true;
    return _signedIn.state;
  }

  void dispose() {
    _signedIn.dispose();
  }
}

final signInBloc = _SignInBloc();
