import 'package:flutter/material.dart';

import '../domain/entities/post.dart';
import 'pages/comments_page/comments_page.dart';
import 'pages/posts_page/posts_page.dart';
import 'pages/login_page/login_page.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/posts':
        return MaterialPageRoute(builder: (_) => PostsPage());
      case '/comments':
        var post = settings.arguments as Post;
        return MaterialPageRoute(builder: (_) => CommentsPage(post: post));
      default:
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          );
        });
    }
  }
}
