import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';
import '../domain/entities/user.dart';
import '../service/exceptions/fetch_exception.dart';
import '../service/interfaces/i_api.dart';

//Implement the IApi class form the interface folder of the service layer.
//Errors must be catches and custom error defined in the service layer must be thrown instead.
class Api implements IApi {
  static const endpoint = 'https://jsonplaceholder.typicode.com';

  var client = new http.Client();

  Future<User> getUserProfile(int userId) async {
    var response;
    try {
      response = await client.get('$endpoint/users/$userId');
    } catch (e) {
      //Handle network error
      //It must throw custom errors classes defined in the service layer
      throw NetworkErrorException();
    }

    //Handle not found page
    if (response.statusCode == 404) {
      throw UserNotFoundException(userId);
    }
    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    return User.fromJson(json.decode(response.body));
  }

  Future<List<Post>> getPostsForUser(int userId) async {
    var posts = List<Post>();
    var response;
    try {
      response = await client.get('$endpoint/posts?userId=$userId');
    } catch (e) {
      throw NetworkErrorException();
    }
    if (response.statusCode == 404) {
      throw PostNotFoundException(userId);
    }

    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    var parsed = json.decode(response.body) as List<dynamic>;

    for (var post in parsed) {
      posts.add(Post.fromJson(post));
    }

    return posts;
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    var comments = List<Comment>();

    var response;
    try {
      response = await client.get('$endpoint/comments?postId=$postId');
    } catch (e) {
      throw NetworkErrorException();
    }
    if (response.statusCode == 404) {
      throw CommentNotFoundException(postId);
    }

    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    var parsed = json.decode(response.body) as List<dynamic>;

    for (var comment in parsed) {
      comments.add(Comment.fromJson(comment));
    }

    return comments;
  }
}
