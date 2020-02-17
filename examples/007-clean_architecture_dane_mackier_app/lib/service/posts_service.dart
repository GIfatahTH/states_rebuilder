import '../domain/entities/post.dart';
import 'interfaces/i_api.dart';

//use case : Fetch posts by user ID, cache the obtained post list in memory and encapsulation of its processing
class PostsService {
  PostsService({IApi api}) : _api = api;
  IApi _api;
  List<Post> _posts = [];
  List<Post> get posts => _posts;

  void getPostsForUser(int userId) async {
    _posts = await _api.getPostsForUser(userId);
  }

  //Encapsulation of the logic of getting post likes.
  int getPostLikes(postId) {
    return _posts.firstWhere((post) => post.id == postId).likes;
  }

  //Encapsulation of the logic of incrementing the like of a post.
  void incrementLikes(int postId) {
    _posts.firstWhere((post) => post.id == postId).incrementLikes();
  }
}
