import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'domain/entities/post.dart';
import 'ui/pages/comments_page/comments_page.dart';
import 'ui/pages/login_page/login_page.dart';
import 'ui/pages/posts_page/posts_page.dart';

final navigator = RM.injectNavigator(
  transitionsBuilder: RM.transitions.upToBottom(),
  routes: {
    '/': (data) => LoginPage(),
    '/posts': (data) => PostsPage(),
    '/comments': (data) => CommentsPage(post: data.arguments as Post),
  },
);

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigator 2
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(),
      routerDelegate: navigator.routerDelegate,
      routeInformationParser: navigator.routeInformationParser,
    );

    // For Navigator 1
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(),
    //   //As we will use states_rebuilder navigator
    //   //we assign its key to the navigator key
    //   navigatorKey: RM.navigate.navigatorKey,
    //   //To use named route, and to make them use the defined
    //   //transition builder, delegate to states_rebuilder the o
    //   //onGenerateRoute.
    //   //
    //   //The RM.navigate.onGenerateRoute takes a map of your routes and
    //   //returns the onGenerateRoute.
    //   onGenerateRoute: RM.navigate.onGenerateRoute(
    //     {
    //       '/': (data) => LoginPage(),
    //       '/posts': (data) => PostsPage(),
    //       '/comments': (data) => CommentsPage(post: data.arguments as Post),
    //     },
    //   ),
    // );
  }
}
