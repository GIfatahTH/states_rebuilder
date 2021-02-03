import 'package:clean_architecture_dane_mackier_app/data_source/api.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/comment.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/domain/value_objects/email.dart';

class FakeUserRepository implements UserRepository {
  final dynamic error;

  FakeUserRepository({this.error});

  @override
  Future<List<User>> read([int userId]) async {
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    return [User(id: userId, name: 'fakeName', username: 'fakeUserName')];
  }

  @override
  Future<User> create(User item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(User item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> update(User item) {
    throw UnimplementedError();
  }
}

class FakePostRepository implements PostRepository {
  final dynamic error;

  FakePostRepository({this.error});

  @override
  Future<List<Post>> read([int userId]) async {
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    return [
      Post(
        id: 1,
        likes: 0,
        title: 'Post1 title',
        body: 'Post1 body',
        userId: userId,
      ),
      Post(
        id: 2,
        likes: 0,
        title: 'Post2 title',
        body: 'Post2 body',
        userId: userId,
      ),
      Post(
        id: 3,
        likes: 0,
        title: 'Post3 title',
        body: 'Post3 body',
        userId: userId,
      ),
    ];
  }

  @override
  Future<Post> create(Post item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(Post item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> update(Post item) {
    throw UnimplementedError();
  }
}

class FakeCommentRepository implements CommentRepository {
  final dynamic error;

  FakeCommentRepository({this.error});

  @override
  Future<List<Comment>> read([int postId]) async {
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
  Future<Comment> create(Comment item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(Comment item) {
    throw UnimplementedError();
  }

  @override
  Future<bool> update(Comment item) {
    throw UnimplementedError();
  }
}
