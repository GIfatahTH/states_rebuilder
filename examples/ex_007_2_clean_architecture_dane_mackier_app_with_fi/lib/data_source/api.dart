import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/entities/comment.dart';
import '../domain/entities/post.dart';
import '../domain/entities/user.dart';
import '../service/exceptions/fetch_exception.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

const _endpoint = 'https://jsonplaceholder.typicode.com';
final _client = new http.Client();

class UserRepository implements ICRUD<User, int> {
  UserRepository();
  @override
  Future<List<User>> read([int userId]) async {
    var response;
    try {
      response = await _client.get('$_endpoint/users/$userId');
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

    return [User.fromJson(json.decode(response.body))];
  }

  @override
  Future<User> create(item, param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<User> items, int param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future update(List<User> items, int param) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class PostRepository implements ICRUD<Post, int> {
  @override
  Future<List<Post>> read([int userId]) async {
    var posts = <Post>[];
    var response;
    try {
      response = await _client.get('$_endpoint/posts?userId=$userId');
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

  @override
  Future<Post> create(Post item, param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Post> items, int param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future update(List<Post> items, int param) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class CommentRepository implements ICRUD<Comment, int> {
  @override
  Future<List<Comment>> read([int postId]) async {
    var comments = <Comment>[];

    var response;
    try {
      response = await _client.get('$_endpoint/comments?postId=$postId');
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

  @override
  Future<Comment> create(Comment item, param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Comment> items, int param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future update(List<Comment> items, int param) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

//Implement the IApi class form the interface folder of the service layer.
//Errors must be catches and custom error defined in the service layer must be thrown instead.
// class Api implements IApi {
//   var client = new http.Client();

//   Future<User> getUserProfile(int userId) async {
//     var response;
//     try {
//       response = await client.get('$endpoint/users/$userId');
//     } catch (e) {
//       //Handle network error
//       //It must throw custom errors classes defined in the service layer
//       throw NetworkErrorException();
//     }

//     //Handle not found page
//     if (response.statusCode == 404) {
//       throw UserNotFoundException(userId);
//     }
//     if (response.statusCode != 200) {
//       throw NetworkErrorException();
//     }

//     return User.fromJson(json.decode(response.body));
//   }

//   Future<List<Post>> getPostsForUser(int userId) async {
//     var posts = <Post>[];
//     var response;
//     try {
//       response = await client.get('$endpoint/posts?userId=$userId');
//     } catch (e) {
//       throw NetworkErrorException();
//     }
//     if (response.statusCode == 404) {
//       throw PostNotFoundException(userId);
//     }

//     if (response.statusCode != 200) {
//       throw NetworkErrorException();
//     }

//     var parsed = json.decode(response.body) as List<dynamic>;

//     for (var post in parsed) {
//       posts.add(Post.fromJson(post));
//     }

//     return posts;
//   }

//   Future<List<Comment>> getCommentsForPost(int postId) async {
//     var comments = <Comment>[];

//     var response;
//     try {
//       response = await client.get('$endpoint/comments?postId=$postId');
//     } catch (e) {
//       throw NetworkErrorException();
//     }
//     if (response.statusCode == 404) {
//       throw CommentNotFoundException(postId);
//     }

//     if (response.statusCode != 200) {
//       throw NetworkErrorException();
//     }

//     var parsed = json.decode(response.body) as List<dynamic>;

//     for (var comment in parsed) {
//       comments.add(Comment.fromJson(comment));
//     }

//     return comments;
//   }
// }
