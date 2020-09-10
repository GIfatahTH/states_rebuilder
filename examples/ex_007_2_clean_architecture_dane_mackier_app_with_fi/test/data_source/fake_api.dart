import 'package:clean_architecture_dane_mackier_app/domain/entities/comment.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/service/interfaces/i_api.dart';

class FakeApi implements IApi {
  @override
  Future<User> getUserProfile(int userId) async {
    await Future.delayed(Duration(seconds: 1));

    return User(id: 1, name: 'Fake User Name');
  }

  @override
  Future<List<Comment>> getCommentsForPost(int postId) async {
    await Future.delayed(Duration(seconds: 1));
    return [Comment(id: 1, name: 'Fake comment', postId: 1)];
  }

  @override
  Future<List<Post>> getPostsForUser(int userId) async {
    await Future.delayed(Duration(seconds: 1));
    return [Post(id: 1, title: 'Fake title', likes: 0, userId: 1)];
  }
}
