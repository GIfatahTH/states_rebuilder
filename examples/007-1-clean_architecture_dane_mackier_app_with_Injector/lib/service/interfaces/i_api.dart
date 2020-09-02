import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';

abstract class IApi {
  Future<User> getUserProfile(int userId);
  Future<List<Post>> getPostsForUser(int userId);
  Future<List<Comment>> getCommentsForPost(int postId);
}
