import 'package:clean_architecture_dane_mackier_app/data_source/api.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/comment.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/domain/value_objects/email.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/input_exception.dart';

class FakeUserRepository implements UserRepository {
  final dynamic error;

  FakeUserRepository({this.error});

  @override
  Future<void> init() async {}

  @override
  Future<User> signIn(int? userId) async {
    if (userId == null) {
      throw NullNumberException();
    }
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    return User(id: userId, name: 'fakeName', username: 'fakeUserName');
  }

  @override
  Future<User> signUp(int? userId) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<void> signOut(int? param) {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}

class FakePostRepository implements PostRepository {
  final dynamic error;

  FakePostRepository({this.error});

  @override
  Future<List<Post>> read([int? userId]) async {
    if (userId == null) {
      throw NullNumberException();
    }
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    return [
      Post(
        id: 1,
        title: 'Post1 title',
        body: 'Post1 body',
        userId: userId,
      ),
      Post(
        id: 2,
        title: 'Post2 title',
        body: 'Post2 body',
        userId: userId,
      ),
      Post(
        id: 3,
        title: 'Post3 title',
        body: 'Post3 body',
        userId: userId,
      ),
    ];
  }

  @override
  Future<Post> create(Post item, int? param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Post> items, int? param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future update(List<Post> items, int? param) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}

class FakeCommentRepository implements CommentRepository {
  final dynamic error;

  FakeCommentRepository({this.error});

  @override
  Future<List<Comment>> read([int? postId]) async {
    if (postId == null) {
      throw NullNumberException();
    }
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }
    return [
      Comment(
          id: 1,
          name: 'FakeCommentName1',
          body: 'FakeCommentBody1',
          email: Email('fake1@mail.com'),
          postId: postId),
      Comment(
          id: 2,
          name: 'FakeCommentName2',
          body: 'FakeCommentBody2',
          email: Email('fake2@mail.com'),
          postId: postId),
      Comment(
          id: 3,
          name: 'FakeCommentName3',
          body: 'FakeCommentBody3',
          email: Email('fake3@mail.com'),
          postId: postId),
    ];
  }

  @override
  Future<Comment> create(Comment item, param) {
    throw UnimplementedError();
  }

  @override
  Future delete(List<Comment> items, int? param) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future update(List<Comment> items, int? param) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  void dispose() {}
}
