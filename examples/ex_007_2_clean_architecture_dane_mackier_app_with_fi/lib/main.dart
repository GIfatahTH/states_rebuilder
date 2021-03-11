import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'domain/entities/post.dart';
import 'ui/pages/comments_page/comments_page.dart';
import 'ui/pages/login_page/login_page.dart';
import 'ui/pages/posts_page/posts_page.dart';

void main() {
  //Set transitionBuilder to be one of the four predefined ones.
  //You can create yours
  RM.navigate.transitionsBuilder = RM.transitions.upToBottom();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      //As we will use states_rebuilder navigator
      //we assign its key to the navigator key
      navigatorKey: RM.navigate.navigatorKey,
      //To use named route, and to make them use the defined
      //transition builder, delegate to states_rebuilder the o
      //onGenerateRoute.
      //
      //The RM.navigate.onGenerateRoute takes a map of your routes and
      //returns the onGenerateRoute.
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          '/': (data) => LoginPage(),
          '/posts': (data) => PostsPage(),
          '/comments': (data) => CommentsPage(post: data.arguments as Post),
        },
      ),
    );
  }
}
